import 'dart:async';

import 'package:dilsensei/core/monetization/domain/subscription_models.dart';
import 'package:dilsensei/core/monetization/domain/subscription_service.dart';
import 'package:dilsensei/core/monetization/monetization_providers.dart';
import 'package:dilsensei/core/routing/app_router.dart';
import 'package:dilsensei/features/lesson/domain/entities/drill_item.dart';
import 'package:dilsensei/features/lesson/domain/entities/lesson_module.dart';
import 'package:dilsensei/features/lesson/domain/repositories/lesson_repository.dart';
import 'package:dilsensei/features/lesson/presentation/providers/lesson_providers.dart';
import 'package:dilsensei/features/lesson/presentation/providers/progress_controller.dart';
import 'package:dilsensei/features/onboarding/domain/onboarding_preferences.dart';
import 'package:dilsensei/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:dilsensei/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const testModules = <LessonModule>[
  LessonModule(
    id: 'free-1',
    title: 'Sapaan & Aisatsu Dasar',
    subtitle: 'Salam harian dari pagi hingga malam.',
    durationMinutes: 5,
    isPremium: false,
    backgroundChar: 'お',
  ),
  LessonModule(
    id: 'free-2',
    title: 'Frasa Perkenalan Diri',
    subtitle: 'Nama, asal, dan pekerjaan.',
    durationMinutes: 8,
    isPremium: false,
    backgroundChar: '私',
  ),
  LessonModule(
    id: 'premium-1',
    title: 'Angka & Jam',
    subtitle: 'Membaca angka, menit, dan janji temu.',
    durationMinutes: 10,
    isPremium: true,
    backgroundChar: '時',
  ),
];

const testDrillItems = <DrillItem>[
  DrillItem(
    id: 'drill-1',
    moduleId: 'free-1',
    prompt: 'Saya pergi ke sekolah setiap hari.',
    answerTokens: ['まいにち', 'がっこう', 'に', 'いきます'],
    distractorTokens: ['を', 'で'],
    patternIds: ['particle_place', 'word_order_time'],
  ),
  DrillItem(
    id: 'drill-2',
    moduleId: 'free-1',
    prompt: 'Saya tidak minum kopi.',
    answerTokens: ['コーヒー', 'を', 'のみません'],
    distractorTokens: ['に', 'のみます'],
    patternIds: ['particle_object', 'negative_form'],
  ),
];

class FakeLessonRepository implements LessonRepository {
  FakeLessonRepository({
    this.modules = testModules,
    this.drillItems = testDrillItems,
    this.shouldFail = false,
    this.delay = Duration.zero,
  });

  final List<LessonModule> modules;
  final List<DrillItem> drillItems;
  final bool shouldFail;

  /// Menahan hasil agar state loading dapat diuji secara deterministik.
  final Duration delay;

  @override
  Future<List<LessonModule>> getLessonModules() async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (shouldFail) {
      throw Exception('gagal memuat modul');
    }
    return modules;
  }

  @override
  Future<List<DrillItem>> getDrillItems(String moduleId) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (shouldFail) {
      throw Exception('gagal memuat butir drill');
    }
    return drillItems
        .where((item) => item.moduleId == moduleId)
        .toList(growable: false);
  }
}

/// Fake service langganan agar paywall bisa diuji tanpa store maupun SDK.
class FakeSubscriptionService implements SubscriptionService {
  FakeSubscriptionService({
    this.plans = testPlans,
    this.isPremium = false,
    this.purchaseResult = const PurchaseResult.success(),
    this.restoreResult = const PurchaseResult.success(),
    this.plansThrow = false,
  });

  final List<SubscriptionPlan> plans;
  final bool isPremium;
  final PurchaseResult purchaseResult;
  final PurchaseResult restoreResult;
  final bool plansThrow;

  final StreamController<PremiumStatus> _controller =
      StreamController<PremiumStatus>.broadcast();

  /// Id paket yang terakhir dibeli, untuk diperiksa di test.
  String? lastPurchasedPlanId;
  int restoreCallCount = 0;

  @override
  Future<void> initialize() async {}

  @override
  Stream<PremiumStatus> premiumStatusChanges() => _controller.stream;

  @override
  Future<PremiumStatus> currentStatus() async =>
      PremiumStatus(isPremium: isPremium);

  @override
  Future<List<SubscriptionPlan>> fetchPlans() async {
    if (plansThrow) throw Exception('gagal mengambil paket');
    return plans;
  }

  @override
  Future<PurchaseResult> purchase(String planId) async {
    lastPurchasedPlanId = planId;
    if (purchaseResult.isSuccess) {
      _controller.add(const PremiumStatus(isPremium: true));
    }
    return purchaseResult;
  }

  @override
  Future<PurchaseResult> restorePurchases() async {
    restoreCallCount++;
    if (restoreResult.isSuccess) {
      _controller.add(const PremiumStatus(isPremium: true));
    }
    return restoreResult;
  }
}

const testPlans = <SubscriptionPlan>[
  SubscriptionPlan(
    id: 'monthly',
    title: 'Paket Bulanan',
    priceLabel: 'Rp 49.000',
    period: BillingPeriod.monthly,
    trialDescription: '3 hari gratis',
    isRecommended: true,
  ),
  SubscriptionPlan(
    id: 'lifetime',
    title: 'Akses Selamanya',
    priceLabel: 'Rp 249.000',
    period: BillingPeriod.lifetime,
  ),
];

Widget buildTestApp({
  LessonRepository? repository,
  DateTime? now,
  SubscriptionService? subscriptionService,
  bool skipOnboarding = true,
  String userName = 'Fadil',
}) {
  return ProviderScope(
    overrides: [
      lessonRepositoryProvider.overrideWithValue(
        repository ?? FakeLessonRepository(),
      ),
      subscriptionServiceProvider.overrideWithValue(
        subscriptionService ?? FakeSubscriptionService(),
      ),
      // Sebagian besar test menguji layar setelah onboarding, jadi preferensinya
      // dianggap sudah terisi. Test onboarding sendiri memakai skipOnboarding: false.
      if (skipOnboarding)
        onboardingPreferencesProvider.overrideWith(
          (ref) async => OnboardingPreferences(
            name: userName,
            goal: LearningGoal.culture,
            dailyTarget: DailyTarget.steady,
            isCompleted: true,
          ),
        ),
      if (now != null) nowProvider.overrideWithValue(() => now),
    ],
    child: DilSenseiApp(router: createAppRouter()),
  );
}

/// Menunggu data provider tanpa `pumpAndSettle`, karena skeleton loading
/// memakai animasi berulang yang tidak pernah settle.
Future<void> pumpUntilLoaded(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 16));
}

/// Membuka paywall lewat alur nyata: tap modul premium di HomeScreen.
Future<void> openPaywallFromHome(WidgetTester tester) async {
  await tester.pumpWidget(buildTestApp());
  await pumpUntilLoaded(tester);

  await tester.tap(find.text('Angka & Jam'));
  await tester.pumpAndSettle();
}
