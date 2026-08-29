import 'package:dilsensei/core/localization/language_controller.dart';
import 'package:dilsensei/core/theme/app_theme.dart';
import 'package:dilsensei/core/theme/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/lesson_test_fixtures.dart';

/// Membuka paywall dari modul premium di Home.
Future<void> _openPaywall(
  WidgetTester tester, {
  required AppThemeMode themeMode,
}) async {
  usePhoneViewport(tester);
  await tester.pumpWidget(
    buildTestApp(language: AppLanguage.english, themeMode: themeMode),
  );
  await pumpUntilLoaded(tester);

  // Fixture test tidak menyediakan judul bahasa Inggris, sehingga judulnya
  // jatuh ke bahasa Indonesia meski app berbahasa Inggris.
  await tapModule(tester, 'Angka & Jam');
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('paywall memakai palet gelap dan tetap menampilkan harga', (
    tester,
  ) async {
    await _openPaywall(tester, themeMode: AppThemeMode.dark);

    final context = tester.element(find.byType(Scaffold).first);

    expect(Theme.of(context).brightness, Brightness.dark);
    expect(context.palette, AppPalette.dark);

    // Harga dari store tetap tampil; mode gelap tidak boleh menyembunyikannya.
    expect(find.textContaining('Rp'), findsWidgets);
    expect(
      find.widgetWithText(ElevatedButton, 'Start subscription'),
      findsOneWidget,
    );
  });

  testWidgets('kartu paket terpilih dan tidak terpilih tetap terbedakan', (
    tester,
  ) async {
    await _openPaywall(tester, themeMode: AppThemeMode.dark);

    // Warna kartu berasal dari dua peran palet yang berbeda, sehingga keadaan
    // terpilih tetap terlihat di mode gelap.
    expect(
      AppPalette.dark.surfaceAccent,
      isNot(AppPalette.dark.surfaceCard),
      reason: 'kartu terpilih harus berbeda dari kartu biasa',
    );

    final materials = tester
        .widgetList<Material>(find.byType(Material))
        .map((material) => material.color)
        .whereType<Color>()
        .toSet();

    // Tidak ada permukaan terang yang menyelip ke mode gelap.
    expect(materials.contains(AppPalette.light.surfaceCard), isFalse);
    expect(materials.contains(AppPalette.light.surfaceAccent), isFalse);
  });

  testWidgets('tombol utama paywall memakai kontras onPrimary yang benar', (
    tester,
  ) async {
    await _openPaywall(tester, themeMode: AppThemeMode.dark);

    final context = tester.element(
      find.widgetWithText(ElevatedButton, 'Start subscription'),
    );
    final style = Theme.of(context).elevatedButtonTheme.style;
    final background = style?.backgroundColor?.resolve(<WidgetState>{});
    final foreground = style?.foregroundColor?.resolve(<WidgetState>{});

    // Tema gelap memakai hijau terang sebagai latar tombol dan warna gelap
    // sebagai teksnya — kebalikan dari tema terang.
    expect(background, AppPalette.dark.primary);
    expect(foreground, AppPalette.dark.onPrimary);
    expect(foreground, isNot(AppPalette.light.onPrimary));
  });
}
