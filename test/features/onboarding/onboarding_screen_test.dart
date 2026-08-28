import 'package:dilsensei/features/lesson/presentation/screens/home_screen.dart';
import 'package:dilsensei/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:dilsensei/features/onboarding/presentation/widgets/choice_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/lesson_test_fixtures.dart';

Future<void> _pumpOnboarding(WidgetTester tester) async {
  await tester.pumpWidget(buildTestApp(skipOnboarding: false));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 16));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('pengguna baru diarahkan ke onboarding, bukan Home', (
    tester,
  ) async {
    await _pumpOnboarding(tester);

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(find.text('Kita mulai dari\nnamamu'), findsOneWidget);
  });

  testWidgets('tombol Lanjut terkunci sampai nama cukup panjang', (
    tester,
  ) async {
    await _pumpOnboarding(tester);

    ElevatedButton nextButton() => tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Lanjut'),
    );

    expect(nextButton().onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'A');
    await tester.pump();
    expect(nextButton().onPressed, isNull, reason: 'satu huruf belum cukup');

    await tester.enterText(find.byType(TextField), 'Fadil');
    await tester.pump();
    expect(nextButton().onPressed, isNotNull);
  });

  testWidgets(
    'menyelesaikan tiga langkah menyimpan preferensi dan masuk Home',
    (tester) async {
      await _pumpOnboarding(tester);

      // Langkah 1: nama.
      await tester.enterText(find.byType(TextField), 'Rina');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Lanjut'));
      await tester.pumpAndSettle();

      // Langkah 2: tujuan belajar.
      expect(find.text('Kenapa belajar\nbahasa Jepang?'), findsOneWidget);
      expect(find.byType(ChoiceCard), findsNWidgets(4));

      var lanjut = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Lanjut'),
      );
      expect(lanjut.onPressed, isNull, reason: 'harus memilih dulu');

      await tester.tap(find.text('Untuk kerja'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Lanjut'));
      await tester.pumpAndSettle();

      // Langkah 3: target harian.
      expect(find.text('Berapa menit\nsehari?'), findsOneWidget);
      expect(find.byType(ChoiceCard), findsNWidgets(3));
      expect(
        find.widgetWithText(ElevatedButton, 'Mulai Berlatih'),
        findsOneWidget,
      );

      await tester.tap(find.text('10 menit · Mantap'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Mulai Berlatih'));
      await tester.pumpAndSettle();

      // Onboarding selesai: Home muncul dengan nama yang diisi.
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.text('Konnichiwa, Rina!'), findsOneWidget);

      // Preferensi benar-benar tersimpan di penyimpanan lokal.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('dilsensei.onboarding.completed'), isTrue);
      expect(prefs.getString('dilsensei.onboarding.name'), 'Rina');
      expect(prefs.getString('dilsensei.onboarding.goal'), 'work');
      expect(prefs.getInt('dilsensei.onboarding.daily_target_minutes'), 10);
    },
  );

  testWidgets('tombol Kembali mengembalikan ke langkah sebelumnya', (
    tester,
  ) async {
    await _pumpOnboarding(tester);

    expect(
      find.text('Kembali'),
      findsNothing,
      reason: 'tidak ada di langkah 1',
    );

    await tester.enterText(find.byType(TextField), 'Rina');
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Lanjut'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();

    expect(find.text('Kita mulai dari\nnamamu'), findsOneWidget);
  });

  testWidgets('preferensi tersimpan membuat app langsung membuka Home', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'dilsensei.onboarding.completed': true,
      'dilsensei.onboarding.name': 'Budi',
      'dilsensei.onboarding.goal': 'exam',
      'dilsensei.onboarding.daily_target_minutes': 15,
    });

    await _pumpOnboarding(tester);

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.text('Konnichiwa, Budi!'), findsOneWidget);
  });
}
