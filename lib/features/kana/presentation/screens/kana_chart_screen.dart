import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/kana_chart.dart';

/// Bagan huruf sebagai rujukan cepat sebelum sesi latihan.
///
/// Sengaja gratis dan tanpa gating: huruf dasar adalah hal pertama yang dicari
/// pemula, dan menahannya di balik paywall hanya akan membuat orang pergi.
class KanaChartScreen extends StatelessWidget {
  const KanaChartScreen({required this.script, super.key});

  final KanaScript script;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final textTheme = Theme.of(context).textTheme;
    final sections = KanaChart.sectionsFor(script);

    return Scaffold(
      appBar: AppBar(title: Text(_scriptName(l10n))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _UsageCard(
              title: l10n.kanaUsageTitle,
              body: script == KanaScript.hiragana
                  ? l10n.kanaHiraganaUsage
                  : l10n.kanaKatakanaUsage,
            ),
            const SizedBox(height: 28),
            for (final section in sections) ...[
              Text(
                _sectionTitle(l10n, section.kind),
                style: textTheme.titleMedium?.copyWith(
                  color: context.palette.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _KanaGrid(section: section),
              const SizedBox(height: 28),
            ],
            _TipCard(title: l10n.kanaTipTitle, body: l10n.kanaTipBody),
          ],
        ),
      ),
    );
  }

  String _scriptName(AppL10n l10n) => switch (script) {
    KanaScript.hiragana => l10n.kanaHiragana,
    KanaScript.katakana => l10n.kanaKatakana,
  };

  static String _sectionTitle(AppL10n l10n, KanaSectionKind kind) =>
      switch (kind) {
        KanaSectionKind.base => l10n.kanaSectionBase,
        KanaSectionKind.voiced => l10n.kanaSectionVoiced,
        KanaSectionKind.combined => l10n.kanaSectionCombined,
      };
}

/// Grid huruf, disusun per baris agar pola konsonan-vokal terlihat.
class _KanaGrid extends StatelessWidget {
  const _KanaGrid({required this.section});

  final KanaSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in section.rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                for (final cell in row) ...[
                  Expanded(child: _KanaTile(cell: cell)),
                  const SizedBox(width: 8),
                ],
                // Baris pendek seperti や ゆ よ tetap sejajar dengan baris lima
                // huruf, bukan melebar mengisi sisa ruang.
                for (var i = row.length; i < 5; i++) ...[
                  const Expanded(child: SizedBox.shrink()),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _KanaTile extends StatelessWidget {
  const _KanaTile({required this.cell});

  final KanaCell cell;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: context.palette.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.palette.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          Text(
            cell.character,
            style: textTheme.headlineSmall?.copyWith(
              color: context.palette.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            cell.romaji,
            style: textTheme.labelSmall?.copyWith(
              color: context.palette.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageCard extends StatelessWidget {
  const _UsageCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.palette.surfaceAccent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.palette.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              color: context.palette.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(body, style: textTheme.bodyMedium?.copyWith(height: 1.6)),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.palette.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 18,
                color: context.palette.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(body, style: textTheme.bodySmall?.copyWith(height: 1.6)),
        ],
      ),
    );
  }
}
