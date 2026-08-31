import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/language_controller.dart';
import '../../../../core/diagnostics/diagnostics_providers.dart';
import '../../../../core/monetization/dev_premium_override.dart';
import '../../../../core/monetization/monetization_config.dart';
import '../../../../core/monetization/monetization_providers.dart';
import '../../../../core/monetization/purchase_messages.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_mode_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../lesson/data/datasources/reminder_local_data_source.dart';
import '../../../lesson/presentation/providers/certificate_providers.dart';
import '../../../lesson/presentation/providers/lesson_providers.dart';
import '../../../lesson/presentation/providers/progress_controller.dart';
import '../../../lesson/presentation/providers/reminder_controller.dart';
import '../../../onboarding/presentation/providers/onboarding_controller.dart';

/// Pengaturan: bahasa, status langganan, Restore Purchases, tautan legal, dan
/// perkakas pengembangan.
///
/// Restore wajib dapat dijangkau di luar paywall, karena pengguna yang sudah
/// berlangganan tidak akan membuka paywall lagi saat pindah perangkat.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isRestoring = false;

  Future<void> _restore() async {
    if (_isRestoring) return;
    setState(() => _isRestoring = true);

    final l10n = AppL10n.of(context);
    final result = await ref
        .read(subscriptionServiceProvider)
        .restorePurchases();
    if (!mounted) return;
    setState(() => _isRestoring = false);

    _showMessage(
      result.isSuccess
          ? l10n.settingsRestoreSuccess
          : purchaseFailureMessage(l10n, result),
    );
  }

  Future<void> _openLink(String url) async {
    final l10n = AppL10n.of(context);
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      _showMessage(l10n.settingsCannotOpen(url));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final isPremium = ref.watch(isPremiumProvider);
    final name = ref.watch(userNameProvider);
    final target = ref
        .watch(onboardingPreferencesProvider)
        .valueOrNull
        ?.dailyTarget;
    final sessionsToday = ref.watch(sessionsTodayProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            _StatusCard(
              isPremium: isPremium,
              name: name,
              targetMinutes: target?.minutes,
              sessionsToday: sessionsToday,
              onUpgrade: () => context.push(AppRoutes.paywall),
            ),
            const SizedBox(height: 28),
            const _TrainingRecordTile(),
            const SizedBox(height: 18),
            _SectionLabel(l10n.settingsSectionPractice),
            _SettingsTile(
              icon: Icons.tune_rounded,
              title: l10n.practicePreferencesEntry,
              subtitle: target == null
                  ? null
                  : l10n.settingsDailyTarget(target.minutes),
              onTap: () => context.push(AppRoutes.practicePreferences),
            ),
            const SizedBox(height: 24),
            _SectionLabel(l10n.settingsSectionLanguage),
            const _LanguageSelector(),
            const SizedBox(height: 24),
            _SectionLabel(l10n.settingsSectionAppearance),
            const _ThemeSelector(),
            const SizedBox(height: 24),
            _SectionLabel(l10n.settingsSectionReminder),
            const _ReminderControls(),
            const SizedBox(height: 24),
            _SectionLabel(l10n.settingsSectionSubscription),
            _SettingsTile(
              icon: Icons.restore_rounded,
              title: l10n.settingsRestore,
              subtitle: l10n.settingsRestoreSubtitle,
              trailing: _isRestoring
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: _isRestoring ? null : _restore,
            ),
            _SettingsTile(
              icon: Icons.open_in_new_rounded,
              title: l10n.settingsManage,
              subtitle: l10n.settingsManageSubtitle,
              onTap: () => _openLink(
                'https://play.google.com/store/account/subscriptions',
              ),
            ),
            const SizedBox(height: 24),
            _SectionLabel(l10n.settingsSectionLegal),
            _SettingsTile(
              icon: Icons.shield_outlined,
              title: l10n.settingsPrivacy,
              onTap: () => _openLink(MonetizationConfig.privacyPolicyUrl),
            ),
            _SettingsTile(
              icon: Icons.description_outlined,
              title: l10n.settingsTerms,
              onTap: () => _openLink(MonetizationConfig.termsUrl),
            ),
            if (ref.watch(diagnosticsEnabledProvider)) ...[
              const SizedBox(height: 24),
              _SectionLabel(l10n.diagnosticsTitle),
              _SettingsTile(
                icon: Icons.bug_report_outlined,
                title: l10n.diagnosticsTitle,
                subtitle: l10n.diagnosticsSubtitle,
                onTap: () => context.push(AppRoutes.diagnostics),
              ),
            ],
            if (ref.watch(devToolsEnabledProvider)) ...[
              const SizedBox(height: 24),
              _SectionLabel(l10n.settingsSectionDevelopment),
              const _DevPremiumToggle(),
              const SizedBox(height: 10),
              const _DevCompleteAllButton(),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pemilih bahasa operasi aplikasi.
///
/// Pilihan ini juga mengubah bahasa perintah latihan, bukan hanya antarmuka.
class _LanguageSelector extends ConsumerWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final selected = ref.watch(languageControllerProvider);

    String labelOf(AppLanguage language) => switch (language) {
      AppLanguage.english => l10n.languageEnglish,
      AppLanguage.indonesian => l10n.languageIndonesian,
    };

    return Column(
      children: [
        for (final language in AppLanguage.values)
          _SettingsTile(
            icon: language == selected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            title: labelOf(language),
            subtitle: language == selected
                ? l10n.settingsLanguageSubtitle
                : null,
            isSelected: language == selected,
            trailing: const SizedBox.shrink(),
            onTap: () =>
                ref.read(languageControllerProvider.notifier).select(language),
          ),
      ],
    );
  }
}

/// Pemilih tampilan: ikut perangkat, terang, atau gelap.
///
/// Strukturnya sengaja sama dengan [_LanguageSelector] supaya kedua pengaturan
/// terasa satu keluarga.
class _ThemeSelector extends ConsumerWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final selected = ref.watch(themeModeControllerProvider);

    String labelOf(AppThemeMode mode) => switch (mode) {
      AppThemeMode.system => l10n.themeSystem,
      AppThemeMode.light => l10n.themeLight,
      AppThemeMode.dark => l10n.themeDark,
    };

    IconData iconOf(AppThemeMode mode) => switch (mode) {
      AppThemeMode.system => Icons.brightness_auto_outlined,
      AppThemeMode.light => Icons.light_mode_outlined,
      AppThemeMode.dark => Icons.dark_mode_outlined,
    };

    return Column(
      children: [
        for (final mode in AppThemeMode.values)
          _SettingsTile(
            icon: iconOf(mode),
            title: labelOf(mode),
            subtitle: mode == selected ? l10n.settingsThemeSubtitle : null,
            isSelected: mode == selected,
            trailing: Icon(
              mode == selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20,
              color: mode == selected
                  ? context.palette.primary
                  : context.palette.textSecondary,
            ),
            onTap: () =>
                ref.read(themeModeControllerProvider.notifier).select(mode),
          ),
      ],
    );
  }
}

