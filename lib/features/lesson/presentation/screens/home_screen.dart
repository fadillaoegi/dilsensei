import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/monetization/monetization_providers.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/lesson_module.dart';
import '../../../onboarding/presentation/providers/onboarding_controller.dart';
import '../providers/lesson_providers.dart';
import '../providers/progress_controller.dart';
import '../widgets/home_header.dart';
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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(userName: userName, streakDays: streakDays),
              const SizedBox(height: 28),
              board.when(
                loading: () => const _HomeLoadingView(),
                error: (error, _) => _HomeErrorView(
                  onRetry: () => ref.invalidate(lessonModulesProvider),
                ),
                data: (data) => _HomeContentView(
                  board: data,
                  isPremium: isPremium,
                  onModuleTap: (module) =>
                      _openModule(context, module, isPremium: isPremium),
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
  }) {
    // Modul premium hanya terbuka bila entitlement RevenueCat aktif.
    if (module.isPremium && !isPremium) {
      context.push(AppRoutes.paywall);
      return;
    }

    context.push(AppRoutes.sessionFor(module.id));
  }
}

class _HomeContentView extends StatelessWidget {
  const _HomeContentView({
    required this.board,
    required this.isPremium,
    required this.onModuleTap,
  });

  final LessonBoard board;
  final bool isPremium;
  final ValueChanged<LessonModule> onModuleTap;

  @override
  Widget build(BuildContext context) {
    final todayModule = board.todayModule;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (todayModule != null)
          TodayModuleCard(
            module: todayModule,
            onStart: () => onModuleTap(todayModule),
          ),
        if (board.otherModules.isNotEmpty) ...[
          const SizedBox(height: 32),
          const _SectionTitle(title: 'Peta Belajarmu'),
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
      ).textTheme.titleLarge?.copyWith(color: AppColors.primary),
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
          'Menyiapkan sesi latihanmu...',
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
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Materi belum bisa dimuat',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Periksa koneksimu, lalu coba lagi sebentar.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}
