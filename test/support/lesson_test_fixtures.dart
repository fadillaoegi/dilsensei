import 'dart:async';

import 'package:dilsensei/core/analytics/analytics_providers.dart';
import 'package:dilsensei/core/analytics/analytics_service.dart';
import 'package:dilsensei/core/localization/language_controller.dart';
import 'package:dilsensei/core/diagnostics/diagnostics_log.dart';
import 'package:dilsensei/core/diagnostics/diagnostics_providers.dart';
import 'package:dilsensei/core/monetization/dev_premium_override.dart';
import 'package:dilsensei/core/update/app_update_service.dart';
import 'package:dilsensei/core/update/play_app_update_service.dart';
import 'package:dilsensei/core/update/update_providers.dart';
import 'package:dilsensei/core/theme/theme_mode_controller.dart';
import 'package:dilsensei/core/monetization/domain/subscription_models.dart';
import 'package:dilsensei/core/monetization/domain/subscription_service.dart';
import 'package:dilsensei/core/monetization/monetization_providers.dart';
import 'package:dilsensei/core/routing/app_router.dart';
import 'package:dilsensei/features/lesson/domain/entities/drill_item.dart';
import 'package:dilsensei/features/lesson/domain/entities/lesson_module.dart';
import 'package:dilsensei/features/lesson/domain/repositories/lesson_repository.dart';
import 'package:dilsensei/features/lesson/presentation/providers/lesson_providers.dart';
import 'package:dilsensei/features/lesson/domain/services/reminder_scheduler.dart';
import 'package:dilsensei/features/lesson/presentation/providers/progress_controller.dart';
import 'package:dilsensei/features/lesson/presentation/providers/reminder_controller.dart';
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

/// Butir dua bahasa untuk menguji resolusi prompt sesuai locale.
const testBilingualDrillItems = <DrillItem>[
  DrillItem(
    id: 'drill-bilingual',
    moduleId: 'free-1',
    prompt: 'Saya pergi ke sekolah setiap hari.',
    promptEn: 'I go to school every day.',
    answerTokens: ['まいにち', 'がっこう', 'に', 'いきます'],
    distractorTokens: ['を', 'で'],
    patternIds: ['particle_place'],
    note: 'Tujuan gerak memakai に.',
    noteEn: 'Movement targets take ni.',
  ),
];

/// Butir untuk menguji tipe isi partikel dan transformasi bentuk.
const testMixedDrillItems = <DrillItem>[
  DrillItem(
    id: 'drill-particle',
    moduleId: 'free-1',
    type: DrillType.chooseParticle,
    prompt: 'Saya pulang ke rumah.',
    questionText: 'わたしは うち＿ かえります',
    answerTokens: ['に'],
    distractorTokens: ['を', 'で', 'が'],
    patternIds: ['particle_place'],
    note: 'Tujuan gerak memakai に.',
  ),
  DrillItem(
    id: 'drill-transform',
    moduleId: 'free-1',
    type: DrillType.transformForm,
    prompt: 'Tidak minum.',
    questionText: 'のみます',
    instruction: 'Ubah ke bentuk negatif sopan',
    answerTokens: ['のみません'],
    distractorTokens: ['のみました', 'のみたい', 'のみましょう'],
    patternIds: ['negative_form'],
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
    this.purchaseThrows = false,
    this.restoreThrows = false,
  });

  final List<SubscriptionPlan> plans;
  final bool isPremium;
  final PurchaseResult purchaseResult;
  final PurchaseResult restoreResult;
  final bool plansThrow;

  /// Menirukan galat yang tidak diubah menjadi hasil, misalnya
  /// `UnsupportedPlatformException` dari SDK RevenueCat di platform yang tidak
  /// mendukung pembelian. Galat semacam ini pernah membuat tombol paywall mati
  /// permanen karena penanda "sedang diproses" tidak pernah turun.
  final bool purchaseThrows;
  final bool restoreThrows;

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
    if (purchaseThrows) throw Exception('platform tidak mendukung pembelian');
    if (purchaseResult.isSuccess) {
      _controller.add(const PremiumStatus(isPremium: true));
    }
    return purchaseResult;
  }

  @override
  Future<PurchaseResult> restorePurchases() async {
    restoreCallCount++;
    if (restoreThrows) throw Exception('platform tidak mendukung restore');
    if (restoreResult.isSuccess) {
      _controller.add(const PremiumStatus(isPremium: true));
    }
    return restoreResult;
  }
}

