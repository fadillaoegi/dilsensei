import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/analytics/analytics_providers.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/localization/language_controller.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/drill_item.dart';
import '../../domain/entities/grammar_pattern.dart';
import '../providers/drill_session_controller.dart';
import '../providers/certificate_providers.dart';
import '../providers/lesson_providers.dart';
import '../providers/progress_controller.dart';
import '../widgets/question_card.dart';
import '../widgets/session_summary_view.dart';
import '../widgets/shimmer_box.dart';
import '../widgets/token_chip.dart';

/// Layar sesi latihan untuk satu modul.
class DrillSessionScreen extends ConsumerWidget {
  const DrillSessionScreen({required this.moduleId, super.key});

  final String moduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(drillItemsProvider(moduleId));

    return Scaffold(
      body: SafeArea(
        child: itemsAsync.when(
          loading: () => const _SessionLoadingView(),
          error: (error, _) => _SessionErrorView(
            onRetry: () => ref.invalidate(drillItemsProvider(moduleId)),
          ),
          data: (items) => items.isEmpty
              ? const _SessionEmptyView()
              : _SessionBody(moduleId: moduleId),
        ),
      ),
    );
  }
}

class _SessionBody extends ConsumerWidget {
  const _SessionBody({required this.moduleId});

  final String moduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(languageControllerProvider).code;
    final state = ref.watch(drillSessionControllerProvider(moduleId));
    final controller = ref.read(
      drillSessionControllerProvider(moduleId).notifier,
    );

    // Catat progres tepat saat ringkasan pertama kali muncul, bukan tiap build.
    ref.listen(drillSessionControllerProvider(moduleId), (previous, next) {
      final summary = next.summary;
      if (previous?.summary == null && summary != null) {
        ref
            .read(analyticsServiceProvider)
            .log(
              AnalyticsEvent.sessionCompleted,
              parameters: <String, Object>{
                'reflex_score': summary.reflexScore,
                'planned_count': summary.plannedCount,
                'first_try_correct': summary.firstTryCorrect,
                'weak_patterns': summary.weakPatterns.length,
              },
            );
        ref
            .read(progressControllerProvider.notifier)
            .recordSession(summary, moduleId: moduleId);
      }
    });

    final summary = state.summary;
    if (summary != null) {
      final hasWeakPatterns =
          summary.weakPatterns.isNotEmpty &&
          controller
              .itemsForPatterns(
                summary.weakPatterns.map((miss) => miss.patternId).toSet(),
              )
              .isNotEmpty;

      final recordUnlocked =
          ref.watch(trainingRecordProvider).valueOrNull?.isUnlocked ?? false;

      return SessionSummaryView(
        summary: summary,
        onClose: () => Navigator.of(context).pop(),
        onOpenRecord: recordUnlocked
            ? () => context.push(AppRoutes.trainingRecord)
            : null,
        onDrillWeakPatterns: hasWeakPatterns
            ? () {
                ref
                    .read(analyticsServiceProvider)
                    .log(AnalyticsEvent.weakPatternDrillStarted);
                controller.restartWithWeakPatterns();
              }
            : null,
      );
    }

    final item = state.displayItem;
    if (item == null) {
      return const _SessionLoadingView();
    }

    return Column(
      children: [
        _SessionHeader(
          progress: state.session.progress,
          resolved: state.session.resolvedCount,
          total: state.session.plannedCount,
          onClose: () => Navigator.of(context).pop(),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                QuestionCard(
                  item: item,
                  selectedTokens: state.selectedTokens,
                  languageCode: languageCode,
                ),
                const SizedBox(height: 24),
                // Area jawaban tersusun hanya relevan untuk menyusun kalimat;
                // tipe pilihan sudah menampilkan jawabannya di kartu pertanyaan.
                if (item.type == DrillType.assembleSentence) ...[
                  AnswerCanvas(
                    tokens: state.selectedTokens,
                    isLocked: state.isShowingFeedback,
                    onRemoveAt: controller.removeTokenAt,
                  ),
                  const SizedBox(height: 24),
                ],
                _TokenBank(
                  item: item,
                  selectedTokens: state.selectedTokens,
                  isLocked: state.isShowingFeedback,
                  onSelect: controller.selectToken,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        _SessionFooter(
          state: state,
          item: item,
          languageCode: languageCode,
          onSubmit: controller.submit,
          onAdvance: controller.advance,
          onClear: controller.clearSelection,
        ),
      ],
    );
  }
}

class _SessionHeader extends StatelessWidget {
  const _SessionHeader({
    required this.progress,
    required this.resolved,
    required this.total,
    required this.onClose,
  });

