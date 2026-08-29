import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/lesson_module.dart';

/// Hero Card "Modul Hari Ini".
class TodayModuleCard extends StatelessWidget {
  const TodayModuleCard({
    required this.module,
    required this.title,
    required this.subtitle,
    required this.onStart,
    super.key,
  });

  final LessonModule module;

  /// Judul dan subtitle sudah diselesaikan sesuai bahasa aktif.
  final String title;
  final String subtitle;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: context.palette.surfaceAccent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.palette.primary.withValues(alpha: 0.12),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -28,
            child: ExcludeSemantics(
              child: Text(
                module.backgroundChar,
                style: textTheme.displayLarge?.copyWith(
                  fontSize: 120,
                  height: 1,
                  color: context.palette.primary.withValues(alpha: 0.05),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardLabel(text: l10n.homeTodayLabel),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: textTheme.headlineSmall?.copyWith(
                    color: context.palette.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(subtitle, style: textTheme.bodyMedium),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onStart,
                  child: Text(l10n.homeStartSession(module.durationMinutes)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardLabel extends StatelessWidget {
  const _CardLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.palette.surfaceCard.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: context.palette.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
