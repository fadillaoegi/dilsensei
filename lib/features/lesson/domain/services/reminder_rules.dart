import '../entities/pattern_event.dart';
import 'pattern_insights.dart';
import 'progress_rules.dart';

/// Jenis pesan pengingat yang dipilih aturan.
///
/// Urutannya juga urutan prioritas: pesan yang paling spesifik menang, karena
/// "partikel tempat masih sering meleset" jauh lebih berguna daripada
/// "jangan lupa belajar".
enum ReminderTone {
  /// Ada pola yang sering salah.
  weakAccuracy,

  /// Ada pola yang benar tapi lambat.
  weakSpeed,

  /// Streak sedang berjalan dan hari ini belum berlatih.
  streakAtRisk,

  /// Belum ada data sama sekali, misalnya pengguna baru.
  firstSession,

  /// Sudah berlatih hari ini; tidak perlu diganggu.
  none,
}

/// Rencana satu pengingat.
class ReminderPlan {
  const ReminderPlan({
    required this.tone,
    required this.scheduledFor,
    this.patternId,
  });

  final ReminderTone tone;

  /// Waktu tayang berikutnya.
  final DateTime scheduledFor;

  /// Pola yang disebut pesan, bila ada.
  final String? patternId;

  bool get shouldSchedule => tone != ReminderTone.none;
}

/// Aturan pengingat harian.
///
/// Murni dan tanpa I/O supaya perilakunya bisa diuji tanpa perangkat: satu-satunya
/// masukan adalah riwayat pola, status latihan hari ini, dan jam yang dipilih.
abstract final class ReminderRules {
  /// Jam tayang bawaan bila pengguna belum memilih.
  static const defaultHour = 19;
  static const defaultMinute = 0;

  /// Menentukan rencana pengingat berikutnya.
  ///
  /// [practisedToday] membuat pengingat dilewati: mengingatkan orang yang sudah
  /// berlatih hanya akan membuat notifikasi terasa mengganggu.
  static ReminderPlan plan({
    required List<PatternEvent> events,
    required bool practisedToday,
    required int streakDays,
    required DateTime now,
    int hour = defaultHour,
    int minute = defaultMinute,
  }) {
    final scheduledFor = nextOccurrence(
      now: now,
      hour: hour,
      minute: minute,
      skipToday: practisedToday,
    );

    if (practisedToday) {
      return ReminderPlan(tone: ReminderTone.none, scheduledFor: scheduledFor);
    }

    final weak = PatternInsights.needingWork(events: events, now: now);
    if (weak.isNotEmpty) {
      final worst = weak.first;

      return ReminderPlan(
        tone: worst.weakness == PatternWeakness.speed
            ? ReminderTone.weakSpeed
            : ReminderTone.weakAccuracy,
        scheduledFor: scheduledFor,
        patternId: worst.patternId,
      );
    }

    if (events.isEmpty) {
      return ReminderPlan(
        tone: ReminderTone.firstSession,
        scheduledFor: scheduledFor,
      );
    }

    return ReminderPlan(
      tone: streakDays > 0
          ? ReminderTone.streakAtRisk
          : ReminderTone.firstSession,
      scheduledFor: scheduledFor,
      patternId: null,
    );
  }

  /// Waktu tayang berikutnya pada jam yang dipilih.
  ///
  /// Bila jamnya sudah lewat hari ini — atau pengguna sudah berlatih — jadwalnya
  /// pindah ke besok.
  static DateTime nextOccurrence({
    required DateTime now,
    required int hour,
    required int minute,
    bool skipToday = false,
  }) {
    final todayAtTime = DateTime(now.year, now.month, now.day, hour, minute);
    if (!skipToday && todayAtTime.isAfter(now)) return todayAtTime;

    final tomorrow = ProgressRules.dateOnly(now.add(const Duration(days: 1)));

    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, hour, minute);
  }
}
