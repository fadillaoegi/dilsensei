import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/learning_progress.dart';

/// Penyimpanan progres lokal berbasis SharedPreferences.
///
/// Cukup untuk kebutuhan sekarang: satu pengguna, tanpa akun, tanpa sinkronisasi.
class ProgressLocalDataSource {
  const ProgressLocalDataSource();

  static const _key = 'dilsensei.learning_progress.v1';

  Future<LearningProgress> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const LearningProgress.empty();

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final lastDate = json['last_session_date'] as String?;

      return LearningProgress(
        streakDays: (json['streak_days'] as num?)?.toInt() ?? 0,
        lastSessionDate: lastDate == null ? null : DateTime.parse(lastDate),
        totalSessions: (json['total_sessions'] as num?)?.toInt() ?? 0,
        bestReflexScore: (json['best_reflex_score'] as num?)?.toInt() ?? 0,
        patternMissCounts: Map<String, int>.unmodifiable(
          (json['pattern_miss_counts'] as Map<String, dynamic>? ??
                  const <String, dynamic>{})
              .map((key, value) => MapEntry(key, (value as num).toInt())),
        ),
      );
    } on Object {
      // Data rusak tidak boleh membuat app gagal dibuka.
      return const LearningProgress.empty();
    }
  }

  Future<void> write(LearningProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = progress.lastSessionDate;

    await prefs.setString(
      _key,
      jsonEncode(<String, dynamic>{
        'streak_days': progress.streakDays,
        'last_session_date': lastDate == null
            ? null
            : '${lastDate.year.toString().padLeft(4, '0')}-'
                  '${lastDate.month.toString().padLeft(2, '0')}-'
                  '${lastDate.day.toString().padLeft(2, '0')}',
        'total_sessions': progress.totalSessions,
        'best_reflex_score': progress.bestReflexScore,
        'pattern_miss_counts': progress.patternMissCounts,
      }),
    );
  }
}
