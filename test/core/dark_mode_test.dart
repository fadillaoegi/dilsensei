import 'dart:io';
import 'dart:math' as math;

import 'package:dilsensei/core/theme/app_theme.dart';
import 'package:dilsensei/core/theme/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Luminansi relatif menurut definisi WCAG 2.1.
double _luminance(Color color) {
  double linear(double channel) {
    return channel <= 0.03928
        ? channel / 12.92
        : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * linear(color.r) +
      0.7152 * linear(color.g) +
      0.0722 * linear(color.b);
}

/// Rasio kontras WCAG antara dua warna solid, dari 1:1 sampai 21:1.
double _contrast(Color a, Color b) {
  final first = _luminance(a);
  final second = _luminance(b);
  final lighter = math.max(first, second);
  final darker = math.min(first, second);

  return (lighter + 0.05) / (darker + 0.05);
}

/// Seluruh berkas Dart di `lib`, kecuali definisi tema itu sendiri.
Iterable<File> _uiSources() {
  return Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .where((file) => !file.path.contains('core/theme'));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('palet', () {
    test('tema gelap memakai warna yang berbeda dari tema terang', () {
      expect(AppPalette.dark.surface, isNot(AppPalette.light.surface));
      expect(AppPalette.dark.surfaceCard, isNot(AppPalette.light.surfaceCard));
      expect(AppPalette.dark.textPrimary, isNot(AppPalette.light.textPrimary));
      expect(AppPalette.dark.primary, isNot(AppPalette.light.primary));
    });

    test('latar gelap lebih gelap daripada latar terang', () {
      // Menangkap palet yang tertukar antar tema.
      expect(
        _luminance(AppPalette.dark.surface),
        lessThan(_luminance(AppPalette.light.surface)),
      );
      expect(
        _luminance(AppPalette.dark.textPrimary),
        greaterThan(_luminance(AppPalette.light.textPrimary)),
      );
    });

    test('kartu selalu terbedakan dari latar halaman', () {
      for (final palette in <AppPalette>[AppPalette.light, AppPalette.dark]) {
        expect(
          palette.surfaceCard,
          isNot(palette.surface),
          reason: 'kartu yang sewarna latar membuat batas kartu hilang',
        );
      }
    });

    test('teks memenuhi kontras minimum WCAG AA di kedua tema', () {
      final palettes = <String, AppPalette>{
        'terang': AppPalette.light,
        'gelap': AppPalette.dark,
      };

      for (final entry in palettes.entries) {
        final name = entry.key;
        final palette = entry.value;

        expect(
          _contrast(palette.textPrimary, palette.surface),
          greaterThanOrEqualTo(4.5),
          reason: 'teks utama pada tema $name kurang kontras',
        );
        expect(
          _contrast(palette.textSecondary, palette.surface),
          greaterThanOrEqualTo(4.5),
          reason: 'teks sekunder pada tema $name kurang kontras',
        );
        expect(
          _contrast(palette.textPrimary, palette.surfaceCard),
          greaterThanOrEqualTo(4.5),
          reason: 'teks utama di atas kartu pada tema $name kurang kontras',
        );
        expect(
          _contrast(palette.onPrimary, palette.primary),
          greaterThanOrEqualTo(4.5),
          reason: 'teks pada tombol utama tema $name kurang kontras',
        );
      }
    });

    test('warna galat tetap terbaca di kedua tema', () {
      for (final palette in <AppPalette>[AppPalette.light, AppPalette.dark]) {
        expect(
          _contrast(palette.error, palette.surface),
          greaterThanOrEqualTo(3.0),
        );
      }
    });

    test('palet setara berdasarkan nilai', () {
      // Dibutuhkan oleh shouldRepaint pada painter yang menerima palet.
      expect(AppPalette.light.copyWith(), AppPalette.light);
      expect(AppPalette.light.copyWith().hashCode, AppPalette.light.hashCode);
      expect(AppPalette.light == AppPalette.dark, isFalse);
    });

    test('lerp bergerak dari satu palet ke palet lain', () {
      expect(AppPalette.light.lerp(AppPalette.dark, 0), AppPalette.light);
      expect(AppPalette.light.lerp(AppPalette.dark, 1), AppPalette.dark);
      expect(AppPalette.light.lerp(null, 0.5), AppPalette.light);
    });
  });

  group('tema', () {
    test('kedua tema memasang ekstensi palet', () {
      expect(AppTheme.light.extension<AppPalette>(), AppPalette.light);
      expect(AppTheme.dark.extension<AppPalette>(), AppPalette.dark);
    });

    test('brightness dan latar scaffold sesuai paletnya', () {
      expect(AppTheme.light.brightness, Brightness.light);
      expect(AppTheme.dark.brightness, Brightness.dark);
      expect(AppTheme.light.scaffoldBackgroundColor, AppPalette.light.surface);
      expect(AppTheme.dark.scaffoldBackgroundColor, AppPalette.dark.surface);
    });

    test('tombol utama memakai warna palet, bukan warna bawaan Material', () {
      final style = AppTheme.dark.elevatedButtonTheme.style;
      final background = style?.backgroundColor?.resolve(<WidgetState>{});
      final foreground = style?.foregroundColor?.resolve(<WidgetState>{});

      expect(background, AppPalette.dark.primary);
      expect(foreground, AppPalette.dark.onPrimary);
    });
  });

  group('pilihan mode tema', () {
    test('default mengikuti setelan perangkat', () {
      expect(AppThemeMode.defaultMode, AppThemeMode.system);
      expect(AppThemeMode.system.themeMode, ThemeMode.system);
      expect(AppThemeMode.light.themeMode, ThemeMode.light);
      expect(AppThemeMode.dark.themeMode, ThemeMode.dark);
    });

    test('kode tidak dikenal jatuh ke default, bukan melempar', () {
      expect(AppThemeMode.fromCode(null), AppThemeMode.system);
      expect(AppThemeMode.fromCode('kabut'), AppThemeMode.system);
      expect(AppThemeMode.fromCode('dark'), AppThemeMode.dark);
    });

    test('pilihan tersimpan dan terbaca kembali', () async {
      const dataSource = ThemeModeLocalDataSource();

      expect(await dataSource.read(), AppThemeMode.system);

      await dataSource.write(AppThemeMode.dark);

      expect(await dataSource.read(), AppThemeMode.dark);
    });

    test('controller menuliskan pilihan ke penyimpanan', () async {
      final controller = ThemeModeController(
        dataSource: const ThemeModeLocalDataSource(),
        initial: AppThemeMode.system,
      );
      addTearDown(controller.dispose);

      await controller.select(AppThemeMode.dark);

      expect(controller.state, AppThemeMode.dark);
      expect(await const ThemeModeLocalDataSource().read(), AppThemeMode.dark);
    });

    test('controller memuat pilihan tersimpan saat dibuat', () async {
      await const ThemeModeLocalDataSource().write(AppThemeMode.light);

      final controller = ThemeModeController(
        dataSource: const ThemeModeLocalDataSource(),
      );
      addTearDown(controller.dispose);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state, AppThemeMode.light);
    });
  });

  group('penjaga warna hardcoded', () {
    test('tidak ada layar atau widget yang memakai AppColors langsung', () {
      // Warna konstan hanya boleh hidup di core/theme. Widget yang memakainya
      // langsung tidak akan ikut berubah saat mode gelap aktif — bug yang mudah
      // lolos dari pemeriksaan mata karena tampak benar di tema terang.
      final offenders = _uiSources()
          .where((file) => file.readAsStringSync().contains('AppColors.'))
          .map((file) => file.path)
          .toList();

      expect(
        offenders,
        isEmpty,
        reason:
            'pakai context.palette agar ikut berubah pada mode gelap: '
            '${offenders.join(', ')}',
      );
    });

    test('tidak ada warna absolut hitam atau putih di UI', () {
      // Colors.transparent tetap boleh karena tidak bergantung tema.
      final pattern = RegExp(r'\bColors\.(white|black)\b');
      final offenders = _uiSources()
          .where((file) => pattern.hasMatch(file.readAsStringSync()))
          .map((file) => file.path)
          .toList();

      expect(
        offenders,
        isEmpty,
        reason: 'warna absolut ditemukan di: ${offenders.join(', ')}',
      );
    });
  });
}
