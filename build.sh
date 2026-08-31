#!/bin/bash

# ============================================================
# build.sh — Flutter Auto-Versioning Build Script
# Proyek: dilsensei
# Deskripsi: Otomatis menaikkan versionCode (+1) di pubspec.yaml
#            sebelum menjalankan flutter build.
# ============================================================

set -e

PUBSPEC="pubspec.yaml"

# Pastikan pubspec.yaml ada
if [ ! -f "$PUBSPEC" ]; then
  echo "❌ File $PUBSPEC tidak ditemukan di direktori ini."
  echo "   Jalankan script dari root folder project Flutter."
  exit 1
fi

# Baca versi saat ini dari pubspec.yaml
CURRENT_VERSION=$(grep '^version:' "$PUBSPEC" | sed 's/version: //' | tr -d '[:space:]')

if [ -z "$CURRENT_VERSION" ]; then
  echo "❌ Format versi tidak ditemukan di $PUBSPEC."
  echo "   Pastikan ada baris seperti: version: 1.0.2+15"
  exit 1
fi

BUILD_NAME=$(echo "$CURRENT_VERSION" | cut -d'+' -f1)
BUILD_NUMBER=$(echo "$CURRENT_VERSION" | cut -d'+' -f2)

# Validasi bahwa BUILD_NUMBER adalah angka
if ! [[ "$BUILD_NUMBER" =~ ^[0-9]+$ ]]; then
  echo "❌ versionCode tidak valid: '$BUILD_NUMBER'"
  echo "   Pastikan format versi: X.Y.Z+N (contoh: 1.0.2+15)"
  exit 1
fi

# Naikkan versionCode +1
NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))
NEW_VERSION="$BUILD_NAME+$NEW_BUILD_NUMBER"

echo ""
echo "📦 Versi saat ini : $CURRENT_VERSION"
echo "🔼 Versi baru      : $NEW_VERSION"
echo ""

# Tulis versi baru ke pubspec.yaml
sed -i '' "s/^version: .*/version: $NEW_VERSION/" "$PUBSPEC"

# ---- Konfigurasi build ----
#
# Tanpa baris ini, dart_defines.json diabaikan sepenuhnya dan build memakai
# nilai bawaan di kode — termasuk LEGAL_BASE_URL `example.invalid`, yang membuat
# tautan Privacy Policy dan Terms pada paywall menunjuk ke domain mati. Itu
# pernah benar-benar terjadi dan ikut ke AAB rilis: string `example.invalid`
# terbukti ada dua kali di dalam libapp.so.
DEFINES_FILE="dart_defines.json"
DEFINES_ARG=()

if [ -f "$DEFINES_FILE" ]; then
  DEFINES_ARG=(--dart-define-from-file="$DEFINES_FILE")
  echo "🔧 Memakai $DEFINES_FILE"
else
  echo "⚠️  $DEFINES_FILE tidak ada. Build memakai nilai bawaan di kode;"
  echo "    tautan legal akan menunjuk ke example.invalid dan Play menolaknya."
fi
echo ""

# ---- Mode Build ----

if [ "$1" = "--no-build" ]; then
  echo "✅ versionCode dinaikkan ke $NEW_BUILD_NUMBER. Build dilewati."
  exit 0

elif [ "$1" = "apk" ]; then
  echo "🔨 Membangun APK..."
  echo ""
  flutter build apk --release "${DEFINES_ARG[@]}"
  echo ""
  echo "✅ APK selesai! (versi $NEW_VERSION)"
  echo "📂 Lokasi: build/app/outputs/flutter-apk/app-release.apk"

else
  echo "🔨 Membangun App Bundle..."
  echo ""
  flutter build appbundle --release "${DEFINES_ARG[@]}"
  echo ""
  echo "✅ App Bundle selesai! (versi $NEW_VERSION)"
  echo "📂 Lokasi: build/app/outputs/bundle/release/app-release.aab"
fi
