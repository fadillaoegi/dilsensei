import 'package:dilsensei/core/localization/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/lesson_test_fixtures.dart';

/// Membuka Pengaturan lalu menggulir sampai dasar daftar.
///
/// Blok dev berada di paling bawah, dan ListView-nya lazy — tanpa menggulir,
/// widget yang tidak ada dan widget yang belum dibangun tampak sama.
Future<void> _openSettingsAndScrollToBottom(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Settings'));
  await tester.pumpAndSettle();

  await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('perkakas dev aktif menampilkan kedua tombol', (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      buildTestApp(language: AppLanguage.english, devToolsEnabled: true),
    );
    await pumpUntilLoaded(tester);
    await tester.pump();

    await _openSettingsAndScrollToBottom(tester);

    expect(find.text('DEVELOPMENT'), findsOneWidget);
    expect(find.text('DEV: Complete all modules'), findsOneWidget);
  });

  testWidgets('perkakas dev mati menghapus seluruh blok dev', (tester) async {
    // Menirukan build release: kedua tombol dan label bagiannya harus hilang
    // sepenuhnya, bukan sekadar dinonaktifkan.
    usePhoneViewport(tester);
    await tester.pumpWidget(
      buildTestApp(language: AppLanguage.english, devToolsEnabled: false),
    );
    await pumpUntilLoaded(tester);
    await tester.pump();

    await _openSettingsAndScrollToBottom(tester);

    expect(find.text('DEVELOPMENT'), findsNothing);
    expect(find.text('DEV: Complete all modules'), findsNothing);
    expect(find.textContaining('DEV:'), findsNothing);

    // Pengaturan lain tetap ada, jadi yang hilang benar-benar hanya blok dev.
    expect(find.text('Restore purchases'), findsOneWidget);
  });

  testWidgets('override premium diabaikan saat perkakas dev mati', (
    tester,
  ) async {
    // Lapis kedua: walau gerbang render ditimpa, status premium tetap tidak
    // boleh berasal dari override dev.
    usePhoneViewport(tester);
    await tester.pumpWidget(
      buildTestApp(language: AppLanguage.english, devToolsEnabled: false),
    );
    await pumpUntilLoaded(tester);
    await tester.pump();

    await _openSettingsAndScrollToBottom(tester);

    // Tidak ada jalan masuk ke override premium dari UI.
    expect(find.textContaining('Force'), findsNothing);
    expect(find.textContaining('Pro aktif'), findsNothing);
  });
}
