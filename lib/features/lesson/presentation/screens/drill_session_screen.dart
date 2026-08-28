import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/drill_item.dart';
import '../../domain/entities/grammar_pattern.dart';
import '../providers/drill_session_controller.dart';
import '../providers/lesson_providers.dart';
import '../providers/progress_controller.dart';
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
    final state = ref.watch(drillSessionControllerProvider(moduleId));
    final controller = ref.read(
      drillSessionControllerProvider(moduleId).notifier,
    );

    // Catat progres tepat saat ringkasan pertama kali muncul, bukan tiap build.
    ref.listen(drillSessionControllerProvider(moduleId), (previous, next) {
      final summary = next.summary;
      if (previous?.summary == null && summary != null) {
        ref.read(progressControllerProvider.notifier).recordSession(summary);
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

      return SessionSummaryView(
        summary: summary,
        onClose: () => Navigator.of(context).pop(),
        onDrillWeakPatterns: hasWeakPatterns
            ? controller.restartWithWeakPatterns
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
                Text(
                  'SUSUN DALAM BAHASA JEPANG',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.prompt,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                AnswerCanvas(
                  tokens: state.selectedTokens,
                  isLocked: state.isShowingFeedback,
                  onRemoveAt: controller.removeTokenAt,
                ),
                const SizedBox(height: 24),
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
            color: AppColors.textSecondary,
            tooltip: 'Keluar sesi',
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
                  backgroundColor: AppColors.secondary,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$resolved/$total',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
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
    required this.onSubmit,
    required this.onAdvance,
    required this.onClear,
  });

  final DrillSessionUiState state;
  final DrillItem item;
  final VoidCallback onSubmit;
  final VoidCallback onAdvance;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.isShowingFeedback) _FeedbackPanel(state: state, item: item),
          if (state.isShowingFeedback) const SizedBox(height: 16),
          Row(
            children: [
              if (!state.isShowingFeedback)
                TextButton(
                  onPressed: state.selectedTokens.isEmpty ? null : onClear,
                  child: const Text('Hapus'),
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
                        ? (state.session.isFinished ? 'Lihat Hasil' : 'Lanjut')
                        : 'Periksa',
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
  const _FeedbackPanel({required this.state, required this.item});

  final DrillSessionUiState state;
  final DrillItem item;

  @override
  Widget build(BuildContext context) {
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
              ? AppColors.secondary
              : AppColors.error.withValues(alpha: 0.08),
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
                  color: isCorrect ? AppColors.primary : AppColors.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isCorrect
                        ? 'Tepat.'
                        : willRepeat
                        ? 'Belum tepat — butir ini muncul lagi nanti.'
                        : 'Belum tepat. Simpan untuk sesi besok.',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isCorrect ? AppColors.primary : AppColors.error,
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
                'Pola yang perlu dilatih: '
                '${item.patternIds.map(GrammarPatterns.labelOf).join(', ')}',
                style: textTheme.bodySmall,
              ),
            ],
            if (item.note != null) ...[
              const SizedBox(height: 6),
              Text(item.note!, style: textTheme.bodySmall),
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
            'Menyiapkan butir latihan...',
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
          'Butir latihan untuk modul ini belum tersedia.',
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
              'Latihan belum bisa dimuat',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}
