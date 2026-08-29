import 'package:dilsensei/features/lesson/domain/entities/pattern_event.dart';
import 'package:dilsensei/features/lesson/domain/services/pattern_insights.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 9, 1, 12);

PatternEvent _event(
  String patternId, {
  required bool correct,
  int daysAgo = 0,
  int seconds = 3,
}) {
  return PatternEvent(
    patternId: patternId,
    date: DateTime(2026, 9, 1).subtract(Duration(days: daysAgo)),
    wasCorrect: correct,
    responseTime: Duration(seconds: seconds),
  );
}

PatternInsight _insightFor(List<PatternEvent> events, String patternId) {
  return PatternInsights.from(
    events: events,
    now: _now,
  ).firstWhere((insight) => insight.patternId == patternId);
}

void main() {
  group('pemudaran kesalahan lama', () {
    test('kesalahan hari ini lebih berat daripada kesalahan minggu lalu', () {
      final fresh = <PatternEvent>[
        for (var i = 0; i < 4; i++) _event('fresh', correct: true),
        _event('fresh', correct: false),
      ];
      final stale = <PatternEvent>[
        for (var i = 0; i < 4; i++) _event('stale', correct: true, daysAgo: 21),
        _event('stale', correct: false, daysAgo: 21),
      ];

      final freshRisk = _insightFor(fresh, 'fresh').riskScore;
      final staleRisk = _insightFor(stale, 'stale').riskScore;

      expect(
        freshRisk,
        greaterThan(staleRisk),
        reason: 'peta harus mencerminkan kondisi sekarang',
      );
    });

    test('pola yang lama tidak disentuh mengendur ke arah prior', () {
      // Lima kesalahan berturut-turut, tapi semuanya 28 hari lalu.
      final events = <PatternEvent>[
        for (var i = 0; i < 5; i++) _event('old', correct: false, daysAgo: 28),
      ];

      final insight = _insightFor(events, 'old');

      expect(insight.missCount, 5);
      expect(
        insight.riskScore,
        lessThan(0.6),
        reason: 'bobot empat kali umur paruh sudah sangat kecil',
      );
    });
  });

  group('waktu respons', () {
    test('selalu benar tapi lambat tetap dianggap belum refleks', () {
      final events = <PatternEvent>[
        for (var i = 0; i < 8; i++) _event('slow', correct: true, seconds: 12),
      ];

      final insight = _insightFor(events, 'slow');

      expect(insight.missCount, 0);
      expect(insight.slowCount, 8);
      expect(insight.weakness, PatternWeakness.speed);
      expect(insight.medianResponseTime, const Duration(seconds: 12));
    });

    test('benar dan cepat dianggap sudah jadi refleks', () {
      final events = <PatternEvent>[
        for (var i = 0; i < 8; i++) _event('fast', correct: true, seconds: 2),
      ];

      final insight = _insightFor(events, 'fast');

      expect(insight.weakness, PatternWeakness.none);
      expect(insight.mastery, greaterThan(0.7));
    });

    test('ambang lambat berada di 7 detik', () {
      final borderline = _insightFor(<PatternEvent>[
        for (var i = 0; i < 6; i++) _event('edge', correct: true, seconds: 6),
      ], 'edge');
      final overThreshold = _insightFor(<PatternEvent>[
        for (var i = 0; i < 6; i++) _event('over', correct: true, seconds: 8),
      ], 'over');

      expect(borderline.slowCount, 0);
      expect(overThreshold.slowCount, 6);
    });
  });

  group('penghalusan data tipis', () {
    test(
      'satu kesalahan dari satu percobaan tidak melompati pola bermasalah',
      () {
        final events = <PatternEvent>[
          // Baru dicoba sekali, langsung salah.
          _event('thin', correct: false),
          // Dicoba dua puluh kali, delapan di antaranya salah.
          for (var i = 0; i < 12; i++) _event('thick', correct: true),
          for (var i = 0; i < 8; i++) _event('thick', correct: false),
        ];

        final ranked = PatternInsights.from(events: events, now: _now);

        expect(
          ranked.first.patternId,
          'thick',
          reason: 'pola dengan bukti lebih banyak harus diprioritaskan',
        );
        expect(_insightFor(events, 'thin').weakness, PatternWeakness.accuracy);
      },
    );

    test('tanpa data sama sekali menghasilkan daftar kosong', () {
      expect(
        PatternInsights.from(events: const <PatternEvent>[], now: _now),
        isEmpty,
      );
    });
  });

  group('peringkat dan penyaringan', () {
    test('daftar terurut dari risiko tertinggi', () {
      final events = <PatternEvent>[
        for (var i = 0; i < 5; i++) _event('bad', correct: false),
        for (var i = 0; i < 5; i++) _event('mid', correct: true, seconds: 11),
        for (var i = 0; i < 5; i++) _event('good', correct: true, seconds: 2),
      ];

      final ranked = PatternInsights.from(
        events: events,
        now: _now,
      ).map((insight) => insight.patternId).toList();

      expect(ranked, ['bad', 'mid', 'good']);
    });

    test('needingWork hanya memuat pola yang masih bermasalah', () {
      final events = <PatternEvent>[
        for (var i = 0; i < 5; i++) _event('bad', correct: false),
        for (var i = 0; i < 8; i++) _event('good', correct: true, seconds: 2),
      ];

      final weak = PatternInsights.needingWork(
        events: events,
        now: _now,
      ).map((insight) => insight.patternId).toList();

      expect(weak, ['bad']);
    });
  });
}
