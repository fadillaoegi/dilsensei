import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/services/day_parts.dart';

/// Sapaan pengguna di kiri, indikator streak di kanan.
///
/// Sapaannya mengikuti waktu setempat: Ohayou pada pagi, Konnichiwa pada siang
/// dan sore, Konbanwa pada malam.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.userName,
    required this.streakDays,
    required this.dayPart,
    super.key,
  });

  final String userName;
  final int streakDays;
  final DayPart dayPart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(l10n),
                style: textTheme.headlineMedium?.copyWith(
                  color: context.palette.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(_subtitle(l10n), style: textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _StreakIndicator(days: streakDays),
      ],
    );
  }

  /// Bahasa Jepang hanya punya tiga sapaan waktu, jadi siang dan sore sama-sama
  /// memakai Konnichiwa. Yang membedakan keduanya adalah subjudulnya.
  String _greeting(AppL10n l10n) => switch (dayPart) {
    DayPart.morning => l10n.homeGreetingMorning(userName),
    DayPart.midday => l10n.homeGreetingMidday(userName),
    DayPart.afternoon => l10n.homeGreetingAfternoon(userName),
    DayPart.evening => l10n.homeGreetingEvening(userName),
  };

  String _subtitle(AppL10n l10n) => switch (dayPart) {
    DayPart.morning => l10n.homeSubtitleMorning,
    DayPart.midday => l10n.homeSubtitleMidday,
    DayPart.afternoon => l10n.homeSubtitleAfternoon,
    DayPart.evening => l10n.homeSubtitleEvening,
  };
}

class _StreakIndicator extends StatelessWidget {
  const _StreakIndicator({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppL10n.of(context).homeStreakSemantics(days),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.palette.surfaceAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, size: 18, color: context.palette.primary),
            const SizedBox(width: 6),
            Text(
              '$days',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: context.palette.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