/// Tombol dev yang menandai seluruh modul selesai, agar Training Record bisa
/// diperiksa tanpa menyelesaikan delapan modul secara manual.
///
/// Sama seperti tombol Pro, blok ini hanya dirender saat
/// [devToolsEnabledProvider] bernilai true
/// dan aksinya menolak berjalan di build release.
class _DevCompleteAllButton extends ConsumerStatefulWidget {
  const _DevCompleteAllButton();

  @override
  ConsumerState<_DevCompleteAllButton> createState() =>
      _DevCompleteAllButtonState();
}

class _DevCompleteAllButtonState extends ConsumerState<_DevCompleteAllButton> {
  bool _isBusy = false;

  Future<void> _run() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);

    final modules = await ref.read(lessonModulesProvider.future);
    await ref
        .read(progressControllerProvider.notifier)
        .devCompleteAllModules(
          modules.map((module) => module.id).toList(growable: false),
        );
    if (!mounted) return;

    setState(() => _isBusy = false);
    ref.invalidate(trainingRecordProvider);

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('DEV: ${modules.length} modul ditandai selesai'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isBusy ? null : _run,
        style: OutlinedButton.styleFrom(
          foregroundColor: context.palette.error,
          side: BorderSide(color: context.palette.error.withValues(alpha: 0.5)),
        ),
        icon: const Icon(Icons.done_all_rounded, size: 18),
        label: const Text('DEV: Complete all modules'),
      ),
    );
  }
}

/// Pintu masuk Training Record beserta status kelayakannya.
class _TrainingRecordTile extends ConsumerWidget {
  const _TrainingRecordTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(trainingRecordProvider).valueOrNull;
    final isUnlocked = state?.isUnlocked ?? false;

