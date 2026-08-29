import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/learning_progress.dart';
import '../../domain/entities/pattern_event.dart';

/// Penyimpanan progres lokal berbasis SharedPreferences.
///
/// Cukup untuk kebutuhan sekarang: satu pengguna, tanpa akun, tanpa sinkronisasi.
class ProgressLocalDataSource {
  const ProgressLocalDataSource();

  static const _key = 'dilsensei.learning_progress.v1';

  /// Waktu respons yang diasumsikan untuk data lama yang tidak menyimpannya.
  static const _legacyResponseTime = Duration(seconds: 5);

  Future<LearningProgress> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const LearningProgress.empty();

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final lastDate = json['last_session_date'] as String?;
      final lastSessionDate = lastDate == null
          ? null
          : DateTime.parse(lastDate);

      return LearningProgress(
        streakDays: (json['streak_days'] as num?)?.toInt() ?? 0,
        lastSessionDate: lastSessionDate,
        totalSessions: (json['total_sessions'] as num?)?.toInt() ?? 0,
        bestReflexScore: (json['best_reflex_score'] as num?)?.toInt() ?? 0,
        patternEvents: _eventsFrom(
          json['pattern_events'],
          legacyCounts: json['pattern_miss_counts'],
          legacyDate: lastSessionDate,
        ),
        sessionsToday: (json['sessions_today'] as num?)?.toInt() ?? 0,
        recentSessions: _recordsFrom(json['recent_sessions']),
        completedModuleIds: _moduleIdsFrom(json['completed_module_ids']),
      );
    } on Object {
      // Data rusak tidak boleh membuat app gagal dibuka.
      return const LearningProgress.empty();
    }
  }

  Future<void> write(LearningProgress progress) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _key,
      jsonEncode(<String, dynamic>{
        'streak_days': progress.streakDays,
        'last_session_date': _dateToString(progress.lastSessionDate),
        'total_sessions': progress.totalSessions,
        'best_reflex_score': progress.bestReflexScore,
        'sessions_today': progress.sessionsToday,
        'completed_module_ids': progress.completedModuleIds.toList(
          growable: false,
        ),
        'pattern_events': progress.patternEvents
            .map(
              (event) => <String, dynamic>{
                'pattern_id': event.patternId,
                'date': _dateToString(event.date),
                'was_correct': event.wasCorrect,
                'response_ms': event.responseTime.inMilliseconds,
              },
            )
            .toList(growable: false),
        'recent_sessions': progress.recentSessions
            .map(
              (record) => <String, dynamic>{
                'date': _dateToString(record.date),
                'reflex_score': record.reflexScore,
                'first_try_correct': record.firstTryCorrect,
                'planned_count': record.plannedCount,
              },
            )
            .toList(growable: false),
      }),
    );
  }

  /// Membaca peristiwa pola.
  ///
  /// Bila hanya ada data format lama (`pattern_miss_counts`), hitungannya
  /// diubah menjadi peristiwa bertanggal supaya peta kelemahan pengguna lama
  /// tidak hilang setelah pembaruan.
  List<PatternEvent> _eventsFrom(
    Object? value, {
    required Object? legacyCounts,
    required DateTime? legacyDate,
  }) {
    if (value is List && value.isNotEmpty) {
      final events = <PatternEvent>[];
      for (final entry in value) {
        if (entry is! Map) continue;

        final patternId = entry['pattern_id'] as String?;
        final date = entry['date'] as String?;
        if (patternId == null || date == null) continue;

        events.add(
          PatternEvent(
            patternId: patternId,
            date: DateTime.parse(date),
            wasCorrect: entry['was_correct'] as bool? ?? false,
            responseTime: Duration(
              milliseconds: (entry['response_ms'] as num?)?.toInt() ?? 0,
            ),
          ),
        );
      }

      return List<PatternEvent>.unmodifiable(events);
    }

    if (legacyCounts is! Map) return const <PatternEvent>[];

    final migrated = <PatternEvent>[];
    legacyCounts.forEach((key, count) {
      final misses = (count as num?)?.toInt() ?? 0;
      for (var i = 0; i < misses; i++) {
        migrated.add(
          PatternEvent(
            patternId: key as String,
            date: legacyDate ?? DateTime(2026),
            wasCorrect: false,
            responseTime: _legacyResponseTime,
          ),
        );
      }
    });

    return List<PatternEvent>.unmodifiable(migrated);
  }

  Set<String> _moduleIdsFrom(Object? value) {
    if (value is! List) return const <String>{};

    return Set<String>.unmodifiable(value.whereType<String>());
  }

  List<SessionRecord> _recordsFrom(Object? value) {
    if (value is! List) return const <SessionRecord>[];

    final records = <SessionRecord>[];
    for (final entry in value) {
      if (entry is! Map) continue;

      final date = entry['date'] as String?;
      if (date == null) continue;

      records.add(
        SessionRecord(
          date: DateTime.parse(date),
          reflexScore: (entry['reflex_score'] as num?)?.toInt() ?? 0,
          firstTryCorrect: (entry['first_try_correct'] as num?)?.toInt() ?? 0,
          plannedCount: (entry['planned_count'] as num?)?.toInt() ?? 0,
        ),
      );
    }

    return List<SessionRecord>.unmodifiable(records);
  }

  static String? _dateToString(DateTime? date) {
    if (date == null) return null;

    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
