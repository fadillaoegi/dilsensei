# Aturan ProGuard/R8 untuk build release.
#
# Flutter dan plugin resmi sudah membawa aturannya sendiri (consumer rules),
# jadi file ini hanya memuat penjagaan tambahan.

# Google Play Billing dipakai purchases_flutter lewat refleksi pada sebagian kelas.
-keep class com.android.billingclient.api.** { *; }
-keep class com.revenuecat.purchases.** { *; }

# Jangan buang informasi baris agar stack trace crash tetap terbaca.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
