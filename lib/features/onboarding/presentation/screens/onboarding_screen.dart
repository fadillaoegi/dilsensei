import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/onboarding_preferences.dart';
import '../providers/onboarding_controller.dart';
import '../widgets/choice_card.dart';

/// Onboarding tiga langkah: nama, tujuan belajar, target harian.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _StepIndicator(step: draft.step),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _StepTransition(
                  step: draft.step,
                  child: switch (draft.step) {
                    0 => _NameStep(
                      controller: _nameController,
                      onChanged: controller.setName,
                      onSubmitted: (_) => controller.next(),
                    ),
                    1 => _GoalStep(
                      selected: draft.goal,
                      onSelect: controller.selectGoal,
                    ),
                    _ => _TargetStep(
                      selected: draft.dailyTarget,
                      onSelect: controller.selectTarget,
                    ),
                  },
                ),
              ),
            ),
            _OnboardingFooter(
              draft: draft,
              onBack: controller.back,
              onNext: controller.next,
            ),
          ],
        ),
      ),
    );
  }
}

/// Transisi antar langkah: naik halus disertai fade, bukan fade generik saja.
class _StepTransition extends StatelessWidget {
  const _StepTransition({required this.child, required this.step});

  final Widget child;
  final int step;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey<int>(step),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Row(
        children: [
          for (var i = 0; i < OnboardingDraft.totalSteps; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: i == OnboardingDraft.totalSteps - 1 ? 0 : 8,
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: i <= step ? 1 : 0),
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOut,
                  builder: (context, value, _) => Container(
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Color.lerp(
                        AppColors.secondary,
                        AppColors.primary,
                        value,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StepHeading extends StatelessWidget {
  const _StepHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.headlineMedium?.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(subtitle, style: textTheme.bodyMedium),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeading(
          title: 'Kita mulai dari\nnamamu',
          subtitle: 'Dipakai untuk menyapamu setiap kali membuka latihan.',
        ),
        TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          maxLength: 24,
          decoration: const InputDecoration(
            hintText: 'Nama panggilan',
            counterText: '',
          ),
        ),
      ],
    );
  }
}

class _GoalStep extends StatelessWidget {
  const _GoalStep({required this.selected, required this.onSelect});

  final LearningGoal? selected;
  final ValueChanged<LearningGoal> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeading(
          title: 'Kenapa belajar\nbahasa Jepang?',
          subtitle: 'Ini menentukan frasa mana yang kamu latih lebih dulu.',
        ),
        for (final goal in LearningGoal.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ChoiceCard(
              title: goal.label,
              description: goal.description,
              isSelected: goal == selected,
              onTap: () => onSelect(goal),
            ),
          ),
      ],
    );
  }
}

class _TargetStep extends StatelessWidget {
  const _TargetStep({required this.selected, required this.onSelect});

  final DailyTarget? selected;
  final ValueChanged<DailyTarget> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeading(
          title: 'Berapa menit\nsehari?',
          subtitle: 'Refleks tumbuh dari rutinitas pendek yang tidak bolong.',
        ),
        for (final target in DailyTarget.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ChoiceCard(
              title: '${target.minutes} menit · ${target.label}',
              description: target.description,
              isSelected: target == selected,
              onTap: () => onSelect(target),
            ),
          ),
      ],
    );
  }
}

class _OnboardingFooter extends StatelessWidget {
  const _OnboardingFooter({
    required this.draft,
    required this.onBack,
    required this.onNext,
  });

  final OnboardingDraft draft;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Row(
        children: [
          if (draft.step > 0)
            TextButton(
              onPressed: draft.isSaving ? null : onBack,
              child: const Text('Kembali'),
            ),
          const Spacer(),
          SizedBox(
            width: 168,
            height: 52,
            child: ElevatedButton(
              onPressed: draft.canContinue && !draft.isSaving ? onNext : null,
              child: draft.isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppColors.white,
                      ),
                    )
                  : Text(draft.isLastStep ? 'Mulai Berlatih' : 'Lanjut'),
            ),
          ),
        ],
      ),
    );
  }
}