const testPlans = <SubscriptionPlan>[
  SubscriptionPlan(
    id: 'monthly',
    priceLabel: 'Rp 49.000',
    period: BillingPeriod.monthly,
    trialDays: 3,
    isRecommended: true,
  ),
  SubscriptionPlan(
    id: 'lifetime',
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
  AppLanguage language = AppLanguage.indonesian,
  ReminderScheduler? reminderScheduler,
  AnalyticsService? analytics,
  AppThemeMode themeMode = AppThemeMode.light,
  bool? devToolsEnabled,
  AppUpdateService? updateService,
  bool? diagnosticsEnabled,
  DiagnosticsLog? diagnosticsLog,
  bool reducedMotion = false,
  bool useStoredPreferences = false,
}) {
  return ProviderScope(
    overrides: [
      lessonRepositoryProvider.overrideWithValue(
        repository ?? FakeLessonRepository(),
      ),
      subscriptionServiceProvider.overrideWithValue(
        subscriptionService ?? FakeSubscriptionService(),
      ),
      // Bahasa dikunci agar test tidak bergantung pada default produksi.
      // Test lama ditulis dengan teks Indonesia; test bahasa Inggris ada di
      // test/core/localization_test.dart.
      languageControllerProvider.overrideWith(
        (ref) => _FixedLanguageController(language),
      ),
      // Sebagian besar test menguji layar setelah onboarding, jadi preferensinya
      // dianggap sudah terisi. Test onboarding sendiri memakai skipOnboarding: false.
      // useStoredPreferences membiarkan provider membaca SharedPreferences yang
      // sudah diisi test, sehingga alur simpan-lalu-baca benar-benar teruji.
      if (skipOnboarding && !useStoredPreferences)
        onboardingPreferencesProvider.overrideWith(
          (ref) async => OnboardingPreferences(
            name: userName,
            goal: LearningGoal.culture,
            dailyTarget: DailyTarget.steady,
            isCompleted: true,
          ),
        ),
      // Tema dikunci ke terang kecuali test memintanya lain, supaya asersi
      // warna pada test lama tidak bergantung setelan perangkat penguji.
      themeModeControllerProvider.overrideWith(
        (ref) => ThemeModeController(
          dataSource: const ThemeModeLocalDataSource(),
          initial: themeMode,
        ),
      ),
      // Gerbang perkakas dev dapat ditirukan supaya perilaku build release
      // bisa diuji; kDebugMode sendiri adalah konstanta.
      if (devToolsEnabled != null)
        devToolsEnabledProvider.overrideWithValue(devToolsEnabled),
      if (diagnosticsEnabled != null)
        diagnosticsEnabledProvider.overrideWithValue(diagnosticsEnabled),
      if (diagnosticsLog != null)
        diagnosticsLogProvider.overrideWithValue(diagnosticsLog),
      // Layanan pembaruan selalu difake: test tidak boleh menyentuh Play Core.
      appUpdateServiceProvider.overrideWithValue(
        updateService ?? const UnavailableAppUpdateService(),
      ),
      // Analytics selalu difake: test tidak boleh menyentuh Firebase.
      analyticsServiceProvider.overrideWithValue(
        analytics ?? FakeAnalyticsService(),
      ),
      // Penjadwal pengingat selalu difake: test tidak boleh menyentuh
      // notifikasi perangkat.
      reminderSchedulerProvider.overrideWithValue(
        reminderScheduler ?? _NoopReminderScheduler(),
      ),
      // Jam dikunci ke tengah hari supaya sapaan Home deterministik: sapaan
      // sekarang mengikuti waktu, dan test tidak boleh bergantung jam nyata.
      nowProvider.overrideWithValue(() => now ?? DateTime(2026, 9, 1, 12)),
    ],
    child: reducedMotion
        // Menirukan setelan aksesibilitas "kurangi gerak" milik sistem.
        ? MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: DilSenseiApp(router: createAppRouter()),
          )
        : DilSenseiApp(router: createAppRouter()),
  );
}

/// Controller bahasa yang tidak membaca maupun menulis penyimpanan, supaya
/// locale test stabil dan tidak bergantung SharedPreferences.
class _FixedLanguageController extends LanguageController {
  _FixedLanguageController(AppLanguage language)
    : super(dataSource: const LanguageLocalDataSource(), initial: language);

  @override
  Future<void> select(AppLanguage language) async {
    state = language;
  }
}

/// Menunggu data provider tanpa `pumpAndSettle`, karena skeleton loading
/// memakai animasi berulang yang tidak pernah settle.
Future<void> pumpUntilLoaded(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 16));
}

