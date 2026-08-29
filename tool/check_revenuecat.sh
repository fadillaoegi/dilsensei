#!/usr/bin/env bash
# Memeriksa apakah dashboard RevenueCat sudah siap dipakai app.
#
# Pakai:
#   bash tool/check_revenuecat.sh
#
# Membaca key dari dart_defines.json (tidak ikut di-commit) lalu memanggil
# endpoint offerings untuk setiap key. Yang dicari: sebuah offering yang
# ditandai Current dan memuat paket. Offering tanpa paket berarti produk belum
# dibuat atau belum dilampirkan, dan paywall akan tampil kosong.
set -uo pipefail

DEFINES="${1:-dart_defines.json}"

if [[ ! -f "$DEFINES" ]]; then
  echo "Tidak menemukan $DEFINES. Salin dari dart_defines.example.json lalu isi." >&2
  exit 1
fi

probe() {
  local name="$1" key="$2"

  if [[ -z "$key" ]]; then
    printf '%-12s : belum diisi\n' "$name"
    return
  fi

  local user_id="dilsensei_check_$(date +%s)_$RANDOM"
  local response
  response=$(curl -s -w $'\n%{http_code}' \
    --request GET \
    --url "https://api.revenuecat.com/v1/subscribers/${user_id}/offerings" \
    --header "Authorization: Bearer ${key}" \
    --header "X-Platform: android" \
    --header "Accept: application/json")

  local status="${response##*$'\n'}"
  local body="${response%$'\n'*}"

  printf '%-12s : key %s...%s | HTTP %s\n' \
    "$name" "${key:0:9}" "${key: -4}" "$status"

  if [[ "$status" != "200" ]]; then
    echo "               key ditolak; periksa apakah key ini milik project yang benar"
    return
  fi

  KEY_LABEL="$name" python3 - "$body" <<'PY'
import json, os, sys

label = os.environ['KEY_LABEL']
data = json.loads(sys.argv[1])
current = data.get('current_offering_id')
offerings = data.get('offerings', [])
total = sum(len(o.get('packages', [])) for o in offerings)

print(f"               offering Current : {current or 'BELUM DITANDAI'}")
print(f"               jumlah offering  : {len(offerings)}")
print(f"               jumlah paket     : {total}")

for offering in offerings:
    marker = ' (Current)' if offering.get('identifier') == current else ''
    print(f"                 - {offering.get('identifier')}{marker}")
    for package in offering.get('packages', []):
        print(
            f"                     {package.get('identifier')}"
            f" -> {package.get('platform_product_identifier')}"
        )

problems = []
if not current:
    problems.append('tidak ada offering yang ditandai Current')
if total == 0:
    problems.append(
        'offering tidak memuat paket: produk belum dibuat di store '
        'atau belum dilampirkan ke offering'
    )

if problems:
    print(f"               BELUM SIAP ({label}):")
    for problem in problems:
        print(f"                 - {problem}")
else:
    print(f"               SIAP ({label})")
PY
}

read_key() {
  python3 -c "
import json, sys
data = json.load(open('$DEFINES'))
print(data.get('$1', ''))
"
}

echo "Memeriksa konfigurasi RevenueCat lewat $DEFINES"
echo

probe "TEST STORE" "$(read_key REVENUECAT_TEST_KEY)"
echo
probe "PRODUKSI" "$(read_key REVENUECAT_ANDROID_KEY)"

cat <<'NOTE'

Yang tidak bisa diperiksa skrip ini:
  - Apakah produk sudah dilampirkan ke entitlement 'pro'. Gejalanya bila belum:
    pembelian berhasil tapi app menampilkan "langganan belum aktif".
  - Apakah produk menawarkan free trial. Info itu hanya datang dari store lewat
    SDK, jadi harus dilihat dengan menjalankan app di perangkat.
NOTE
