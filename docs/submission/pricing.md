# Harga dan produk

Daftar harga yang dipakai, beserta cara mengisinya di Play Console dan
RevenueCat. Angka di sini adalah **harga dasar dalam USD**; Google Play yang
mengubahnya menjadi mata uang lokal setiap negara.

---

## Daftar harga

| Paket | Harga dasar | Package di RevenueCat | Bentuk di Play Console |
| --- | --- | --- | --- |
| Bulanan | $2.99 | `$rc_monthly` | Base plan pada subscription |
| Tahunan | $24.99 | `$rc_annual` | Base plan pada subscription |
| Lifetime (sekali beli) | $49.99 | `$rc_lifetime` | In-app product |

Ketiganya dilampirkan ke **satu** entitlement: `pro`.

### Yang harus cocok, dan yang tidak

Kolom yang wajib cocok hanyalah **package identifier** (`$rc_monthly`,
`$rc_annual`, `$rc_lifetime`), karena itulah yang dipetakan kode ke
`BillingPeriod`. Product ID di Play Console **tidak** perlu sama dengan yang di
Test Store.

Itu penting karena RevenueCat merepresentasikan langganan Google Play sebagai
`<subscription_id>:<base_plan_id>` — misalnya `dilsensei_pro:monthly-autorenewing`
— jadi mustahil menyamakannya dengan `monthly` milik Test Store. Selama package
identifier-nya benar, paywall tidak perlu diubah sama sekali.

Nama yang disarankan, karena **Product ID di Play tidak bisa dipakai ulang
selamanya, bahkan setelah dihapus**:

| Objek | Identifier |
| --- | --- |
| Subscription | `dilsensei_pro` |
| Base plan bulanan | `monthly-autorenewing` |
| Base plan tahunan | `annual-autorenewing` |
| In-app product lifetime | `dilsensei_lifetime_v1` |

### Jebakan: lifetime harus non-consumable

Di dashboard RevenueCat, produk lifetime **wajib** ditandai *non-consumable*.
Bila tidak, RevenueCat akan meng-`consume` pembeliannya dan Google mengizinkan
pengguna membelinya lagi — "sekali beli" yang bisa dibeli berulang, dan
entitlement yang hilang setelah beberapa waktu.

## Diskon tahunan

$24.99 dibanding membayar bulanan setahun ($2.99 × 12 = $35.88) berarti hemat
**30%**.

Angka itu **tidak dipatok di kode**. Paywall menghitungnya dari harga nyata yang
dilaporkan store lewat `SubscriptionPlan.annualSavingsPercent`. Konsekuensinya
penting: kalau kamu mengubah harga di Play Console, badge diskonnya ikut berubah
sendiri dan tidak pernah berbohong. Bila paket tahunan ternyata tidak lebih
murah, badge-nya hilang alih-alih menampilkan angka menyesatkan.

Dijaga oleh `test/core/pricing_test.dart`.

---

## Key mana yang dipakai build mana

Otomatis menurut mode build, tanpa argumen tambahan:

| Build | Key | Akibatnya |
| --- | --- | --- |
| `flutter run` (debug) | `test_...` | Pembelian tiruan, tidak menagih uang |
| `flutter build appbundle --release` | `goog_...` | Pembelian sungguhan lewat Google Play |

Build rilis **menolak** key Test Store walau key itu diberikan lewat dart-define.
Sudah diverifikasi pada APK dan AAB: string `test_` nol kali, `goog_` satu kali.

---

## Mata uang: yang menentukan adalah negara, bukan bahasa app

Ini sering disalahpahami, jadi ditulis tegas.

**Harga tidak datang dari app.** Paywall menampilkan `priceString` apa adanya
dari Google Play. Play sendiri yang menentukan mata uang dan angkanya,
berdasarkan **negara akun penagihan pengguna**.

Artinya:

- Pengguna dengan akun Play Indonesia melihat `Rp …` secara otomatis.
- Pengguna dengan akun Play Amerika melihat `$…`.
- Keduanya terjadi **tanpa** app melakukan apa pun, dan **tanpa** ada kaitan
  dengan sakelar bahasa di Pengaturan.

**App tidak boleh mengonversi mata uang sendiri.** Kalau pengguna di Amerika
mengganti bahasa app ke Indonesia lalu paywall menampilkan Rupiah, angka itu
salah — Play tetap akan menagihnya dalam dolar. Menampilkan harga yang berbeda
dari yang ditagih adalah klaim menyesatkan, dan Play menindaknya. Karena itu
tidak ada kurs, tidak ada konversi, dan tidak ada harga yang ditulis di kode.

Yang berubah mengikuti bahasa app hanyalah **teksnya**: judul paket, label
periode, dan badge "Hemat 30%" / "Save 30%".

### Cara mengaturnya di Play Console

1. Buat produk dengan harga dasar USD sesuai tabel di atas.
2. Play menghasilkan harga lokal untuk setiap negara secara otomatis. Periksa
   khusus **Indonesia**, karena hasil konversi otomatis sering menghasilkan angka
   yang tidak lazim seperti `Rp 47.312`.
3. Bulatkan harga Indonesia ke angka yang wajar secara psikologis, misalnya
   `Rp 49.000` untuk bulanan. Menaikkan atau menurunkan sedikit tidak masalah;
   yang penting rasio tahunan tetap sekitar 30% agar badge diskonnya tetap masuk
   akal.
4. Pastikan **Amerika Serikat** termasuk negara yang tersedia — rules Shipaton
   mewajibkan app dapat diunduh dari sana.

### Yang perlu diperiksa setelah produk dibuat

```
bash tool/check_revenuecat.sh
```

Baris PRODUKSI harus berubah dari "BELUM SIAP" menjadi "SIAP" dengan 3 paket.
Skrip itu tidak bisa memeriksa dua hal, jadi keduanya harus dilihat manual di
dashboard:

- Ketiga produk sudah dilampirkan ke entitlement `pro`. Gejala bila belum:
  pembelian berhasil tapi app menampilkan "langganan belum aktif".
- Free trial sudah aktif pada langganan bulanan dan tahunan. Rules lomba
  mewajibkan free trial **atau** promo code untuk juri.
