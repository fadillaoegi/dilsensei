import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'analytics_service.dart';

/// Implementasi analytics di atas Firebase Analytics.
///
/// Seluruh kegagalan ditelan: analytics tidak pernah boleh menjatuhkan app atau
/// menghalangi pengguna berlatih.
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService({FirebaseAnalytics? analytics})
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> initialize() async {
    try {
      // Pengumpulan hanya dinyalakan di rilis; saat pengembangan datanya justru
      // mengotori laporan.
      await _analytics.setAnalyticsCollectionEnabled(kReleaseMode);
    } on Object catch (error) {
      debugPrint('ANALYTICS: gagal inisialisasi: $error');
    }
  }

  @override
  Future<void> log(
    AnalyticsEvent event, {
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: event.name, parameters: parameters);
    } on Object catch (error) {
      debugPrint('ANALYTICS: gagal mencatat ${event.name}: $error');
    }
  }

  @override
  Future<void> setCurrentScreen(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } on Object catch (error) {
      debugPrint('ANALYTICS: gagal mencatat layar $screenName: $error');
    }
  }
}

/// Analytics yang tidak melakukan apa pun.
///
/// Dipakai saat Firebase tidak tersedia dan pada seluruh test, sehingga test
/// tidak pernah menyentuh layanan luar.
class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> log(
    AnalyticsEvent event, {
    Map<String, Object>? parameters,
  }) async {}

  @override
  Future<void> setCurrentScreen(String screenName) async {}
}
