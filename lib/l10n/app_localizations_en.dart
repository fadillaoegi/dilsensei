// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DilSensei';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get commonNext => 'Continue';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDone => 'Done';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonClose => 'Close';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonReload => 'Reload';

  @override
  String get commonSeePro => 'See Pro plans';

  @override
  String get onboardingNameTitle => 'Let\'s start with\nyour name';

  @override
  String get onboardingNameSubtitle =>
      'We use it to greet you every time you open a session.';

  @override
  String get onboardingNameHint => 'Nickname';

  @override
  String get onboardingGoalTitle => 'Why are you\nlearning Japanese?';

  @override
  String get onboardingGoalSubtitle =>
      'This decides which phrases you drill first.';

  @override
  String get onboardingTargetTitle => 'How many minutes\na day?';

  @override
  String get onboardingTargetSubtitle =>
      'Reflexes grow from short routines you don\'t skip.';

  @override
  String get onboardingStart => 'Start practising';

  @override
  String get goalWorkLabel => 'For work';

  @override
  String get goalWorkDescription => 'Office phrases, reporting, and team talk';

  @override
  String get goalTravelLabel => 'For travel';

  @override
  String get goalTravelDescription =>
      'Asking directions, ordering, and shopping';

  @override
  String get goalCultureLabel => 'For anime & culture';

  @override
  String get goalCultureDescription =>
      'Everyday conversation that sounds natural';

  @override
  String get goalExamLabel => 'For exams';

  @override
  String get goalExamDescription => 'Grammar patterns that show up in the JLPT';

  @override
  String get targetLightLabel => 'Light';

  @override
  String get targetLightDescription => 'Enough to keep your streak';

  @override
  String get targetSteadyLabel => 'Steady';

  @override
  String get targetSteadyDescription => 'Most people pick this';

  @override
  String get targetIntenseLabel => 'Serious';

  @override
  String get targetIntenseDescription => 'For anyone on a deadline';

  @override
  String targetMinutes(int minutes, String label) {
    return '$minutes minutes · $label';
  }

  @override
  String homeGreeting(String name) {
    return 'Konnichiwa, $name!';
  }

  @override
  String get homeGreetingFallbackName => 'Sensei';

  @override
  String get homeSubtitle => 'Time to train your muscle memory';

  @override
  String homeStreakSemantics(int days) {
    return '$days day streak';
  }

  @override
  String get homeTodayLabel => 'TODAY\'S MODULE';

  @override
  String homeStartSession(int minutes) {
    return 'Start session ($minutes min)';
  }

  @override
  String get homeRoadmapTitle => 'Your roadmap';

  @override
  String get homeLoading => 'Preparing your session...';

  @override
  String get homeErrorTitle => 'Couldn\'t load the lessons';

  @override
  String get homeErrorBody => 'Check your connection, then try again.';

  @override
  String homeMinutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get homePremiumSemantics => 'Premium module, subscription required';

  @override
  String get homeInsightsTooltip => 'Weak spots';

  @override
  String get homeSettingsTooltip => 'Settings';

  @override
  String get dailyLimitTitle => 'That\'s today\'s session';

  @override
  String get dailyLimitBody =>
      'The free plan gives you one session a day. Reflexes come from repetition, and Pro unlocks as many sessions as you want — including sessions built from your weak spots.';

  @override
  String get dailyLimitLater => 'Tomorrow then';

  @override
  String get sessionAssembleLabel => 'BUILD IT IN JAPANESE';

  @override
  String get sessionParticleLabel => 'COMPLETE THE PARTICLE';

  @override
  String get sessionTransformLabel => 'CHANGE THE FORM';

  @override
  String get sessionCanvasHint => 'Tap the word chips to build your answer';

  @override
  String get sessionCheck => 'Check';

  @override
  String get sessionContinue => 'Continue';

  @override
  String get sessionSeeResult => 'See result';

  @override
  String get sessionExitTooltip => 'Leave session';

  @override
  String get sessionLoading => 'Preparing your drills...';

  @override
  String get sessionEmpty => 'This module has no drills yet.';

  @override
  String get sessionErrorTitle => 'Couldn\'t load the drills';

  @override
  String get feedbackCorrect => 'Nailed it.';

  @override
  String get feedbackWrongRepeat => 'Not quite — this one comes back later.';

  @override
  String get feedbackWrongMovedOn =>
      'Not quite. Saved for tomorrow\'s session.';

  @override
  String feedbackPatternToPractise(String patterns) {
    return 'Pattern to practise: $patterns';
  }

  @override
  String get summaryTitle => 'Session complete';

  @override
  String get summaryReflexScore => 'reflex score';

  @override
  String get summaryFirstTry => 'Right first try';

  @override
  String get summaryResponseTime => 'Response time';

  @override
  String summarySeconds(String seconds) {
    return '$seconds s';
  }

  @override
  String get summaryNoData => '—';

  @override
  String get summaryWeakTitle => 'Patterns that aren\'t reflex yet';

  @override
  String get summaryClean => 'All clean.';

  @override
  String get summaryCleanBody =>
      'No pattern went wrong this session. The next module raises the tempo.';

  @override
  String get summaryDrillWeak => 'Drill your weak spots now';

  @override
  String get insightsTitle => 'Weak spots';

  @override
  String get insightsTotalSessions => 'Total sessions';

  @override
  String get insightsBestScore => 'Best score';

  @override
  String get insightsPatternsTitle => 'Patterns you miss most';

  @override
  String get insightsPatternsSubtitle =>
      'Recent mistakes count more than old ones, and answers that are right but slow still count.';

  @override
  String insightsReasonAccuracy(int count) {
    return '$count wrong';
  }

  @override
  String insightsReasonSlow(int count) {
    return '$count slow';
  }

  @override
  String get insightsReasonSolid => 'Solid';

  @override
  String insightsMastery(int percent) {
    return '$percent% mastered';
  }

  @override
  String get insightsStrongTitle => 'Already reflex';

  @override
  String get insightsNoPatterns =>
      'No pattern has gone wrong yet. Finish a few more sessions to see the map.';

  @override
  String get insightsProgressTitle => 'Reflex score over time';

  @override
  String get insightsHistoryLocked => 'Progress history unlocks with Pro.';

  @override
  String get insightsHistoryEmpty =>
      'History appears after your first session.';

  @override
  String insightsHiddenPatterns(int count) {
    return '$count more patterns are hidden on the free plan.';
  }

  @override
  String get insightsEmptyTitle => 'Nothing to map yet';

  @override
  String get insightsEmptyBody =>
      'Finish one session, then come back to see which patterns aren\'t reflex yet.';

  @override
  String insightsAccuracy(int percent) {
    return '$percent% right';
  }

  @override
  String insightsMissCount(int count) {
    return '${count}x';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsFreePlan => 'Free plan';

  @override
  String get settingsProActive => 'Pro access active';

  @override
  String settingsDailyTarget(int minutes) {
    return 'Daily target: $minutes minutes';
  }

  @override
  String settingsSessionsToday(int count) {
    return 'Sessions today: $count';
  }

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get settingsSectionPractice => 'Practice';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get themeSystem => 'Match device';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsThemeSubtitle => 'Currently active';

  @override
  String get settingsSectionSubscription => 'Subscription';

  @override
  String get settingsSectionLegal => 'Legal';

  @override
  String get settingsSectionDevelopment => 'Development';

  @override
  String get settingsLanguageSubtitle => 'Interface and lesson prompts';

  @override
  String get settingsRestore => 'Restore purchases';

  @override
  String get settingsRestoreSubtitle =>
      'Recover your subscription after switching devices';

  @override
  String get settingsManage => 'Manage subscription';

  @override
  String get settingsManageSubtitle => 'Change or cancel through Google Play';

  @override
  String get settingsPrivacy => 'Privacy Policy';

  @override
  String get settingsTerms => 'Terms of Use';

  @override
  String get settingsDevToggle => 'DEV: Force Pro access';

  @override
  String get settingsDevToggleBody =>
      'Unlocks every module and unlimited sessions without a purchase, for testing only. Never shown in release builds.';

  @override
  String get settingsRestoreSuccess => 'Subscription restored.';

  @override
  String get settingsRestoreEmpty => 'No subscription to restore.';

  @override
  String settingsCannotOpen(String url) {
    return 'Couldn\'t open $url';
  }

  @override
  String get paywallHeadline => 'Unlock\nyour full\npotential';

  @override
  String get paywallBody =>
      'Don\'t let your muscle memory fade. Drill the patterns that still make you hesitate, until Japanese comes out without thinking.';

  @override
  String get paywallBenefitModules =>
      'Every module and unlimited daily sessions';

  @override
  String get paywallBenefitMap => 'The full weak-spot map, not a summary';

  @override
  String get paywallBenefitAuto =>
      'Sessions built automatically from your weak patterns';

  @override
  String get paywallBenefitHistory =>
      'Reflex score history and weekly progress';

  @override
  String get paywallCta => 'Start subscription';

  @override
  String get paywallRestore => 'Restore purchases';

  @override
  String get paywallDisclosure =>
      'Subscriptions renew automatically until cancelled. Cancel any time in your store account settings.';

  @override
  String get paywallPricesLoading => 'Fetching prices from the store...';

  @override
  String get paywallPricesErrorTitle => 'Prices unavailable';

  @override
  String get paywallPricesErrorBody =>
      'Check your connection, then reload the plans.';

  @override
  String get paywallPurchaseSuccess => 'Subscription active. Happy drilling!';

  @override
  String get paywallPurchaseFailed => 'Purchase failed.';

  @override
  String get paywallTestStore => 'TEST STORE MODE — purchases are not charged';

  @override
  String get paywallRecommended => 'SAVE';

  @override
  String paywallSavePercent(int percent) {
    return 'Save $percent%';
  }

  @override
  String get planPeriodWeekly => '/ week';

  @override
  String get planPeriodMonthly => '/ month';

  @override
  String get planPeriodAnnual => '/ year';

  @override
  String get planPeriodLifetime => 'one-time';

  @override
  String get planTitleWeekly => 'Weekly plan';

  @override
  String get planTitleMonthly => 'Monthly plan';

  @override
  String get planTitleAnnual => 'Annual plan';

  @override
  String get planTitleLifetime => 'Lifetime access';

  @override
  String planTrialFree(int count, String unit) {
    return '$count $unit free';
  }

  @override
  String get planUnitDay => 'day';

  @override
  String get planUnitWeek => 'week';

  @override
  String get planUnitMonth => 'month';

  @override
  String get planUnitYear => 'year';

  @override
  String get patternParticlePlace => 'Place particle';

  @override
  String get patternParticleObject => 'Object particle';

  @override
  String get patternParticleTopic => 'Topic particle';

  @override
  String get patternWordOrderTime => 'Time expression order';

  @override
  String get patternPoliteForm => 'Polite form';

  @override
  String get patternPastForm => 'Past form';

  @override
  String get patternNegativeForm => 'Negative form';

  @override
  String get patternCounterWord => 'Counter word';

  @override
  String get kanaSectionTitle => 'Refresh the letters first';

  @override
  String get kanaSectionSubtitle => 'Free reference, no session needed';

  @override
  String get kanaFreeBadge => 'FREE';

  @override
  String get kanaHiragana => 'Hiragana';

  @override
  String get kanaKatakana => 'Katakana';

  @override
  String kanaLetterCount(int count) {
    return '$count letters';
  }

  @override
  String get kanaSectionBase => 'Gojūon · 46 base letters';

  @override
  String get kanaSectionVoiced => 'Dakuten · voiced letters';

  @override
  String get kanaSectionCombined => 'Yōon · combinations';

  @override
  String get kanaUsageTitle => 'When do you use it?';

  @override
  String get kanaHiraganaUsage =>
      'Hiragana is the base script. Use it for native Japanese words, for particles like は and を, and for the verb endings that keep changing shape. When you don\'t know the kanji for a word, hiragana is the safe fallback that everyone still reads.';

  @override
  String get kanaKatakanaUsage =>
      'Katakana marks words that arrived from outside Japanese — コーヒー for coffee, パソコン for a computer, and foreign names including yours. You will also meet it on menus, packaging, and signage, and it is used for emphasis the way italics work in English.';

  @override
  String get kanaTipTitle => 'Reading it faster';

  @override
  String get kanaTipBody =>
      'Read across the rows, not down the columns: the consonant stays and only the vowel changes. Once a row feels automatic, move to the next one instead of trying to memorise the whole chart at once.';

  @override
  String homeGreetingMorning(String name) {
    return 'Ohayou, $name!';
  }

  @override
  String homeGreetingMidday(String name) {
    return 'Konnichiwa, $name!';
  }

  @override
  String homeGreetingAfternoon(String name) {
    return 'Konnichiwa, $name!';
  }

  @override
  String homeGreetingEvening(String name) {
    return 'Konbanwa, $name!';
  }

  @override
  String get homeSubtitleMorning =>
      'A short session now sets the tone for the day';

  @override
  String get homeSubtitleMidday => 'Ten minutes between tasks is enough';

  @override
  String get homeSubtitleAfternoon =>
      'Beat the afternoon slump with one quick drill';

  @override
  String get homeSubtitleEvening =>
      'Close the day by locking in what you practised';

  @override
  String get settingsSectionReminder => 'Daily reminder';

  @override
  String get settingsReminderToggle => 'Remind me to practise';

  @override
  String get settingsReminderToggleBody =>
      'One notification a day, skipped automatically when you have already practised.';

  @override
  String get settingsReminderTime => 'Reminder time';

  @override
  String settingsReminderTimeValue(String time) {
    return 'Every day at $time';
  }

  @override
  String get settingsReminderPermissionDenied =>
      'Notifications are turned off for DilSensei. Enable them in your system settings.';

  @override
  String reminderTitleWeakAccuracy(String pattern) {
    return '$pattern is still slipping';
  }

  @override
  String get reminderBodyWeakAccuracy =>
      'Three minutes is enough to turn it around. Want to drill just that pattern?';

  @override
  String reminderTitleWeakSpeed(String pattern) {
    return '$pattern is right but slow';
  }

  @override
  String get reminderBodyWeakSpeed =>
      'Correct is not the same as reflex. One quick session tightens it up.';

  @override
  String get reminderTitleStreak => 'Your streak is waiting';

  @override
  String get reminderBodyStreak =>
      'One session keeps it alive. It takes less time than scrolling.';

  @override
  String get reminderTitleFirst => 'Ready for your first drill?';

  @override
  String get reminderBodyFirst =>
      'Five minutes, one module, and you will already feel the rhythm.';

  @override
  String get recordUnlockedCta => 'See your Training Record';

  @override
  String get recordEntryTitle => 'Training Record';

  @override
  String get recordEntrySubtitle => 'Proof that you finished every module';

  @override
  String recordEntryLocked(int completed, int total) {
    return '$completed of $total modules done';
  }

  @override
  String get purchaseErrorPlanNotFound =>
      'That plan is not available right now.';

  @override
  String get purchaseErrorNotActive => 'The subscription is not active yet.';

  @override
  String get purchaseErrorStore => 'The store could not complete the purchase.';

  @override
  String get purchaseErrorNotConfigured =>
      'Purchases are not available in this build.';

  @override
  String get updateAvailableTitle => 'Update available';

  @override
  String get updateAvailableBody =>
      'A newer version of DilSensei is on Google Play.';

  @override
  String get updateAction => 'Update';

  @override
  String get updateDismiss => 'Later';

  @override
  String get updateDownloadingTitle => 'Downloading update';

  @override
  String get updateDownloadingBody =>
      'You can keep practising while it downloads.';

  @override
  String get updateReadyTitle => 'Update ready';

  @override
  String get updateReadyBody => 'Restart the app to finish installing.';

  @override
  String get updateReadyAction => 'Restart';

  @override
  String get updateFailedTitle => 'Update could not start';

  @override
  String get updateFailedBody =>
      'Open DilSensei on Google Play to update manually.';

  @override
  String get updateFailedAction => 'Open Google Play';

  @override
  String get diagnosticsTitle => 'Diagnostics';

  @override
  String get diagnosticsSubtitle => 'Technical log for this session';

  @override
  String get diagnosticsCopy => 'Copy all';

  @override
  String get diagnosticsClear => 'Clear';

  @override
  String get diagnosticsCopied => 'Log copied to clipboard';

  @override
  String get diagnosticsEmpty =>
      'Nothing recorded yet. Open the paywall to capture subscription activity.';

  @override
  String get practicePreferencesTitle => 'Practice preferences';

  @override
  String get practicePreferencesSubtitle =>
      'Change these whenever your reason for learning changes. Your progress and streak are kept.';

  @override
  String get practicePreferencesEntry => 'Goal & daily target';

  @override
  String get practicePreferencesError => 'Could not load your preferences.';
}
