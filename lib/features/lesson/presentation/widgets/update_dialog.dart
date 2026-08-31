import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/update/update_providers.dart';
import '../../../../l10n/app_localizations.dart';

/// Jawaban pengguna atas tawaran pembaruan.
enum UpdateDialogChoice { update, later }

/// Menampilkan tawaran pembaruan Google Play sebagai dialog.
///
/// Mengembalikan pilihan pengguna, atau null bila dialog ditutup lewat barrier
/// maupun tombol kembali. Pemanggil memperlakukan null sama dengan
/// [UpdateDialogChoice.later]: pembaruan tidak boleh menyandera pengguna.
Future<UpdateDialogChoice?> showUpdateDialog(BuildContext context) {
  return showDialog<UpdateDialogChoice>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const UpdateDialog(),
  );
}

/// Isi dialog pembaruan.
///
/// Sengaja tidak menyentuh Riverpod: dialog hanya melaporkan pilihan lewat
/// [Navigator.pop], dan [UpdateDialogHost] yang menjalankan akibatnya. Dengan
/// begitu dialog ini bisa diuji sendiri tanpa provider.
class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppL10n.of(context);

    return Dialog(
      backgroundColor: palette.surfaceCard,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: palette.primary.withValues(alpha: 0.12)),
      ),
      // Scrollable agar isinya tidak meluber pada layar pendek atau lanskap.
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: palette.surfaceAccent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.system_update_outlined,
                size: 26,
                color: palette.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.updateAvailableTitle,
              style: textTheme.headlineSmall?.copyWith(color: palette.primary),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.updateAvailableBody,
              style: textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pop(UpdateDialogChoice.update),
                child: Text(l10n.updateDialogAction),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(UpdateDialogChoice.later),
                style: TextButton.styleFrom(
                  foregroundColor: palette.textSecondary,
                ),
                child: Text(l10n.updateDismiss),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pemicu dialog pembaruan. Widget tanpa tampilan, dipasang di Home.
///
/// Dua aturan yang disengaja. Pertama, dialog hanya muncul untuk tahap
/// [UpdateStage.available] — sekali per hidup controller — sehingga pengguna
/// tidak diinterupsi berulang kali. Kedua, tahap berikutnya (mengunduh, siap
/// pasang, gagal) diserahkan ke `UpdateBanner`: pesan "bisa tetap berlatih
/// sambil menunggu" akan bohong bila unduhannya ditahan di balik dialog modal.
class UpdateDialogHost extends ConsumerStatefulWidget {
  const UpdateDialogHost({super.key});

  @override
  ConsumerState<UpdateDialogHost> createState() => _UpdateDialogHostState();
}

class _UpdateDialogHostState extends ConsumerState<UpdateDialogHost> {
  bool _hasOffered = false;

  @override
  void initState() {
    super.initState();

    // Tawaran bisa sudah ada sebelum host terpasang, misalnya saat pengguna
    // kembali ke Home dari layar lain. Dijalankan setelah frame pertama karena
    // showDialog membutuhkan Navigator yang sudah terbangun.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _offerIfAvailable(ref.read(updateControllerProvider).stage);
    });
  }

  @override
  Widget build(BuildContext context) {
    // listen, bukan watch: widget ini tidak menggambar apa pun, ia hanya
    // bereaksi. Ia juga yang pertama menyentuh provider sehingga pemeriksaan
    // pembaruan berjalan meski banner belum terpasang.
    ref.listen<UpdateState>(updateControllerProvider, (_, next) {
      _offerIfAvailable(next.stage);
    });

    return const SizedBox.shrink();
  }

  Future<void> _offerIfAvailable(UpdateStage stage) async {
    if (stage != UpdateStage.available || _hasOffered) return;
    _hasOffered = true;

    final choice = await showUpdateDialog(context);
    if (!mounted) return;

    final controller = ref.read(updateControllerProvider.notifier);

    if (choice == UpdateDialogChoice.update) {
      await controller.startDownload();

      return;
    }

    // "Nanti", barrier, maupun tombol kembali: tawaran ditutup sampai app
    // dijalankan lagi.
    controller.dismiss();
  }
}
