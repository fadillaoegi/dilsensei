import 'package:dilsensei/features/lesson/presentation/screens/drill_session_screen.dart';
import 'package:dilsensei/features/lesson/presentation/widgets/lesson_list_item.dart';
import 'package:dilsensei/features/lesson/presentation/widgets/today_module_card.dart';
import 'package:dilsensei/features/monetization/presentation/screens/paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/lesson_test_fixtures.dart';

void main() {
  testWidgets('menampilkan skeleton loading sebelum data siap', (tester) async {
    // Data ditahan supaya state loading benar-benar terlihat.
    await tester.pumpWidget(
      buildTestApp(
        repository: FakeLessonRepository(delay: const Duration(seconds: 1)),
      ),
    );
    await pumpUntilLoaded(tester);

    expect(find.text('Konnichiwa, Fadil!'), findsOneWidget);
    expect(find.text('Menyiapkan sesi latihanmu...'), findsOneWidget);
    expect(find.byType(TodayModuleCard), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(TodayModuleCard), findsOneWidget);
  });

  testWidgets('hero card memakai modul gratis pertama dan tidak diulang '
      'di daftar', (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(buildTestApp());
    await pumpUntilLoaded(tester);

    expect(find.byType(TodayModuleCard), findsOneWidget);
    expect(find.text('MODUL HARI INI'), findsOneWidget);
    expect(find.text('Mulai Sesi (5 Menit)'), findsOneWidget);

    // Judul modul hero hanya muncul sekali (tidak duplikat di list).
    expect(find.text('Sapaan & Aisatsu Dasar'), findsOneWidget);

    expect(find.text('Peta Belajarmu'), findsOneWidget);
    expect(find.byType(LessonListItem), findsNWidgets(2));
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    expect(find.text('8 mnt'), findsOneWidget);
  });

  testWidgets('tap modul gratis membuka layar sesi latihan', (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(buildTestApp());
    await pumpUntilLoaded(tester);

    await tapModule(tester, 'Frasa Perkenalan Diri');
    await tester.pumpAndSettle();

    expect(find.byType(DrillSessionScreen), findsOneWidget);
    expect(find.byType(PaywallScreen), findsNothing);
  });

  testWidgets('tap modul premium membuka paywall', (tester) async {
    await openPaywallFromHome(tester);

    expect(find.byType(PaywallScreen), findsOneWidget);
  });

  testWidgets('state error menampilkan pesan dan tombol coba lagi', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      buildTestApp(repository: FakeLessonRepository(shouldFail: true)),
    );
    await pumpUntilLoaded(tester);

    expect(find.text('Materi belum bisa dimuat'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
  });
}
