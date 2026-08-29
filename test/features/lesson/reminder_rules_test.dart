import 'package:dilsensei/features/lesson/domain/entities/pattern_event.dart';
import 'package:dilsensei/features/lesson/domain/services/reminder_rules.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 9, 1, 10, 0);

PatternEvent _event(
  String patternId, {
  required bool correct,
  int seconds = 3,
  int daysAgo = 0,
}) {
  return PatternEvent(
    patternId: patternId,
    date: DateTime(2026, 9, 1).subtract(Duration(days: daysAgo)),
    wasCorrect: correct,
    responseTime: Duration(seconds: seconds),
  );
}

ReminderPlan _plan({
  List<PatternEvent> events = const <PatternEvent>[],
  bool practisedToday = false,
  int streakDays = 0,
  DateTime? now,
  int hour = ReminderRules.defaultHour,
}) {
  return ReminderRules.plan(
    events: events,
    practisedToday: practisedToday,
    streakDays: streakDays,
    now: now ?? _now,
    hour: hour,
  );
}

void main() {
  group('pemilihan pesan', () {
    test('pola yang sering salah menang atas pesan generik', () {
      final plan = _plan(
        events: <PatternEvent>[
          for (var i = 0; i < 5; i++) _event('particle_place', correct: false),
        ],
        streakDays: 4,
      );

      expect(plan.tone, ReminderTone.weakAccuracy);
      expect(plan.patternId, 'particle_place');
      expect(plan.shouldSchedule, isTrue);
    });

    test('pola benar tapi lambat memakai nada kecepatan', () {
      final plan = _plan(
        events: <PatternEvent>[
          for (var i = 0; i < 8; i++)
            _event('past_form', correct: true, seconds: 12),
        ],
      );

      expect(plan.tone, ReminderTone.weakSpeed);
      expect(plan.patternId, 'past_form');
    });

    test('tanpa riwayat sama sekali memakai nada sesi pertama', () {
      expect(_plan().tone, ReminderTone.firstSession);
    });

    test('sudah kuat tapi streak berjalan memakai nada streak', () {
      final plan = _plan(
        events: <PatternEvent>[
          for (var i = 0; i < 8; i++)
            _event('polite_form', correct: true, seconds: 2),
        ],
        streakDays: 6,
      );

      expect(plan.tone, ReminderTone.streakAtRisk);
      expect(plan.patternId, isNull);
    });

    test('kesalahan lama tidak lagi memicu pesan pola', () {
      final plan = _plan(
        events: <PatternEvent>[
          for (var i = 0; i < 5; i++)
            _event('counter_word', correct: false, daysAgo: 28),
        ],
        streakDays: 2,
      );

      expect(
        plan.tone,
        ReminderTone.streakAtRisk,
        reason: 'pola yang memudar tidak layak disebut lagi',
      );
    });
  });

  group('melewati pengingat', () {
    test('sudah berlatih hari ini tidak dijadwalkan', () {
      final plan = _plan(
        events: <PatternEvent>[_event('particle_place', correct: false)],
        practisedToday: true,
        streakDays: 3,
      );

      expect(plan.tone, ReminderTone.none);
      expect(plan.shouldSchedule, isFalse);
    });

    test('yang sudah berlatih dijadwalkan untuk besok', () {
      final plan = _plan(practisedToday: true, hour: 19);

      expect(plan.scheduledFor, DateTime(2026, 9, 2, 19));
    });
  });

  group('waktu tayang', () {
    test('jam yang belum lewat dijadwalkan hari ini', () {
      expect(_plan(hour: 19).scheduledFor, DateTime(2026, 9, 1, 19));
    });

    test('jam yang sudah lewat dijadwalkan besok', () {
      final plan = _plan(now: DateTime(2026, 9, 1, 20, 30), hour: 19);

      expect(plan.scheduledFor, DateTime(2026, 9, 2, 19));
    });

    test('tepat pada jamnya dianggap sudah lewat', () {
      final plan = _plan(now: DateTime(2026, 9, 1, 19), hour: 19);

      expect(plan.scheduledFor, DateTime(2026, 9, 2, 19));
    });

    test('menghormati menit yang dipilih', () {
      final next = ReminderRules.nextOccurrence(
        now: DateTime(2026, 9, 1, 7),
        hour: 8,
        minute: 45,
      );

      expect(next, DateTime(2026, 9, 1, 8, 45));
    });

    test('pergantian bulan tetap benar', () {
      final next = ReminderRules.nextOccurrence(
        now: DateTime(2026, 9, 30, 23),
        hour: 7,
        minute: 0,
      );

      expect(next, DateTime(2026, 10, 1, 7));
    });
  });
}
