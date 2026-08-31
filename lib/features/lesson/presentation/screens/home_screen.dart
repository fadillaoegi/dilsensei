import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/language_controller.dart';
import '../../../../core/monetization/monetization_providers.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../kana/domain/kana_chart.dart';
import '../../../kana/presentation/widgets/kana_shortcut_row.dart';
import '../../../onboarding/presentation/providers/onboarding_controller.dart';
import '../../domain/entities/lesson_module.dart';
import '../providers/lesson_providers.dart';
import '../providers/progress_controller.dart';
import '../widgets/home_header.dart';
import '../widgets/update_banner.dart';
import '../widgets/lesson_list_item.dart';
import '../widgets/shimmer_box.dart';
import '../widgets/today_module_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(lessonBoardProvider);
    final streakDays = ref.watch(displayStreakProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final userName = ref.watch(userNameProvider);
    final canStartSession = ref.watch(canStartSessionProvider);
    final languageCode = ref.watch(languageControllerProvider).code;
    final dayPart = ref.watch(dayPartProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeActions(
                onOpenInsights: () => context.push(AppRoutes.insights),
                onOpenSettings: () => context.push(AppRoutes.settings),
              ),
              HomeHeader(
                userName: userName,
                streakDays: streakDays,
                dayPart: dayPart,
              ),
              const SizedBox(height: 28),
              // Tawaran pembaruan berada di bawah header dan di atas daftar
              // modul: terlihat, tapi tidak menggeser tombol mulai sesi ke luar
              // layar saat tidak ada pembaruan (widgetnya nol tinggi).
              const UpdateBanner(),
              board.when(
                loading: () => const _HomeLoadingView(),
                error: (error, _) => _HomeErrorView(
                  onRetry: () => ref.invalidate(lessonModulesProvider),
                ),
                data: (data) => _HomeContentView(
                  board: data,
                  isPremium: isPremium,
                  languageCode: languageCode,
                  onOpenKana: (script) =>
                      context.push(AppRoutes.kanaFor(script)),
                  onModuleTap: (module) => _openModule(
                    context,
                    module,
                    isPremium: isPremium,
                    canStartSession: canStartSession,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _openModule(
    BuildContext context,
    LessonModule module, {
    required bool isPremium,
    required bool canStartSession,
  }) {
    // Modul premium hanya terbuka bila entitlement RevenueCat aktif.
    if (module.isPremium && !isPremium) {
      context.push(AppRoutes.paywall);
      return;
    }

    // Pengguna gratis dibatasi satu sesi per hari; ini yang dijanjikan paywall
    // sebagai "sesi tanpa batas harian" untuk premium.
    if (!canStartSession) {
      _showDailyLimitReached(context);
      return;
    }

    context.push(AppRoutes.sessionFor(module.id));
  }

  void _showDailyLimitReached(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => _DailyLimitSheet(
        onUpgrade: () {
          Navigator.of(sheetContext).pop();
          context.push(AppRoutes.paywall);
        },
        onClose: () => Navigator.of(sheetContext).pop(),
      ),
    );
  }
}

/// Tombol akses ke peta kelemahan dan pengaturan.
class _HomeActions extends StatelessWidget {
  const _HomeActions({
    required this.onOpenInsights,
    required this.onOpenSettings,
  });

  final VoidCallback onOpenInsights;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: onOpenInsights,
          icon: const Icon(Icons.insights_rounded),
          color: context.palette.primary,
          tooltip: l10n.homeInsightsTooltip,
        ),
        IconButton(
          onPressed: onOpenSettings,
          icon: const Icon(Icons.settings_outlined),
          color: context.palette.textSecondary,
          tooltip: l10n.homeSettingsTooltip,
        ),
      ],
    );
  }
}

/// Penjelasan saat kuota sesi harian versi gratis habis.
class _DailyLimitSheet extends StatelessWidget {
  const _DailyLimitSheet({required this.onUpgrade, required this.onClose});

  final VoidCallback onUpgrade;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final textTheme = Theme.of(context).textTheme;

    // Dibuat scrollable agar tidak meluber pada layar pendek atau mode lanskap.
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dailyLimitTitle,
              style: textTheme.headlineSmall?.copyWith(
                color: context.palette.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.dailyLimitBody,
              style: textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onUpgrade,
                child: Text(l10n.commonSeePro),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onClose,
                child: Text(l10n.dailyLimitLater),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContentView extends StatelessWidget {
  const _HomeContentView({
    required this.board,
    required this.isPremium,
    required this.languageCode,
    required this.onModuleTap,
    required this.onOpenKana,
  });

  final LessonBoard board;
  final bool isPremium;
  final String languageCode;
  final ValueChanged<LessonModule> onModuleTap;
  final ValueChanged<KanaScript> onOpenKana;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final todayModule = board.todayModule;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (todayModule != null)
          TodayModuleCard(
            module: todayModule,
            title: todayModule.titleFor(languageCode),
            subtitle: todayModule.subtitleFor(languageCode),
            onStart: () => onModuleTap(todayModule),
          ),
        const SizedBox(height: 32),
        KanaShortcutRow(onOpen: onOpenKana),
        if (board.otherModules.isNotEmpty) ...[
          const SizedBox(height: 32),
          _SectionTitle(title: l10n.homeRoadmapTitle),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: board.otherModules.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final module = board.otherModules[index];

              return LessonListItem(
                module: module,
                title: module.titleFor(languageCode),
                subtitle: module.subtitleFor(languageCode),
                isUnlocked: isPremium,
                onTap: () => onModuleTap(module),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(color: context.palette.primary),
    );
  }
}

class _HomeLoadingView extends StatelessWidget {
  const _HomeLoadingView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HeroCardSkeleton(),
        const SizedBox(height: 32),
        Text(
          AppL10n.of(context).homeLoading,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        const LessonListSkeleton(),
      ],
    );
  }
}

class _HomeErrorView extends StatelessWidget {
  const _HomeErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.palette.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homeErrorTitle,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(l10n.homeErrorBody, style: textTheme.bodyMedium),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
        ],
      ),
    );
  }
}
