import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/lesson_module.dart';

/// Hero Card "Modul Hari Ini".
class TodayModuleCard extends StatelessWidget {
  const TodayModuleCard({
    required this.module,
    required this.onStart,
    super.key,
  });

  final LessonModule module;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
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
                  color: AppColors.primary.withValues(alpha: 0.05),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardLabel(text: 'MODUL HARI INI'),
                const SizedBox(height: 16),
                Text(
                  module.title,
                  style: textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(module.subtitle, style: textTheme.bodyMedium),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onStart,
                  child: Text('Mulai Sesi (${module.durationMinutes} Menit)'),
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
        color: AppColors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
