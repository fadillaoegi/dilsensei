import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/grammar_pattern.dart';
import '../../domain/services/drill_session_engine.dart';
import 'session_complete_burst.dart';

/// Ringkasan setelah sesi tuntas: skor refleks dan peta pola yang masih lemah.
class SessionSummaryView extends StatelessWidget {
  const SessionSummaryView({
    required this.summary,
    required this.onClose,
    required this.onDrillWeakPatterns,
    this.onOpenRecord,
    super.key,
  });

  final SessionSummary summary;
  final VoidCallback onClose;

  /// Null bila tidak ada pola lemah yang bisa dilatih ulang.
  final VoidCallback? onDrillWeakPatterns;

  /// Terisi hanya bila seluruh modul sudah tuntas, sehingga Training Record siap.
  final VoidCallback? onOpenRecord;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final textTheme = Theme.of(context).textTheme;
    final hasWeakPatterns = summary.weakPatterns.isNotEmpty;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: SessionCompleteBurst()),
                const SizedBox(height: 20),
                Text(l10n.summaryTitle, style: textTheme.bodyMedium),
                const SizedBox(height: 4),
                _ReflexScore(score: summary.reflexScore),
                const SizedBox(height: 28),
                Row(
                  children: [
                    _MetricTile(
                      label: l10n.summaryFirstTry,
                      value:
                          '${summary.firstTryCorrect}/${summary.plannedCount}',
                    ),
                    const SizedBox(width: 12),
                    _MetricTile(
                      label: l10n.summaryResponseTime,
                      value: _formatDuration(l10n, summary.medianResponseTime),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  hasWeakPatterns ? l10n.summaryWeakTitle : l10n.summaryClean,
                  style: textTheme.titleLarge?.copyWith(
                    color: context.palette.primary,
                  ),
                ),
                const SizedBox(height: 12),
                if (!hasWeakPatterns)
                  Text(l10n.summaryCleanBody, style: textTheme.bodyMedium)
                else
                  for (final miss in summary.weakPatterns)
                    _PatternRow(
                      label: GrammarPatterns.labelOf(l10n, miss.patternId),
                      missCount: miss.missCount,
                      maxMissCount: summary.weakPatterns.first.missCount,
                    ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Column(
            children: [
              if (onOpenRecord != null) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: onOpenRecord,
                    icon: const Icon(Icons.workspace_premium_outlined),
                    label: Text(l10n.recordUnlockedCta),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (onDrillWeakPatterns != null)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onDrillWeakPatterns,
                    child: Text(l10n.summaryDrillWeak),
                  ),
                ),
              if (onDrillWeakPatterns != null) const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: onDrillWeakPatterns == null
                    ? ElevatedButton(
                        onPressed: onClose,
                        child: Text(l10n.commonDone),
                      )
                    : OutlinedButton(
                        onPressed: onClose,
                        child: Text(l10n.commonDone),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _formatDuration(AppL10n l10n, Duration duration) {
    if (duration == Duration.zero) return l10n.summaryNoData;

    final seconds = duration.inMilliseconds / 1000;
    return l10n.summarySeconds(seconds.toStringAsFixed(1));
  }
}

class _ReflexScore extends StatelessWidget {
  const _ReflexScore({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(end: score.toDouble()),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => Text(
            '${value.round()}',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: context.palette.primary,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Flexible agar label tidak memaksa lebar pada ponsel sempit.
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              AppL10n.of(context).summaryReflexScore,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

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
              style: textTheme.titleLarge?.copyWith(
                color: context.palette.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Satu baris pola lemah dengan bilah proporsional terhadap pola terburuk.
class _PatternRow extends StatelessWidget {
  const _PatternRow({
    required this.label,
    required this.missCount,
    required this.maxMissCount,
  });

  final String label;
  final int missCount;
  final int maxMissCount;

  @override
  Widget build(BuildContext context) {
    final ratio = maxMissCount == 0 ? 0.0 : missCount / maxMissCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                AppL10n.of(context).insightsMissCount(missCount),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: context.palette.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: ratio),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: context.palette.surfaceAccent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.palette.error.withValues(alpha: 0.65),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
