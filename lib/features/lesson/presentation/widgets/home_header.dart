import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Sapaan pengguna di kiri, indikator streak di kanan.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.userName,
    required this.streakDays,
    super.key,
  });

  final String userName;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Konnichiwa, $userName!',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Waktunya melatih memori ototmu',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _StreakIndicator(days: streakDays),
      ],
    );
  }
}

class _StreakIndicator extends StatelessWidget {
  const _StreakIndicator({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Streak $days hari',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.eco, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              '$days',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
