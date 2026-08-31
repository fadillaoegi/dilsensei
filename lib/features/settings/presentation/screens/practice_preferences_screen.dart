import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../onboarding/domain/onboarding_preferences.dart';
import '../../../onboarding/presentation/providers/onboarding_controller.dart';
import '../../../onboarding/presentation/providers/practice_preferences_editor.dart';
import '../../../onboarding/presentation/widgets/choice_card.dart';

/// Mengubah jawaban onboarding: tujuan belajar dan target harian.
///
/// Dipisah dari Pengaturan supaya daftar utama tidak makin panjang, dan memakai
/// ulang [ChoiceCard] yang sama seperti onboarding agar keduanya terasa satu
/// keputusan yang bisa ditinjau ulang, bukan dua hal berbeda.
class PracticePreferencesScreen extends ConsumerWidget {
  const PracticePreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final preferences = ref.watch(onboardingPreferencesProvider);
    final editor = ref.read(practicePreferencesEditorProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.practicePreferencesTitle)),
      body: SafeArea(
        child: preferences.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.practicePreferencesError),
            ),
          ),
          data: (data) => ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              Text(
                l10n.practicePreferencesSubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _SectionLabel(l10n.onboardingGoalTitle),
              for (final goal in LearningGoal.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ChoiceCard(
                    title: goal.labelFor(l10n),
                    description: goal.descriptionFor(l10n),
                    isSelected: goal == data.goal,
                    onTap: () => editor.update(goal: goal),
                  ),
                ),
              const SizedBox(height: 20),
              _SectionLabel(l10n.onboardingTargetTitle),
              for (final target in DailyTarget.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ChoiceCard(
                    title: target.labelFor(l10n),
                    description: target.descriptionFor(l10n),
                    isSelected: target == data.dailyTarget,
                    onTap: () => editor.update(dailyTarget: target),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: context.palette.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
