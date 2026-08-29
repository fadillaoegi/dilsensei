import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytics_service.dart';
import 'firebase_analytics_service.dart';

/// Menandai apakah Firebase berhasil disiapkan.
///
/// Diisi oleh [initializeFirebase] sebelum `runApp`, sehingga provider bisa
/// memilih implementasi tanpa perlu menunggu Future.
bool _isFirebaseReady = false;

/// Menyiapkan Firebase dan menelan kegagalannya.
///
/// App harus tetap bisa dipakai walau Firebase gagal — misalnya bila
/// `google-services.json` belum ada pada salinan repo orang lain.
Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp();
    _isFirebaseReady = true;
  } on Object catch (error) {
    _isFirebaseReady = false;
    debugPrint('FIREBASE: tidak tersedia, analytics dimatikan: $error');
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  if (!_isFirebaseReady) return const NoopAnalyticsService();

  final service = FirebaseAnalyticsService();
  service.initialize();

  return service;
});
