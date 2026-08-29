#!/usr/bin/env bash
# Mengisi email dukungan dan URL halaman legal di satu langkah.
#
# Pakai:
#   bash tool/fill_legal.sh support@contoh.com https://namamu.github.io/dilsensei
#
# Argumen kedua opsional. Bila diisi, nilainya juga ditulis ke dart_defines.json
# sebagai LEGAL_BASE_URL supaya tautan pada paywall menunjuk ke halaman yang
# benar-benar hidup.
#
# Play Console mewajibkan kebijakan privasi berada di URL publik dan memuat
# kontak yang bisa dihubungi. Placeholder yang tertinggal akan membuat app
# ditolak, dan test test/core/legal_pages_test.dart menjaga hal itu.
set -euo pipefail

EMAIL="${1:-}"
BASE_URL="${2:-}"

if [[ -z "$EMAIL" ]]; then
  echo "Pakai: bash tool/fill_legal.sh <email-dukungan> [url-basis-legal]" >&2
  exit 1
fi

if [[ ! "$EMAIL" =~ ^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$ ]]; then
  echo "Email tidak terlihat valid: $EMAIL" >&2
  exit 1
fi

if [[ -n "$BASE_URL" ]]; then
  if [[ ! "$BASE_URL" =~ ^https:// ]]; then
    echo "URL legal harus memakai https:// — Play menolak http biasa." >&2
    exit 1
  fi
  if [[ "$BASE_URL" == */ ]]; then
    echo "Hilangkan garis miring di akhir URL: $BASE_URL" >&2
    exit 1
  fi
fi

# Halaman legal.
for file in docs/index.html docs/privacy.html docs/terms.html; do
  if [[ ! -f "$file" ]]; then
    echo "Tidak menemukan $file" >&2
    exit 1
  fi
  python3 - "$file" "$EMAIL" <<'PY'
import pathlib, sys

path, email = sys.argv[1], sys.argv[2]
p = pathlib.Path(path)
text = p.read_text()
count = text.count('REPLACE_WITH_SUPPORT_EMAIL')
p.write_text(text.replace('REPLACE_WITH_SUPPORT_EMAIL', email))
print(f'  {path}: {count} placeholder diisi')
PY
done

# URL legal untuk tautan di dalam app.
if [[ -n "$BASE_URL" ]]; then
  python3 - "$BASE_URL" <<'PY'
import json, pathlib, sys

base = sys.argv[1]
p = pathlib.Path('dart_defines.json')
if not p.exists():
    print('  dart_defines.json belum ada; lewati LEGAL_BASE_URL')
    raise SystemExit

data = json.loads(p.read_text())
data['LEGAL_BASE_URL'] = base
p.write_text(json.dumps(data, indent=2) + '\n')
print(f'  dart_defines.json: LEGAL_BASE_URL = {base}')
print(f'  privacy  -> {base}/privacy.html')
print(f'  terms    -> {base}/terms.html')
PY
fi

echo
if grep -rq 'REPLACE_WITH_' docs/*.html; then
  echo "Masih ada placeholder yang tertinggal:"
  grep -rn 'REPLACE_WITH_' docs/*.html
  exit 1
fi

echo "Semua placeholder terisi. Jalankan verifikasinya:"
echo "  flutter test test/core/legal_pages_test.dart"
