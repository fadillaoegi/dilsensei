import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/diagnostics/diagnostics_log.dart';
import '../../../../core/diagnostics/diagnostics_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Menampilkan log diagnostik sesi berjalan.
///
/// Dibuat untuk keadaan yang tidak bisa didiagnosis lewat test: APK sudah
/// dipasang di perangkat, pembelian gagal, dan logcat tidak tersambung. Isinya
/// dapat disalin utuh untuk dilaporkan.
class DiagnosticsScreen extends ConsumerStatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends ConsumerState<DiagnosticsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final log = ref.watch(diagnosticsLogProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.diagnosticsTitle),
        actions: [
          IconButton(
            onPressed: log.isEmpty ? null : () => _copy(log),
            icon: const Icon(Icons.copy_all_outlined),
            tooltip: l10n.diagnosticsCopy,
          ),
          IconButton(
            onPressed: log.isEmpty ? null : log.clear,
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: l10n.diagnosticsClear,
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: log,
          builder: (context, _) {
            if (log.isEmpty) {
              return _EmptyState(message: l10n.diagnosticsEmpty);
            }

            // Terbaru di atas: yang baru terjadi itulah yang sedang dicari.
            final entries = log.entries.reversed.toList(growable: false);

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) =>
                  _EntryTile(entry: entries[index]),
            );
          },
        ),
      ),
    );
  }

  Future<void> _copy(DiagnosticsLog log) async {
    await Clipboard.setData(ClipboardData(text: log.asText()));
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).diagnosticsCopied)),
      );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final DiagnosticEntry entry;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    final accent = switch (entry.level) {
      DiagnosticSeverity.info => palette.primary,
      DiagnosticSeverity.warning => palette.textSecondary,
      DiagnosticSeverity.error => palette.error,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  entry.scope,
                  style: textTheme.labelSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                entry.at.toIso8601String().substring(11, 19),
                style: textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            entry.message,
            style: textTheme.bodyLarge?.copyWith(color: palette.textPrimary),
          ),
          if (entry.detail != null) ...[
            const SizedBox(height: 4),
            // SelectableText supaya potongan tertentu bisa disalin manual.
            SelectableText(
              entry.detail!,
              style: textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
            ),
          ],
        ],
      ),
    );
  }
}
