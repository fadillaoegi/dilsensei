import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/update/update_providers.dart';
import '../../../../l10n/app_localizations.dart';

/// Tautan halaman app di Google Play, dipakai bila pembaruan dalam app gagal.
const _playStoreUrl =
    'https://play.google.com/store/apps/details?id=com.fldev.dilsensei';

/// Perkembangan pembaruan di Home.
///
/// Tawaran awalnya dibawakan `UpdateDialog`; banner ini mengambil alih sesudah
/// pengguna setuju, yaitu saat mengunduh, siap dipasang, atau gagal. Bentuknya
/// kartu tenang supaya proses yang berjalan di latar tidak menghalangi tombol
/// mulai sesi.
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(updateControllerProvider);
    if (!state.isVisible) return const SizedBox.shrink();

    final l10n = AppL10n.of(context);
    final controller = ref.read(updateControllerProvider.notifier);

    return switch (state.stage) {
      UpdateStage.idle => const SizedBox.shrink(),
      // Tahap ini milik dialog. Menampilkannya di dua tempat sekaligus hanya
      // akan membuat pengguna menutup tawaran yang sama dua kali.
      UpdateStage.available => const SizedBox.shrink(),
      UpdateStage.downloading => _UpdateCard(
        icon: Icons.downloading_outlined,
        title: l10n.updateDownloadingTitle,
        body: l10n.updateDownloadingBody,
        isBusy: true,
      ),
      UpdateStage.readyToInstall => _UpdateCard(
        icon: Icons.restart_alt_rounded,
        title: l10n.updateReadyTitle,
        body: l10n.updateReadyBody,
        actionLabel: l10n.updateReadyAction,
        onAction: controller.install,
        onDismiss: controller.dismiss,
      ),
      UpdateStage.failed => _UpdateCard(
        icon: Icons.error_outline_rounded,
        title: l10n.updateFailedTitle,
        body: l10n.updateFailedBody,
        actionLabel: l10n.updateFailedAction,
        isError: true,
        onAction: () => launchUrl(
          Uri.parse(_playStoreUrl),
          mode: LaunchMode.externalApplication,
        ),
        onDismiss: controller.dismiss,
      ),
    };
  }
}

class _UpdateCard extends StatelessWidget {
  const _UpdateCard({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.isBusy = false,
    this.isError = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  final bool isBusy;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final accent = isError ? palette.error : palette.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surfaceAccent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isBusy
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: accent,
                      ),
                    )
                  : Icon(icon, size: 20, color: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(body, style: textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            // Wrap, bukan Row: label seperti "Open Google Play" meluber di layar
            // sempit, dan bahasa lain bisa lebih panjang lagi.
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 4,
              runSpacing: 4,
              children: [
                if (onDismiss != null)
                  TextButton(
                    onPressed: onDismiss,
                    style: TextButton.styleFrom(
                      foregroundColor: palette.textSecondary,
                    ),
                    child: Text(AppL10n.of(context).updateDismiss),
                  ),
                ElevatedButton(
                  onPressed: onAction,
                  style: isError
                      ? ElevatedButton.styleFrom(backgroundColor: palette.error)
                      : null,
                  child: Text(actionLabel!),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
