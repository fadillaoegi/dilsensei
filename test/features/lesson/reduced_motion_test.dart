import 'dart:io';

import 'package:dilsensei/core/localization/language_controller.dart';
import 'package:dilsensei/core/theme/app_motion.dart';
import 'package:dilsensei/features/lesson/presentation/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/lesson_test_fixtures.dart';

/// Membungkus [child] dengan setelan "kurangi gerak" menyala atau mati.
Widget _withMotion({required bool reduced, required Widget child}) {
  return MediaQuery(
    data: MediaQueryData(disableAnimations: reduced),
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('helper motion', () {
    testWidgets('durasi menjadi nol saat gerak dikurangi', (tester) async {
      Duration? resolved;

      await tester.pumpWidget(
        _withMotion(
          reduced: true,
          child: Builder(
            builder: (context) {
              resolved = context.motion(const Duration(milliseconds: 400));

              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved, Duration.zero);
    });

    testWidgets('durasi tetap utuh saat gerak normal', (tester) async {
      Duration? resolved;
      bool? prefers;

      await tester.pumpWidget(
        _withMotion(
          reduced: false,
          child: Builder(
            builder: (context) {
              resolved = context.motion(const Duration(milliseconds: 400));
              prefers = context.prefersReducedMotion;

              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved, const Duration(milliseconds: 400));
      expect(prefers, isFalse);
    });
  });

  group('shimmer', () {
    testWidgets('denyut berhenti saat gerak dikurangi', (tester) async {
      await tester.pumpWidget(
        _withMotion(reduced: true, child: const ShimmerBox(height: 40)),
      );
      await tester.pump();

      // Tanpa animasi berjalan, tidak ada frame baru yang dijadwalkan.
      expect(tester.binding.hasScheduledFrame, isFalse);

      // Skeletonnya tetap tampil, hanya gerakannya yang hilang, dan dibekukan
      // pada keadaan paling terang agar tidak tampak dinonaktifkan.
      expect(find.byType(ShimmerBox), findsOneWidget);

      final fade = tester.widget<FadeTransition>(
        find
            .descendant(
              of: find.byType(ShimmerBox),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(fade.opacity.value, 1.0);
    });

    testWidgets('denyut berjalan saat gerak normal', (tester) async {
      await tester.pumpWidget(
        _withMotion(reduced: false, child: const ShimmerBox(height: 40)),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.binding.hasScheduledFrame, isTrue);
    });
  });

  group('animasi layar', () {
    testWidgets('onboarding langsung menampilkan keadaan akhir', (
      tester,
    ) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(
        buildTestApp(
          language: AppLanguage.english,
          skipOnboarding: false,
          reducedMotion: true,
        ),
      );
      await tester.pump();
      await tester.pump();

      // Setiap animasi berbasis durasi di layar ini harus berdurasi nol.
      final builders = tester
          .widgetList<TweenAnimationBuilder<double>>(
            find.byType(TweenAnimationBuilder<double>),
          )
          .toList();

      expect(builders, isNotEmpty, reason: 'onboarding punya animasi');
      for (final builder in builders) {
        expect(builder.duration, Duration.zero);
      }
    });

    testWidgets('Home selesai memuat tanpa frame animasi tersisa', (
      tester,
    ) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(
        buildTestApp(language: AppLanguage.english, reducedMotion: true),
      );
      await pumpUntilLoaded(tester);

      expect(find.text('Start session (5 min)'), findsOneWidget);

      // Tidak ada animasi berdurasi bukan nol yang tersisa di layar.
      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      for (final container in containers) {
        expect(container.duration, Duration.zero);
      }
    });
  });

  group('penjaga reduced motion', () {
    test('setiap berkas beranimasi menghormati setelan kurangi gerak', () {
      // Menambahkan animasi tanpa menghormati setelan ini adalah cacat
      // aksesibilitas yang tidak terlihat sampai seseorang menyalakannya di
      // perangkatnya sendiri. Penjaga ini menutup celah itu.
      final animationPattern = RegExp(
        r'AnimatedContainer|TweenAnimationBuilder|AnimationController|'
        r'AnimatedOpacity|AnimatedSwitcher|AnimatedSize|'
        r'AnimatedDefaultTextStyle|AnimatedAlign|AnimatedPadding',
      );
      final respectPattern = RegExp(
        r'context\.motion\(|prefersReducedMotion|maybeDisableAnimationsOf',
      );

      final offenders = <String>[];

      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;

        final source = entity.readAsStringSync();
        if (!animationPattern.hasMatch(source)) continue;
        if (respectPattern.hasMatch(source)) continue;

        offenders.add(entity.path);
      }

      expect(
        offenders,
        isEmpty,
        reason:
            'berkas berikut beranimasi tanpa menghormati "kurangi gerak"; '
            'pakai context.motion(...) untuk durasinya: '
            '${offenders.join(', ')}',
      );
    });
  });
}
