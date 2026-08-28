import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/lesson_module.dart';

/// Item daftar pada section "Peta Belajarmu".
class LessonListItem extends StatelessWidget {
  const LessonListItem({
    required this.module,
    required this.onTap,
    this.isUnlocked = false,
    super.key,
  });

  /// Aksen kalem untuk penanda konten premium.
  static const lockAccent = Color(0xFFB08968);

  final LessonModule module;
  final VoidCallback onTap;

  /// True bila entitlement premium aktif, sehingga kunci tidak perlu tampil.
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      module.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _TrailingIndicator(module: module, isUnlocked: isUnlocked),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrailingIndicator extends StatelessWidget {
  const _TrailingIndicator({required this.module, required this.isUnlocked});

  final LessonModule module;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    if (module.isPremium && !isUnlocked) {
      return Semantics(
        label: 'Modul premium, perlu langganan',
        child: const Icon(
          Icons.lock_rounded,
          size: 20,
          color: LessonListItem.lockAccent,
        ),
      );
    }

    return Text(
      '${module.durationMinutes} mnt',
      style: Theme.of(
        context,
      ).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
    );
  }
}
