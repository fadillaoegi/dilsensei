import 'package:dilsensei/features/lesson/presentation/screens/drill_session_screen.dart';
import 'package:dilsensei/features/monetization/presentation/screens/paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/lesson_test_fixtures.dart';

void main() {
  testWidgets('pengguna gratis melihat kunci dan diarahkan ke paywall', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(subscriptionService: FakeSubscriptionService()),
    );
    await pumpUntilLoaded(tester);

    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);

    await tester.tap(find.text('Angka & Jam'));
    await tester.pumpAndSettle();

    expect(find.byType(PaywallScreen), findsOneWidget);
    expect(find.byType(DrillSessionScreen), findsNothing);
  });

  testWidgets('pengguna premium membuka modul premium tanpa paywall', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        subscriptionService: FakeSubscriptionService(isPremium: true),
      ),
    );
    await pumpUntilLoaded(tester);
    await tester.pump();

    expect(
      find.byIcon(Icons.lock_rounded),
      findsNothing,
      reason: 'entitlement aktif menghilangkan kunci',
    );
    expect(find.text('10 mnt'), findsOneWidget);

    await tester.tap(find.text('Angka & Jam'));
    await tester.pumpAndSettle();

    expect(find.byType(PaywallScreen), findsNothing);
  });
}
