import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/monetization/monetization_providers.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/grammar_pattern.dart';
import '../../domain/entities/learning_progress.dart';
import '../../domain/services/pattern_insights.dart';
import '../providers/progress_controller.dart';

/// Peta kelemahan plus riwayat perkembangan.
///
/// Peringkatnya bukan sekadar jumlah kesalahan: kesalahan lama memudar dan
/// jawaban benar tapi lambat tetap dihitung, karena refleks berarti cepat.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  /// Jumlah pola yang terlihat tanpa premium.
  static const freePatternPreview = 1;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final progress = ref.watch(progressControllerProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final insights = ref.watch(patternInsightsProvider);
    final textTheme = Theme.of(context).textTheme;

    final needsWork = insights
        .where((insight) => insight.weakness != PatternWeakness.none)
        .toList(growable: false);
    final strong = insights
        .where((insight) => insight.weakness == PatternWeakness.none)
        .toList(growable: false);
    final hasData = insights.isNotEmpty || progress.recentSessions.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.insightsTitle)),
      body: SafeArea(
        child: !hasData
            ? const _EmptyInsights()
            : ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                children: [
                  _SummaryStrip(progress: progress),
                  const SizedBox(height: 32),
                  Text(
                    l10n.insightsPatternsTitle,
                    style: textTheme.titleLarge?.copyWith(
                      color: context.palette.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.insightsPatternsSubtitle,
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  if (needsWork.isEmpty)
                    Text(l10n.insightsNoPatterns, style: textTheme.bodyMedium)
                  else
                    for (final insight in _visible(needsWork, isPremium))
                      _PatternRow(insight: insight),
                  if (!isPremium && needsWork.length > freePatternPreview) ...[
                    const SizedBox(height: 8),
                    _LockedNotice(
                      hiddenCount: needsWork.length - freePatternPreview,
                      onUpgrade: () => context.push(AppRoutes.paywall),
                    ),
                  ],
                  if (isPremium && strong.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text(
                      l10n.insightsStrongTitle,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final insight in strong) _PatternRow(insight: insight),
                  ],
                  const SizedBox(height: 36),
                  Text(
                    l10n.insightsProgressTitle,
                    style: textTheme.titleLarge?.copyWith(
                      color: context.palette.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!isPremium)
                    _LockedNotice(
                      hiddenCount: progress.recentSessions.length,
                      label: l10n.insightsHistoryLocked,
                      onUpgrade: () => context.push(AppRoutes.paywall),
                    )
                  else if (progress.recentSessions.isEmpty)
                    Text(l10n.insightsHistoryEmpty, style: textTheme.bodyMedium)
                  else
                    _HistoryList(records: progress.recentSessions),
                ],
              ),
      ),
    );
  }

  List<PatternInsight> _visible(List<PatternInsight> all, bool isPremium) {
    return isPremium
        ? all
        : all.take(freePatternPreview).toList(growable: false);
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.progress});

  final LearningProgress progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatTile(
          label: AppL10n.of(context).insightsTotalSessions,
          value: '${progress.totalSessions}',
        ),
        const SizedBox(width: 12),
        _StatTile(
          label: AppL10n.of(context).insightsBestScore,
          value: '${progress.bestReflexScore}',
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.palette.primary.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: textTheme.bodySmall),
            const SizedBox(height: 6),
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                color: context.palette.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Satu baris pola: nama, alasan, dan bilah penguasaan.
class _PatternRow extends StatelessWidget {
  const _PatternRow({required this.insight});

  final PatternInsight insight;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final textTheme = Theme.of(context).textTheme;

    final reason = switch (insight.weakness) {
      PatternWeakness.accuracy => l10n.insightsReasonAccuracy(
        insight.missCount,
      ),
      PatternWeakness.speed => l10n.insightsReasonSlow(insight.slowCount),
      PatternWeakness.none => l10n.insightsReasonSolid,
    };

    final barColor = switch (insight.weakness) {
      PatternWeakness.accuracy => context.palette.error.withValues(alpha: 0.65),
      PatternWeakness.speed => LessonAccents.slow,
      PatternWeakness.none => context.palette.primary,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  GrammarPatterns.labelOf(l10n, insight.patternId),
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                reason,
                style: textTheme.labelMedium?.copyWith(
                  color: context.palette.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.insightsMastery((insight.mastery * 100).round()),
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: insight.mastery),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: context.palette.surfaceAccent,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Aksen khusus untuk penanda "lambat", bukan salah.
abstract final class LessonAccents {
  static const slow = Color(0xFFB08968);
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.records});

  final List<SessionRecord> records;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        for (final record in records)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.palette.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatDate(record.date),
                      style: textTheme.bodyMedium?.copyWith(
                        color: context.palette.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    AppL10n.of(
                      context,
                    ).insightsAccuracy((record.accuracy * 100).round()),
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '${record.reflexScore}',
                    style: textTheme.titleMedium?.copyWith(
                      color: context.palette.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _LockedNotice extends StatelessWidget {
  const _LockedNotice({
    required this.hiddenCount,
    required this.onUpgrade,
    this.label,
  });

  final int hiddenCount;
  final String? label;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.palette.surfaceAccent.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.palette.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_rounded,
                size: 18,
                color: context.palette.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label ?? l10n.insightsHiddenPatterns(hiddenCount),
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.palette.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onUpgrade, child: Text(l10n.commonSeePro)),
        ],
      ),
    );
  }
}

class _EmptyInsights extends StatelessWidget {
  const _EmptyInsights();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppL10n.of(context).insightsEmptyTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              AppL10n.of(context).insightsEmptyBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
