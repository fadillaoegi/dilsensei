import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../onboarding/presentation/providers/onboarding_controller.dart';
import '../../domain/services/certificate_rules.dart';
import '../providers/certificate_providers.dart';

/// Training Record: bukti bahwa seluruh modul sudah diselesaikan.
///
/// Seluruh teks di layar ini **sengaja berbahasa Inggris**, apa pun bahasa app.
/// Alasannya: ini artefak yang dibagikan ke orang lain — atasan, perekrut,
/// teman di luar negeri — jadi harus terbaca universal. Sengaja pula disebut
/// "training record", bukan sertifikat resmi, karena ini bukan kualifikasi.
class TrainingRecordScreen extends ConsumerWidget {
  const TrainingRecordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eligibility = ref.watch(trainingRecordProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Training Record')),
      body: SafeArea(
        child: eligibility.when(
          loading: () => const Center(child: SizedBox.shrink()),
          error: (error, _) => const _LockedView(completed: 0, total: 0),
          data: (state) => state.record == null
              ? _LockedView(
                  completed: state.completedModules,
                  total: state.totalModules,
                )
              : _RecordView(
                  record: state.record!,
                  learnerName: ref.watch(userNameProvider),
                ),
        ),
      ),
    );
  }
}

class _RecordView extends StatelessWidget {
  const _RecordView({required this.record, required this.learnerName});

  final TrainingRecord record;
  final String learnerName;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        _Certificate(record: record, learnerName: learnerName),
        const SizedBox(height: 24),
        Text(
          'How the score is built',
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: context.palette.primary,
          ),
        ),
        const SizedBox(height: 12),
        _Component(
          label: 'Accuracy',
          weight: '40%',
          value: record.accuracy,
          note: 'Right on the first try, across every recorded session.',
        ),
        _Component(
          label: 'Speed',
          weight: '30%',
          value: record.speed,
          note:
              'Median response time against the four-second reflex target '
              '(${_formatSeconds(record.medianResponseTime)}).',
        ),
        _Component(
          label: 'Pattern mastery',
          weight: '25%',
          value: record.mastery,
          note: 'Share of grammar patterns that already count as reflex.',
        ),
        _Component(
          label: 'Consistency',
          weight: '5%',
          value: record.consistency,
          note: '${record.practiceDays} separate days of practice.',
        ),
      ],
    );
  }

  static String _formatSeconds(Duration duration) {
    if (duration == Duration.zero) return 'no data yet';

    return '${(duration.inMilliseconds / 1000).toStringAsFixed(1)} s';
  }
}

/// Kartu sertifikat. Dibuat sebagai widget terpisah agar nanti mudah ditangkap
/// menjadi gambar untuk dibagikan.
class _Certificate extends StatelessWidget {
  const _Certificate({required this.record, required this.learnerName});

  final TrainingRecord record;
  final String learnerName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: context.palette.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.palette.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.palette.surfaceAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '鳥',
                  style: TextStyle(
                    fontSize: 20,
                    color: context.palette.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'DILSENSEI TRAINING RECORD',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: context.palette.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'This record certifies that',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 14,
              color: context.palette.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            learnerName,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              color: context.palette.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'completed all ${record.totalModules} grammar reflex modules of the '
            'DilSensei Japanese drill programme, across '
            '${record.totalSessions} practice sessions.',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 15,
              height: 1.6,
              color: context.palette.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _ScoreBlock(score: record.score, tier: record.tier),
              ),
              const SizedBox(width: 12),
              Flexible(child: _IssuedBlock(issuedOn: record.issuedOn)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: context.palette.surfaceAccent.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'A record of practice completed inside DilSensei. '
              'It is not an official language qualification.',
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 11,
                height: 1.5,
                color: context.palette.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBlock extends StatelessWidget {
  const _ScoreBlock({required this.score, required this.tier});

  final int score;
  final RecordTier tier;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REFLEX SCORE',
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: context.palette.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(end: score.toDouble()),
              duration: context.motion(const Duration(milliseconds: 900)),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => Text(
                '${value.round()}',
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: context.palette.primary,
                ),
              ),
            ),
            Flexible(
              child: Text(
                ' / 100',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 14,
                  color: context.palette.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: context.palette.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            tierLabel(tier).toUpperCase(),
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: context.palette.onPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// Nama tingkatan, sengaja Inggris agar konsisten dengan isi sertifikat.
  static String tierLabel(RecordTier tier) => switch (tier) {
    RecordTier.reflex => 'Reflex',
    RecordTier.sharp => 'Sharp',
    RecordTier.steady => 'Steady',
    RecordTier.completed => 'Completed',
  };
}

class _IssuedBlock extends StatelessWidget {
  const _IssuedBlock({required this.issuedOn});

  final DateTime issuedOn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'ISSUED',
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: context.palette.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formatDate(issuedOn),
          textAlign: TextAlign.end,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.palette.textPrimary,
          ),
        ),
      ],
    );
  }

  static String formatDate(DateTime date) {
    // Bulan disingkat agar baris skor dan tanggal tetap muat di ponsel sempit.
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _Component extends StatelessWidget {
  const _Component({
    required this.label,
    required this.weight,
    required this.value,
    required this.note,
  });

  final String label;
  final String weight;
  final double value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.palette.textPrimary,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  '${(value * 100).round()}%  ·  weight $weight',
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 12,
                    color: context.palette.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: value),
              duration: context.motion(const Duration(milliseconds: 700)),
              curve: Curves.easeOutCubic,
              builder: (context, animated, _) => LinearProgressIndicator(
                value: animated,
                minHeight: 6,
                backgroundColor: context.palette.surfaceAccent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.palette.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            note,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 12,
              height: 1.5,
              color: context.palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedView extends StatelessWidget {
  const _LockedView({required this.completed, required this.total});

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium_outlined, size: 40),
            const SizedBox(height: 16),
            Text(
              'Your record is not ready yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: context.palette.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Finish a session in every module to unlock it. '
              '$completed of $total modules done so far.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 14,
                height: 1.6,
                color: context.palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
