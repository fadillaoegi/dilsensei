import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/services/reminder_rules.dart';

/// Preferensi pengingat harian.
class ReminderPreferences {
  const ReminderPreferences({
    required this.isEnabled,
    required this.hour,
    required this.minute,
  });

  const ReminderPreferences.defaults()
    : isEnabled = false,
      hour = ReminderRules.defaultHour,
      minute = ReminderRules.defaultMinute;

  final bool isEnabled;
  final int hour;
  final int minute;

  ReminderPreferences copyWith({bool? isEnabled, int? hour, int? minute}) {
    return ReminderPreferences(
      isEnabled: isEnabled ?? this.isEnabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }
}

/// Penyimpanan preferensi pengingat.
class ReminderLocalDataSource {
  const ReminderLocalDataSource();

  static const _enabledKey = 'dilsensei.reminder.enabled';
  static const _hourKey = 'dilsensei.reminder.hour';
  static const _minuteKey = 'dilsensei.reminder.minute';

  Future<ReminderPreferences> read() async {
    final prefs = await SharedPreferences.getInstance();

    return ReminderPreferences(
      isEnabled: prefs.getBool(_enabledKey) ?? false,
      hour: prefs.getInt(_hourKey) ?? ReminderRules.defaultHour,
      minute: prefs.getInt(_minuteKey) ?? ReminderRules.defaultMinute,
    );
  }

  Future<void> write(ReminderPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_enabledKey, preferences.isEnabled);
    await prefs.setInt(_hourKey, preferences.hour);
    await prefs.setInt(_minuteKey, preferences.minute);
  }
}
