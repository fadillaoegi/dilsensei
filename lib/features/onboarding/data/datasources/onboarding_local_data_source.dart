import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/onboarding_preferences.dart';

/// Penyimpanan preferensi onboarding.
class OnboardingLocalDataSource {
  const OnboardingLocalDataSource();

  static const _nameKey = 'dilsensei.onboarding.name';
  static const _goalKey = 'dilsensei.onboarding.goal';
  static const _targetKey = 'dilsensei.onboarding.daily_target_minutes';
  static const _completedKey = 'dilsensei.onboarding.completed';

  Future<OnboardingPreferences> read() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_completedKey) ?? false)) {
      return const OnboardingPreferences.empty();
    }

    return OnboardingPreferences(
      name: prefs.getString(_nameKey) ?? '',
      goal: _goalFrom(prefs.getString(_goalKey)),
      dailyTarget: _targetFrom(prefs.getInt(_targetKey)),
      isCompleted: true,
    );
  }

  Future<void> write(OnboardingPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_nameKey, preferences.name);
    await prefs.setString(_goalKey, preferences.goal.name);
    await prefs.setInt(_targetKey, preferences.dailyTarget.minutes);
    await prefs.setBool(_completedKey, preferences.isCompleted);
  }

  LearningGoal _goalFrom(String? value) {
    return LearningGoal.values
            .where((goal) => goal.name == value)
            .firstOrNull ??
        LearningGoal.culture;
  }

  DailyTarget _targetFrom(int? minutes) {
    return DailyTarget.values
            .where((target) => target.minutes == minutes)
            .firstOrNull ??
        DailyTarget.steady;
  }
}
