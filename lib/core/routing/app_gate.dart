import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/lesson/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/providers/onboarding_controller.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../theme/app_theme.dart';

/// Menentukan layar pertama: onboarding untuk pengguna baru, Home untuk yang
/// sudah menyelesaikannya.
///
/// Keputusan ditahan sampai preferensi selesai dibaca agar tidak berkedip.
class AppGate extends ConsumerWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(onboardingPreferencesProvider);

    return preferences.when(
      loading: () => const _SplashView(),
      // Gagal membaca preferensi tidak boleh mengunci app; anggap pengguna baru.
      error: (error, _) => const OnboardingScreen(),
      data: (value) =>
          value.isCompleted ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}

/// Lanjutan visual dari splash native.
///
/// Logo, ukuran, dan warna latarnya sengaja sama dengan splash native supaya
/// peralihan dari splash sistem ke Flutter tidak terlihat berkedip.
class _SplashView extends StatelessWidget {
  const _SplashView();

  static const logoAsset = 'assets/icon/splash_logo.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.surface,
      body: Center(
        child: Image(
          image: AssetImage(logoAsset),
          width: 192,
          height: 192,
          // Splash tidak perlu dibacakan pembaca layar.
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}
