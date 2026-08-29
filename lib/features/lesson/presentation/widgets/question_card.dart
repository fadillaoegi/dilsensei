import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/drill_item.dart';

/// Pertanyaan sesi, disajikan sesuai tipe butir.
///
/// Untuk isi partikel, token yang dipilih langsung muncul di posisi rumpang
/// sehingga pengguna membaca kalimat utuh sebelum memeriksa jawaban.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    required this.item,
    required this.selectedTokens,
    required this.languageCode,
    super.key,
  });

  final DrillItem item;
  final List<String> selectedTokens;

  /// Bahasa aktif, menentukan versi prompt dan instruksi yang ditampilkan.
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _label(l10n),
          style: textTheme.labelSmall?.copyWith(
            color: context.palette.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        if (item.type == DrillType.assembleSentence)
          Text(item.promptFor(languageCode), style: textTheme.headlineSmall)
        else ...[
          _JapaneseQuestion(item: item, selectedTokens: selectedTokens),
          const SizedBox(height: 10),
          Text(item.promptFor(languageCode), style: textTheme.bodyMedium),
        ],
      ],
    );
  }

  String _label(AppL10n l10n) => switch (item.type) {
    DrillType.assembleSentence => l10n.sessionAssembleLabel,
    DrillType.chooseParticle => l10n.sessionParticleLabel,
    DrillType.transformForm =>
      item.instructionFor(languageCode)?.toUpperCase() ??
          l10n.sessionTransformLabel,
  };
}

class _JapaneseQuestion extends StatelessWidget {
  const _JapaneseQuestion({required this.item, required this.selectedTokens});

  final DrillItem item;
  final List<String> selectedTokens;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headlineSmall;
    final question = item.questionText ?? '';
    final filled = selectedTokens.isEmpty ? null : selectedTokens.first;

    if (item.type == DrillType.transformForm) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: style),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.arrow_downward_rounded,
                size: 18,
                color: context.palette.primary,
              ),
              const SizedBox(width: 8),
              Text(
                filled ?? '?',
                style: style?.copyWith(color: context.palette.primary),
              ),
            ],
          ),
        ],
      );
    }

    final parts = question.split(DrillItem.blankMarker);

    return RichText(
      text: TextSpan(
        style: style,
        children: <InlineSpan>[
          TextSpan(text: parts.first),
          if (filled == null)
            TextSpan(
              text: '　　',
              style: style?.copyWith(
                color: context.palette.primary,
                decoration: TextDecoration.underline,
                decorationThickness: 2,
              ),
            )
          else
            TextSpan(
              text: filled,
              style: style?.copyWith(
                color: context.palette.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (parts.length > 1) TextSpan(text: parts.last),
        ],
      ),
    );
  }
}
