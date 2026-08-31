import 'package:flutter/material.dart';

/// Dukungan setelan "kurangi gerak" milik sistem.
///
/// Pengguna yang menyalakannya biasanya punya alasan medis — vertigo, migrain,
/// atau sensitivitas gerak. Karena itu animasi tidak boleh sekadar dipercepat,
/// tapi dihilangkan, sementara **hasil akhirnya tetap tampil**. Menghilangkan
/// informasinya justru menghukum pengguna yang butuh setelan itu.
extension AppMotionX on BuildContext {
  /// True bila sistem meminta gerak dikurangi.
  bool get prefersReducedMotion =>
      MediaQuery.maybeDisableAnimationsOf(this) ?? false;

  /// Durasi animasi yang menghormati setelan tersebut.
  ///
  /// Mengembalikan [Duration.zero] saat gerak dikurangi, sehingga widget seperti
  /// `AnimatedContainer` dan `TweenAnimationBuilder` langsung berada di keadaan
  /// akhirnya alih-alih bergerak menuju ke sana.
  Duration motion(Duration duration) =>
      prefersReducedMotion ? Duration.zero : duration;
}
