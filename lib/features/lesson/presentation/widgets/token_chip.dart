import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Potongan kata yang bisa diketuk, dipakai di bank kata maupun area jawaban.
class TokenChip extends StatelessWidget {
  const TokenChip({
    required this.label,
    required this.onTap,
    this.isPlaced = false,
    this.isDisabled = false,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;

  /// True bila chip sedang berada di area jawaban.
  final bool isPlaced;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final background = isPlaced
        ? context.palette.primary
        : context.palette.surfaceCard;
    final foreground = isPlaced
        ? context.palette.onPrimary
        : context.palette.textPrimary;

    return Opacity(
      opacity: isDisabled ? 0.35 : 1,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isPlaced
                    ? Colors.transparent
                    : context.palette.primary.withValues(alpha: 0.16),
              ),
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Area tempat jawaban disusun, dengan garis dasar saat masih kosong.
class AnswerCanvas extends StatelessWidget {
  const AnswerCanvas({
    required this.tokens,
    required this.onRemoveAt,
    required this.isLocked,
    super.key,
  });

  final List<String> tokens;
  final ValueChanged<int> onRemoveAt;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.surfaceAccent.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.palette.primary.withValues(alpha: 0.12),
        ),
      ),
      child: tokens.isEmpty
          ? Text(
              AppL10n.of(context).sessionCanvasHint,
              style: Theme.of(context).textTheme.bodyMedium,
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < tokens.length; i++)
                  TokenChip(
                    label: tokens[i],
                    isPlaced: true,
                    isDisabled: isLocked,
                    onTap: () => onRemoveAt(i),
                  ),
              ],
            ),
    );
  }
}