  final double progress;
  final int resolved;
  final int total;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 24, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            color: context.palette.textSecondary,
            tooltip: AppL10n.of(context).sessionExitTooltip,
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: progress),
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: context.palette.surfaceAccent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.palette.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$resolved/$total',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TokenBank extends StatelessWidget {
  const _TokenBank({
    required this.item,
    required this.selectedTokens,
    required this.isLocked,
    required this.onSelect,
  });

  final DrillItem item;
  final List<String> selectedTokens;
  final bool isLocked;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    // Hitung sisa kuota tiap token supaya duplikat tetap bisa dipakai.
    final remaining = <String, int>{};
    for (final token in item.shuffledTokens) {
      remaining[token] = (remaining[token] ?? 0) + 1;
    }
    for (final token in selectedTokens) {
      remaining[token] = (remaining[token] ?? 0) - 1;
    }

    final rendered = <String, int>{};

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final token in item.shuffledTokens)
          Builder(
            builder: (context) {
              final index = rendered[token] = (rendered[token] ?? 0) + 1;
              final available = (remaining[token] ?? 0) >= index;

              return TokenChip(
                label: token,
                isDisabled: isLocked || !available,
                onTap: () => onSelect(token),
              );
            },
          ),
      ],
    );
  }
}

class _SessionFooter extends StatelessWidget {
  const _SessionFooter({
    required this.state,
    required this.item,
    required this.languageCode,
    required this.onSubmit,
    required this.onAdvance,
    required this.onClear,
  });

  final DrillSessionUiState state;
  final DrillItem item;
  final String languageCode;
  final VoidCallback onSubmit;
  final VoidCallback onAdvance;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: context.palette.primary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.isShowingFeedback)
            _FeedbackPanel(
              state: state,
              item: item,
              languageCode: languageCode,
            ),
          if (state.isShowingFeedback) const SizedBox(height: 16),
          Row(
            children: [
              if (!state.isShowingFeedback)
                TextButton(
                  onPressed: state.selectedTokens.isEmpty ? null : onClear,
                  child: Text(AppL10n.of(context).commonClear),
                ),
              const Spacer(),
              SizedBox(
                width: 180,
                height: 52,
                child: ElevatedButton(
                  onPressed: state.isShowingFeedback
                      ? onAdvance
                      : state.canSubmit
                      ? onSubmit
                      : null,
                  child: Text(
                    state.isShowingFeedback
                        ? (state.session.isFinished
                              ? l10n.sessionSeeResult
                              : l10n.sessionContinue)
                        : l10n.sessionCheck,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({
    required this.state,
    required this.item,
    required this.languageCode,
  });

  final DrillSessionUiState state;
  final DrillItem item;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final note = item.noteFor(languageCode);
    final textTheme = Theme.of(context).textTheme;
    final isCorrect = state.feedback == DrillFeedback.correct;
    final willRepeat = state.feedback == DrillFeedback.incorrectWillRepeat;

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCorrect
              ? context.palette.surfaceAccent
              : context.palette.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle_rounded : Icons.replay_rounded,
                  size: 20,
                  color: isCorrect
                      ? context.palette.primary
                      : context.palette.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isCorrect
                        ? l10n.feedbackCorrect
                        : willRepeat
                        ? l10n.feedbackWrongRepeat
                        : l10n.feedbackWrongMovedOn,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isCorrect
                          ? context.palette.primary
                          : context.palette.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(item.answer, style: textTheme.titleMedium),
            if (!isCorrect && item.patternIds.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l10n.feedbackPatternToPractise(
                  item.patternIds
                      .map((id) => GrammarPatterns.labelOf(l10n, id))
                      .join(', '),
                ),
                style: textTheme.bodySmall,
              ),
            ],
            if (note != null) ...[
              const SizedBox(height: 6),
              Text(note, style: textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _SessionLoadingView extends StatelessWidget {
  const _SessionLoadingView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(height: 24, width: 180),
          const SizedBox(height: 16),
          const ShimmerBox(height: 76, borderRadius: 20),
          const SizedBox(height: 24),
          Text(
            AppL10n.of(context).sessionLoading,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _SessionEmptyView extends StatelessWidget {
  const _SessionEmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          AppL10n.of(context).sessionEmpty,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _SessionErrorView extends StatelessWidget {
  const _SessionErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppL10n.of(context).sessionErrorTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(AppL10n.of(context).commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
