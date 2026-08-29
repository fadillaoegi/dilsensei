import 'package:dilsensei/core/analytics/analytics_service.dart';
import 'package:dilsensei/core/localization/language_controller.dart';
import 'package:dilsensei/core/monetization/domain/subscription_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/lesson_test_fixtures.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('menyelesaikan sesi mencatat peristiwa beserta skornya', (
    tester,
  ) async {
    final analytics = FakeAnalyticsService();

    usePhoneViewport(tester);
    await tester.pumpWidget(
      buildTestApp(language: AppLanguage.english, analytics: analytics),
    );
    await pumpUntilLoaded(tester);

    await tester.tap(find.text('Start session (5 min)'));
    await tester.pumpAndSettle();

    // Dua butir dijawab benar sampai sesi tuntas.
    for (final answer in <List<String>>[
      ['まいにち', 'がっこう', 'に', 'いきます'],
      ['コーヒー', 'を', 'のみません'],
    ]) {
      for (final token in answer) {
        await tester.tap(find.text(token));
        await tester.pump();
      }
      await tester.tap(find.widgetWithText(ElevatedButton, 'Check'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is ElevatedButton &&
              widget.child is Text &&
              ((widget.child! as Text).data == 'Continue' ||
                  (widget.child! as Text).data == 'See result'),
        ),
      );
      await tester.pumpAndSettle();
    }

    expect(analytics.names, contains('sessionCompleted'));

    final logged = analytics.entries.firstWhere(
      (entry) => entry.event == AnalyticsEvent.sessionCompleted,
    );
    expect(logged.parameters?['planned_count'], 2);
    expect(logged.parameters?['first_try_correct'], 2);
    expect(logged.parameters?.containsKey('reflex_score'), isTrue);
  });

  testWidgets('membuka paywall dan gagal membeli tercatat sebabnya', (
    tester,
  ) async {
    final analytics = FakeAnalyticsService();

    usePhoneViewport(tester);
    await tester.pumpWidget(
      buildTestApp(
        language: AppLanguage.english,
        analytics: analytics,
        subscriptionService: FakeSubscriptionService(
          purchaseResult: const PurchaseResult.failed(
            null,
            failure: PurchaseFailure.storeError,
          ),
        ),
      ),
    );
    await pumpUntilLoaded(tester);

    await tapModule(tester, 'Angka & Jam');
    await tester.pumpAndSettle();

    expect(analytics.names, contains('paywallViewed'));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Start subscription'));
    await tester.pumpAndSettle();

    expect(analytics.names, contains('purchaseStarted'));

    final failure = analytics.entries.firstWhere(
      (entry) => entry.event == AnalyticsEvent.purchaseFailed,
    );
    expect(failure.parameters?['reason'], 'storeError');

    // Tidak ada peristiwa sukses saat pembelian gagal.
    expect(analytics.names, isNot(contains('purchaseCompleted')));
  });

  testWidgets('tidak ada data pribadi yang ikut pada parameter peristiwa', (
    tester,
  ) async {
    final analytics = FakeAnalyticsService();

    usePhoneViewport(tester);
    await tester.pumpWidget(
      buildTestApp(
        language: AppLanguage.english,
        analytics: analytics,
        userName: 'Rina',
      ),
    );
    await pumpUntilLoaded(tester);

    await tester.tap(find.text('Start session (5 min)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('まいにち'));
    await tester.pump();

    for (final entry in analytics.entries) {
      final values = entry.parameters?.values.map((v) => '$v').toList() ?? [];
      expect(
        values,
        isNot(contains('Rina')),
        reason: 'nama pengguna tidak boleh masuk analytics',
      );
      for (final value in values) {
        expect(
          value.contains('まいにち'),
          isFalse,
          reason: 'jawaban pengguna tidak boleh masuk analytics',
        );
      }
    }
  });
}