    return _SettingsTile(
      icon: Icons.workspace_premium_outlined,
      title: l10n.recordEntryTitle,
      subtitle: isUnlocked
          ? l10n.recordEntrySubtitle
          : l10n.recordEntryLocked(
              state?.completedModules ?? 0,
              state?.totalModules ?? 0,
            ),
      isSelected: isUnlocked,
      onTap: () => context.push(AppRoutes.trainingRecord),
    );
  }
}

/// Kendali pengingat harian: sakelar aktif dan pemilih jam.
///
/// Pengingatnya lokal, jadi tidak butuh server maupun akun. Isi pesannya diambil
/// dari pola kelemahan pengguna, bukan kalimat generik.
class _ReminderControls extends ConsumerStatefulWidget {
  const _ReminderControls();

  @override
  ConsumerState<_ReminderControls> createState() => _ReminderControlsState();
}

class _ReminderControlsState extends ConsumerState<_ReminderControls> {
  bool _isBusy = false;

  Future<void> _toggle(bool value) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);

    final l10n = AppL10n.of(context);
    final granted = await ref
        .read(reminderControllerProvider.notifier)
        .setEnabled(value);
    if (!mounted) return;
    setState(() => _isBusy = false);

    if (!granted) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text(l10n.settingsReminderPermissionDenied)),
        );
    }
  }

  Future<void> _pickTime(ReminderPreferences preferences) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: preferences.hour,
        minute: preferences.minute,
      ),
    );
    if (picked == null || !mounted) return;

    await ref
        .read(reminderControllerProvider.notifier)
        .setTime(hour: picked.hour, minute: picked.minute);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final preferences = ref.watch(reminderControllerProvider);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.palette.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.palette.primary.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 20,
                    color: context.palette.primary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      l10n.settingsReminderToggle,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Switch(
                    value: preferences.isEnabled,
                    onChanged: _isBusy ? null : _toggle,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(l10n.settingsReminderToggleBody, style: textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (preferences.isEnabled)
          _SettingsTile(
            icon: Icons.schedule_rounded,
            title: l10n.settingsReminderTime,
            subtitle: l10n.settingsReminderTimeValue(_formatTime(preferences)),
            onTap: () => _pickTime(preferences),
          ),
      ],
    );
  }

  static String _formatTime(ReminderPreferences preferences) {
    final hour = preferences.hour.toString().padLeft(2, '0');
    final minute = preferences.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}

/// Tombol dev untuk memaksa akses Pro.
///
/// Hanya dirender saat [devToolsEnabledProvider] bernilai true, yaitu build
/// debug atau profile.
class _DevPremiumToggle extends ConsumerWidget {
  const _DevPremiumToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final isActive = ref.watch(devPremiumOverrideProvider);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.palette.error.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.construction_rounded,
                size: 18,
                color: context.palette.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.settingsDevToggle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.palette.error,
                  ),
                ),
              ),
              Switch(
                value: isActive,
                activeThumbColor: context.palette.error,
                onChanged: (_) =>
                    ref.read(devPremiumOverrideProvider.notifier).toggle(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(l10n.settingsDevToggleBody, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.isPremium,
    required this.name,
    required this.targetMinutes,
    required this.sessionsToday,
    required this.onUpgrade,
  });

  final bool isPremium;
  final String name;
  final int? targetMinutes;
  final int sessionsToday;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPremium
            ? context.palette.surfaceAccent
            : context.palette.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPremium
              ? context.palette.primary
              : context.palette.primary.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            isPremium ? l10n.settingsProActive : l10n.settingsFreePlan,
            style: textTheme.bodyMedium?.copyWith(
              color: isPremium
                  ? context.palette.primary
                  : context.palette.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (targetMinutes != null) ...[
            const SizedBox(height: 10),
            Text(
              l10n.settingsDailyTarget(targetMinutes!),
              style: textTheme.bodySmall,
            ),
          ],
          Text(
            l10n.settingsSessionsToday(sessionsToday),
            style: textTheme.bodySmall,
          ),
          if (!isPremium) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onUpgrade,
              child: Text(l10n.commonSeePro),
            ),
          ],
        ],
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
      padding: const EdgeInsets.only(bottom: 8),
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

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.isSelected = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isSelected
            ? context.palette.surfaceAccent
            : context.palette.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? context.palette.primary
                    : context.palette.primary.withValues(alpha: 0.12),
                width: isSelected ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: context.palette.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!, style: textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
                trailing ??
                    Icon(
                      Icons.chevron_right_rounded,
                      color: context.palette.textSecondary,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
