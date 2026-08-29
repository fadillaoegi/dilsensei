import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/kana_chart.dart';

/// Pintu masuk bagan huruf pada Home.
///
/// Ditempatkan sebelum daftar modul supaya pengguna bisa menyegarkan huruf
/// dulu tanpa memulai sesi. Gratis, jadi tidak ada pemeriksaan entitlement.
class KanaShortcutRow extends StatelessWidget {
  const KanaShortcutRow({required this.onOpen, super.key});

  final ValueChanged<KanaScript> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.kanaSectionTitle,
                style: textTheme.titleLarge?.copyWith(
                  color: context.palette.primary,
                ),
              ),
            ),
            const _FreeBadge(),
          ],
        ),
        const SizedBox(height: 4),
        Text(l10n.kanaSectionSubtitle, style: textTheme.bodySmall),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _KanaButton(
                script: KanaScript.hiragana,
                label: l10n.kanaHiragana,
                sample: 'あ',
                onTap: () => onOpen(KanaScript.hiragana),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KanaButton(
                script: KanaScript.katakana,
                label: l10n.kanaKatakana,
                sample: 'ア',
                onTap: () => onOpen(KanaScript.katakana),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FreeBadge extends StatelessWidget {
  const _FreeBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.palette.surfaceAccent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        AppL10n.of(context).kanaFreeBadge,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: context.palette.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _KanaButton extends StatelessWidget {
  const _KanaButton({
    required this.script,
    required this.label,
    required this.sample,
    required this.onTap,
  });

  final KanaScript script;
  final String label;

  /// Satu huruf contoh sebagai penanda visual, bukan dekorasi kosong.
  final String sample;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final textTheme = Theme.of(context).textTheme;
    final letterCount = KanaChart.sectionsFor(
      script,
    ).fold<int>(0, (total, section) => total + section.cells.length);

    return Material(
      color: context.palette.surfaceCard,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: context.palette.primary.withValues(alpha: 0.14),
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.palette.surfaceAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  sample,
                  style: textTheme.titleLarge?.copyWith(
                    color: context.palette.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.kanaLetterCount(letterCount),
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
