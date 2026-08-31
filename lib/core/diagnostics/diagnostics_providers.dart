import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../monetization/dev_premium_override.dart';
import 'diagnostics_log.dart';

/// Sakelar layar diagnostik.
///
/// Aktif pada build debug atau profile, dan dapat dinyalakan pada build rilis
/// dengan `--dart-define=ENABLE_DIAGNOSTICS=true`. Itu yang memungkinkan
/// memasang APK rilis untuk menguji pembelian sungguhan sambil tetap bisa
/// membaca penyebab kegagalannya — tanpa membuat layar ini ikut ke rilis publik.
abstract final class DiagnosticsConfig {
  static const _flag = String.fromEnvironment('ENABLE_DIAGNOSTICS');

  static bool get isForcedOn => _flag.toLowerCase() == 'true';

  static bool get isEnabled => DevTools.isEnabled || isForcedOn;
}

/// Satu log untuk seluruh app, hidup selama app berjalan.
final diagnosticsLogProvider = Provider<DiagnosticsLog>((ref) {
  final log = DiagnosticsLog();
  ref.onDispose(log.dispose);

  return log;
});

/// Gerbang render layar diagnostik; dapat ditimpa test.
final diagnosticsEnabledProvider = Provider<bool>(
  (ref) => DiagnosticsConfig.isEnabled,
);