/// Memberi viewport test setinggi ponsel sungguhan.
///
/// Home kini memuat header, hero card, pintu masuk bagan huruf, dan daftar
/// modul — lebih tinggi dari 600 piksel bawaan `flutter_test`, sehingga item
/// daftar berada di luar layar dan tidak bisa diketuk.
void usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// Mengetuk sebuah modul pada daftar Home.
///
/// `ensureVisible` tidak menolong karena Scrollable terdekat adalah ListView
/// daftar modul yang sengaja tidak bisa digulir; yang harus digulir adalah
/// SingleChildScrollView di luarnya.
Future<void> tapModule(WidgetTester tester, String title) async {
  final finder = find.text(title);
  final scrollView = find.byType(SingleChildScrollView).first;

  for (var attempt = 0; attempt < 8; attempt++) {
    final viewportHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final rect = tester.getRect(finder);
    if (rect.top >= 0 && rect.bottom <= viewportHeight) break;

    await tester.drag(
      scrollView,
      Offset(0, -(rect.bottom - viewportHeight + 120)),
    );
    await tester.pumpAndSettle();
  }

  await tester.tap(finder);
}

/// Membuka paywall lewat alur nyata: tap modul premium di HomeScreen.
Future<void> openPaywallFromHome(WidgetTester tester) async {
  usePhoneViewport(tester);
  await tester.pumpWidget(buildTestApp());
  await pumpUntilLoaded(tester);

  await tapModule(tester, 'Angka & Jam');
  await tester.pumpAndSettle();
}

/// Penjadwal pengingat yang tidak melakukan apa pun, untuk test yang tidak
/// sedang menguji pengingat.
class _NoopReminderScheduler implements ReminderScheduler {
  @override
  Future<void> cancel() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> schedule(ReminderContent content) async {}
}

/// Satu peristiwa analytics yang tercatat.
class LoggedAnalyticsEvent {
  const LoggedAnalyticsEvent(this.event, this.parameters);

  final AnalyticsEvent event;
  final Map<String, Object>? parameters;
}

/// Analytics palsu yang menyimpan peristiwa untuk diperiksa test.
class FakeAnalyticsService implements AnalyticsService {
  final List<LoggedAnalyticsEvent> entries = <LoggedAnalyticsEvent>[];
  final List<String> screens = <String>[];

  /// Nama peristiwa yang tercatat, memudahkan asersi.
  List<String> get names =>
      entries.map((entry) => entry.event.name).toList(growable: false);

  @override
  Future<void> initialize() async {}

  @override
  Future<void> log(
    AnalyticsEvent event, {
    Map<String, Object>? parameters,
  }) async {
    entries.add(LoggedAnalyticsEvent(event, parameters));
  }

  @override
  Future<void> setCurrentScreen(String screenName) async {
    screens.add(screenName);
  }
}

/// Layanan pembaruan palsu yang dapat diatur hasilnya.
class FakeAppUpdateService implements AppUpdateService {
  FakeAppUpdateService({
    this.info = const AppUpdateInfo.unknown(),
    this.startResult = UpdateStartResult.started,
    this.installSucceeds = true,
  });

  final AppUpdateInfo info;
  final UpdateStartResult startResult;
  final bool installSucceeds;

  int checkCount = 0;
  int startCount = 0;
  int installCount = 0;

  @override
  Future<AppUpdateInfo> check() async {
    checkCount++;

    return info;
  }

  @override
  Future<UpdateStartResult> startFlexibleUpdate() async {
    startCount++;

    return startResult;
  }

  @override
  Future<bool> completeFlexibleUpdate() async {
    installCount++;

    return installSucceeds;
  }
}

/// Pembaruan yang tersedia dan bisa diunduh dari dalam app.
const availableUpdate = AppUpdateInfo(
  availability: UpdateAvailability.available,
  isFlexibleAllowed: true,
  availableVersionCode: 7,
);

/// Menggulir daftar Pengaturan sampai [text] benar-benar terbangun dan terlihat.
///
/// `scrollUntilVisible` terbukti rapuh di layar ini: ListView-nya lazy dan
/// daftarnya bertambah panjang setiap kali ada bagian pengaturan baru, sehingga
/// jarak gulir yang dipatok selalu basi. Helper ini menggulir bertahap sampai
/// widgetnya ada, lalu memastikannya masuk viewport.
Future<void> scrollSettingsTo(
  WidgetTester tester,
  String text, {
  int maxSteps = 30,
}) async {
  final finder = find.text(text);

  // Selalu kembali ke puncak lebih dulu. Tanpa ini, memanggil helper dua kali
  // berurutan bisa gagal karena target kedua berada di atas posisi saat ini,
  // dan widgetnya sudah dilepas dari cache ListView.
  await tester.drag(find.byType(Scrollable).first, const Offset(0, 4000));
  await tester.pumpAndSettle();

  for (var step = 0; step < maxSteps; step++) {
    if (finder.evaluate().isNotEmpty) {
      await tester.ensureVisible(finder.first);
      await tester.pumpAndSettle();

      return;
    }

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
    await tester.pumpAndSettle();
  }

  throw StateError('tidak menemukan "$text" setelah menggulir Pengaturan');
}
