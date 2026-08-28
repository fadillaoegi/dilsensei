import 'package:dilsensei/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final theme = AppTheme.light;

  test('palet mengikuti design system Organic Minimalism', () {
    expect(theme.scaffoldBackgroundColor, const Color(0xFFFCFCFC));
    expect(theme.colorScheme.primary, const Color(0xFF2D6A4F));
    expect(theme.colorScheme.secondary, const Color(0xFFD8F3DC));
    expect(theme.textTheme.bodyLarge?.color, const Color(0xFF1A1A1A));
    expect(theme.textTheme.bodyMedium?.color, const Color(0xFF666666));
  });

  test('heading memakai Space Grotesk yang dibundel', () {
    for (final style in <TextStyle?>[
      theme.textTheme.displaySmall,
      theme.textTheme.headlineMedium,
      theme.textTheme.titleLarge,
    ]) {
      expect(style?.fontFamily, 'Space Grotesk');
      expect(style?.fontWeight, FontWeight.w700);
    }
  });

  test('body memakai Plus Jakarta Sans yang dibundel', () {
    for (final style in <TextStyle?>[
      theme.textTheme.bodyLarge,
      theme.textTheme.bodySmall,
      theme.textTheme.titleMedium,
      theme.textTheme.labelSmall,
    ]) {
      expect(style?.fontFamily, 'Plus Jakarta Sans');
    }

    expect(theme.textTheme.bodyLarge?.fontFamily, isNot(contains('Inter')));
  });

  test('setiap gaya teks punya fallback aksara Jepang', () {
    final styles = <TextStyle?>[
      theme.textTheme.displaySmall,
      theme.textTheme.headlineMedium,
      theme.textTheme.bodyLarge,
      theme.textTheme.titleMedium,
      theme.textTheme.labelMedium,
    ];

    for (final style in styles) {
      expect(
        style?.fontFamilyFallback,
        contains('Noto Sans JP'),
        reason: 'aksara Jepang harus punya jalur render',
      );
    }
  });

  test('komponen mengikuti aturan sudut membulat dan tanpa elevasi', () {
    expect(theme.cardTheme.elevation, 0);
    expect(theme.appBarTheme.elevation, 0);

    final buttonShape =
        theme.elevatedButtonTheme.style?.shape?.resolve(<WidgetState>{})
            as RoundedRectangleBorder?;
    expect(
      buttonShape?.borderRadius,
      BorderRadius.circular(12),
      reason: 'radius 12 untuk button',
    );
  });
}
