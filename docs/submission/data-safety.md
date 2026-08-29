# Draf jawaban form Data Safety (Play Console)

Disusun dari perilaku app yang sebenarnya, bukan template. Poin bertanda
**PERIKSA** perlu kamu konfirmasi sendiri sebelum dikirim, karena Play meminta
kamu bertanggung jawab atas jawabannya.

Yang perlu diingat: Play menganggap data yang dikumpulkan **SDK pihak ketiga**
sebagai data yang app-mu kumpulkan. Di app ini ada tiga: RevenueCat, Google Play
Billing, dan **Google Analytics for Firebase**.

Catatan penting soal Analytics: pengumpulan **advertising ID dimatikan** lewat
`tools:node="remove"` pada izin `com.google.android.gms.permission.AD_ID` dan
meta-data `google_analytics_adid_collection_enabled=false`. Karena itu kamu
**tidak** perlu mendeklarasikan identitas periklanan. Pengumpulan juga hanya
aktif pada build release.

---

## Ringkasan yang benar untuk app ini

| Pertanyaan | Jawaban |
|---|---|
| Apakah app mengumpulkan atau membagikan tipe data yang diwajibkan? | **Ya** — pembelian lewat RevenueCat dan peristiwa pemakaian lewat Firebase Analytics |
| Semua data terenkripsi saat transit? | **Ya** |
| Menyediakan cara menghapus data? | **Ya** — lewat email dukungan, sebutkan di halaman Privacy Policy |
| Data dikumpulkan dari anak-anak? | **Tidak**; app tidak menyasar anak di bawah 13 tahun |
| Ada akun pengguna? | **Tidak** |

---

## Tipe data

### Purchases — Purchase history

- **Dikumpulkan**: Ya
- **Dibagikan**: Tidak. RevenueCat adalah pemroses atas nama kami, bukan pihak
  yang menerima data untuk keperluannya sendiri. **PERIKSA** sekali lagi bila
  kamu nanti mengaktifkan integrasi RevenueCat ke layanan analitik lain, karena
  itu mengubah jawaban ini menjadi "dibagikan".
- **Opsional atau wajib**: Wajib untuk fungsi langganan
- **Tujuan**: App functionality
- **Terenkripsi saat transit**: Ya
- **Bisa diminta hapus**: Ya

### Device or other IDs

- **Dikumpulkan**: Ya
- Penjelasan: dua identifier tanpa nama. RevenueCat membuat *anonymous app user
  ID* untuk menautkan pembelian ke pemasangan app, dan Firebase membuat
  *installation ID* untuk analytics. Keduanya **bukan** advertising ID dan tidak
  ditautkan ke nama atau email.
- **Tujuan**: App functionality dan Analytics
- **Terenkripsi saat transit**: Ya

### App activity — App interactions

- **Dikumpulkan**: **Ya** (karena Google Analytics for Firebase)
- **Dibagikan**: Tidak
- **Opsional atau wajib**: Wajib; tidak ada sakelar pengguna untuk analytics
- **Tujuan**: Analytics
- **Terenkripsi saat transit**: Ya
- Peristiwa yang dicatat: menyelesaikan onboarding, memulai dan menyelesaikan
  sesi, membuka bagan huruf, membuka paywall, memulai dan menyelesaikan
  pembelian, kegagalan pembelian, mencapai batas harian, menyalakan pengingat,
  membuka Training Record, mengganti bahasa. Tidak ada isi jawaban maupun nama
  panggilan yang disertakan.

### App info and performance — Crash logs / Diagnostics

- **Dikumpulkan**: **Tidak**
- App ini tidak memakai Crashlytics maupun Sentry. Firebase Analytics tanpa
  Crashlytics tidak mengirim laporan crash.

### Personal info (nama, email, dll.)

- **Dikumpulkan**: **Tidak**
- Nama panggilan yang diisi saat onboarding **tidak pernah dikirim ke mana pun**;
  hanya tersimpan di penyimpanan privat app. Play tidak menganggap data yang
  hanya berada di perangkat sebagai "collected".

### Location, Contacts, Photos, Messages, Audio, Files, Calendar, Health

- **Dikumpulkan**: **Tidak** untuk semuanya. App tidak meminta izin apa pun di
  kategori ini.

---

## Izin yang dideklarasikan dan alasannya

Siapkan jawaban ini karena reviewer bisa menanyakannya:

| Izin | Alasan |
|---|---|
| `INTERNET`, `ACCESS_NETWORK_STATE` | Verifikasi status langganan dan mengambil harga dari store |
| `POST_NOTIFICATIONS` | Pengingat latihan harian, hanya bila pengguna menyalakannya |
| `RECEIVE_BOOT_COMPLETED` | Menjadwalkan ulang pengingat setelah perangkat restart |
| `VIBRATE` | Dibawa oleh pustaka notifikasi |
| `WAKE_LOCK`, `ACCESS_ADSERVICES_*` | Dibawa oleh Firebase Analytics; advertising ID sendiri sudah dicabut |

---

## Kolom lain yang sering terlewat

- **Privacy Policy URL**: `https://<username>.github.io/dilsensei/privacy.html`
  — wajib bisa diakses publik sebelum submit.
- **Ads**: pilih **tidak ada iklan**. App ini tidak menayangkan iklan, dan
  advertising ID tidak dikumpulkan meski Analytics aktif.
- **Content rating**: isi kuesionernya; app edukasi tanpa konten sensitif,
  tanpa interaksi antar pengguna, tanpa pembelian acak.
- **Target audience**: 13 tahun ke atas. Jangan pilih kategori anak-anak, karena
  itu memicu kewajiban tambahan Families Policy.
- **Data deletion**: karena tidak ada akun, cukup jelaskan bahwa menghapus app
  menghapus seluruh data lokal, dan permintaan penghapusan catatan pembelian
  dilayani lewat email dukungan dengan menyertakan order ID Play.

---

## Bila nanti fitur berubah

Tiga perubahan ini **mengubah jawaban di atas** dan harus diperbarui sebelum
rilis versinya:

1. Menambahkan Crashlytics atau Sentry → data diagnostik jadi "Ya".
2. Menambahkan OneSignal → push token dan device ID masuk hitungan, dan biasanya
   dihitung sebagai dibagikan ke pihak ketiga.
3. Menambahkan login atau sinkronisasi → data pribadi jadi "Ya", plus Apple dan
   Play mewajibkan fitur hapus akun di dalam app.
