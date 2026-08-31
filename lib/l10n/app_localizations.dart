import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'DilSensei'**
  String get appTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageIndonesian.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get languageIndonesian;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// No description provided for @commonReload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get commonReload;

  /// No description provided for @commonSeePro.
  ///
  /// In en, this message translates to:
  /// **'See Pro plans'**
  String get commonSeePro;

  /// No description provided for @onboardingNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start with\nyour name'**
  String get onboardingNameTitle;

  /// No description provided for @onboardingNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We use it to greet you every time you open a session.'**
  String get onboardingNameSubtitle;

  /// No description provided for @onboardingNameHint.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get onboardingNameHint;

  /// No description provided for @onboardingGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Why are you\nlearning Japanese?'**
  String get onboardingGoalTitle;

  /// No description provided for @onboardingGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This decides which phrases you drill first.'**
  String get onboardingGoalSubtitle;

  /// No description provided for @onboardingTargetTitle.
  ///
  /// In en, this message translates to:
  /// **'How many minutes\na day?'**
  String get onboardingTargetTitle;

  /// No description provided for @onboardingTargetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reflexes grow from short routines you don\'t skip.'**
  String get onboardingTargetSubtitle;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start practising'**
  String get onboardingStart;

  /// No description provided for @goalWorkLabel.
  ///
  /// In en, this message translates to:
  /// **'For work'**
  String get goalWorkLabel;

  /// No description provided for @goalWorkDescription.
  ///
  /// In en, this message translates to:
  /// **'Office phrases, reporting, and team talk'**
  String get goalWorkDescription;

  /// No description provided for @goalTravelLabel.
  ///
  /// In en, this message translates to:
  /// **'For travel'**
  String get goalTravelLabel;

  /// No description provided for @goalTravelDescription.
  ///
  /// In en, this message translates to:
  /// **'Asking directions, ordering, and shopping'**
  String get goalTravelDescription;

  /// No description provided for @goalCultureLabel.
  ///
  /// In en, this message translates to:
  /// **'For anime & culture'**
  String get goalCultureLabel;

  /// No description provided for @goalCultureDescription.
  ///
  /// In en, this message translates to:
  /// **'Everyday conversation that sounds natural'**
  String get goalCultureDescription;

  /// No description provided for @goalExamLabel.
  ///
  /// In en, this message translates to:
  /// **'For exams'**
  String get goalExamLabel;

  /// No description provided for @goalExamDescription.
  ///
  /// In en, this message translates to:
  /// **'Grammar patterns that show up in the JLPT'**
  String get goalExamDescription;

  /// No description provided for @targetLightLabel.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get targetLightLabel;

  /// No description provided for @targetLightDescription.
  ///
  /// In en, this message translates to:
  /// **'Enough to keep your streak'**
  String get targetLightDescription;

  /// No description provided for @targetSteadyLabel.
  ///
  /// In en, this message translates to:
  /// **'Steady'**
  String get targetSteadyLabel;

  /// No description provided for @targetSteadyDescription.
  ///
  /// In en, this message translates to:
  /// **'Most people pick this'**
  String get targetSteadyDescription;

  /// No description provided for @targetIntenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Serious'**
  String get targetIntenseLabel;

  /// No description provided for @targetIntenseDescription.
  ///
  /// In en, this message translates to:
  /// **'For anyone on a deadline'**
  String get targetIntenseDescription;

  /// No description provided for @targetMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes · {label}'**
  String targetMinutes(int minutes, String label);

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Konnichiwa, {name}!'**
  String homeGreeting(String name);

  /// No description provided for @homeGreetingFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Sensei'**
  String get homeGreetingFallbackName;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Time to train your muscle memory'**
  String get homeSubtitle;

  /// No description provided for @homeStreakSemantics.
  ///
  /// In en, this message translates to:
  /// **'{days} day streak'**
  String homeStreakSemantics(int days);

  /// No description provided for @homeTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S MODULE'**
  String get homeTodayLabel;

  /// No description provided for @homeStartSession.
  ///
  /// In en, this message translates to:
  /// **'Start session ({minutes} min)'**
  String homeStartSession(int minutes);

  /// No description provided for @homeRoadmapTitle.
  ///
  /// In en, this message translates to:
  /// **'Your roadmap'**
  String get homeRoadmapTitle;

  /// No description provided for @homeLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing your session...'**
  String get homeLoading;

  /// No description provided for @homeErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the lessons'**
  String get homeErrorTitle;

  /// No description provided for @homeErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection, then try again.'**
  String get homeErrorBody;

  /// No description provided for @homeMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String homeMinutesShort(int minutes);

  /// No description provided for @homePremiumSemantics.
  ///
  /// In en, this message translates to:
  /// **'Premium module, subscription required'**
  String get homePremiumSemantics;

  /// No description provided for @homeInsightsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Weak spots'**
  String get homeInsightsTooltip;

  /// No description provided for @homeSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettingsTooltip;

  /// No description provided for @dailyLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'That\'s today\'s session'**
  String get dailyLimitTitle;

  /// No description provided for @dailyLimitBody.
  ///
  /// In en, this message translates to:
  /// **'The free plan gives you one session a day. Reflexes come from repetition, and Pro unlocks as many sessions as you want — including sessions built from your weak spots.'**
  String get dailyLimitBody;

  /// No description provided for @dailyLimitLater.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow then'**
  String get dailyLimitLater;

  /// No description provided for @sessionAssembleLabel.
  ///
  /// In en, this message translates to:
  /// **'BUILD IT IN JAPANESE'**
  String get sessionAssembleLabel;

  /// No description provided for @sessionParticleLabel.
  ///
  /// In en, this message translates to:
  /// **'COMPLETE THE PARTICLE'**
  String get sessionParticleLabel;

  /// No description provided for @sessionTransformLabel.
  ///
  /// In en, this message translates to:
  /// **'CHANGE THE FORM'**
  String get sessionTransformLabel;

  /// No description provided for @sessionCanvasHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the word chips to build your answer'**
  String get sessionCanvasHint;

  /// No description provided for @sessionCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get sessionCheck;

  /// No description provided for @sessionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get sessionContinue;

  /// No description provided for @sessionSeeResult.
  ///
  /// In en, this message translates to:
  /// **'See result'**
  String get sessionSeeResult;

  /// No description provided for @sessionExitTooltip.
  ///
  /// In en, this message translates to:
  /// **'Leave session'**
  String get sessionExitTooltip;

  /// No description provided for @sessionLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing your drills...'**
  String get sessionLoading;

  /// No description provided for @sessionEmpty.
  ///
  /// In en, this message translates to:
  /// **'This module has no drills yet.'**
  String get sessionEmpty;

  /// No description provided for @sessionErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the drills'**
  String get sessionErrorTitle;

  /// No description provided for @feedbackCorrect.
  ///
  /// In en, this message translates to:
  /// **'Nailed it.'**
  String get feedbackCorrect;

  /// No description provided for @feedbackWrongRepeat.
  ///
  /// In en, this message translates to:
  /// **'Not quite — this one comes back later.'**
  String get feedbackWrongRepeat;

  /// No description provided for @feedbackWrongMovedOn.
  ///
  /// In en, this message translates to:
  /// **'Not quite. Saved for tomorrow\'s session.'**
  String get feedbackWrongMovedOn;

  /// No description provided for @feedbackPatternToPractise.
  ///
  /// In en, this message translates to:
  /// **'Pattern to practise: {patterns}'**
  String feedbackPatternToPractise(String patterns);

  /// No description provided for @summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get summaryTitle;

  /// No description provided for @summaryReflexScore.
  ///
  /// In en, this message translates to:
  /// **'reflex score'**
  String get summaryReflexScore;

  /// No description provided for @summaryFirstTry.
  ///
  /// In en, this message translates to:
  /// **'Right first try'**
  String get summaryFirstTry;

  /// No description provided for @summaryResponseTime.
  ///
  /// In en, this message translates to:
  /// **'Response time'**
  String get summaryResponseTime;

  /// No description provided for @summarySeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String summarySeconds(String seconds);

  /// No description provided for @summaryNoData.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get summaryNoData;

  /// No description provided for @summaryWeakTitle.
  ///
  /// In en, this message translates to:
  /// **'Patterns that aren\'t reflex yet'**
  String get summaryWeakTitle;

  /// No description provided for @summaryClean.
  ///
  /// In en, this message translates to:
  /// **'All clean.'**
  String get summaryClean;

  /// No description provided for @summaryCleanBody.
  ///
  /// In en, this message translates to:
  /// **'No pattern went wrong this session. The next module raises the tempo.'**
  String get summaryCleanBody;

  /// No description provided for @summaryDrillWeak.
  ///
  /// In en, this message translates to:
  /// **'Drill your weak spots now'**
  String get summaryDrillWeak;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Weak spots'**
  String get insightsTitle;

  /// No description provided for @insightsTotalSessions.
  ///
  /// In en, this message translates to:
  /// **'Total sessions'**
  String get insightsTotalSessions;

  /// No description provided for @insightsBestScore.
  ///
  /// In en, this message translates to:
  /// **'Best score'**
  String get insightsBestScore;

  /// No description provided for @insightsPatternsTitle.
  ///
  /// In en, this message translates to:
  /// **'Patterns you miss most'**
  String get insightsPatternsTitle;

  /// No description provided for @insightsPatternsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recent mistakes count more than old ones, and answers that are right but slow still count.'**
  String get insightsPatternsSubtitle;

  /// No description provided for @insightsReasonAccuracy.
  ///
  /// In en, this message translates to:
  /// **'{count} wrong'**
  String insightsReasonAccuracy(int count);

  /// No description provided for @insightsReasonSlow.
  ///
  /// In en, this message translates to:
  /// **'{count} slow'**
  String insightsReasonSlow(int count);

  /// No description provided for @insightsReasonSolid.
  ///
  /// In en, this message translates to:
  /// **'Solid'**
  String get insightsReasonSolid;

  /// No description provided for @insightsMastery.
  ///
  /// In en, this message translates to:
  /// **'{percent}% mastered'**
  String insightsMastery(int percent);

  /// No description provided for @insightsStrongTitle.
  ///
  /// In en, this message translates to:
  /// **'Already reflex'**
  String get insightsStrongTitle;

  /// No description provided for @insightsNoPatterns.
  ///
  /// In en, this message translates to:
  /// **'No pattern has gone wrong yet. Finish a few more sessions to see the map.'**
  String get insightsNoPatterns;

  /// No description provided for @insightsProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Reflex score over time'**
  String get insightsProgressTitle;

  /// No description provided for @insightsHistoryLocked.
  ///
  /// In en, this message translates to:
  /// **'Progress history unlocks with Pro.'**
  String get insightsHistoryLocked;

  /// No description provided for @insightsHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'History appears after your first session.'**
  String get insightsHistoryEmpty;

  /// No description provided for @insightsHiddenPatterns.
  ///
  /// In en, this message translates to:
  /// **'{count} more patterns are hidden on the free plan.'**
  String insightsHiddenPatterns(int count);

  /// No description provided for @insightsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to map yet'**
  String get insightsEmptyTitle;

  /// No description provided for @insightsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Finish one session, then come back to see which patterns aren\'t reflex yet.'**
  String get insightsEmptyBody;

  /// No description provided for @insightsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'{percent}% right'**
  String insightsAccuracy(int percent);

  /// No description provided for @insightsMissCount.
  ///
  /// In en, this message translates to:
  /// **'{count}x'**
  String insightsMissCount(int count);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsFreePlan.
  ///
  /// In en, this message translates to:
  /// **'Free plan'**
  String get settingsFreePlan;

  /// No description provided for @settingsProActive.
  ///
  /// In en, this message translates to:
  /// **'Pro access active'**
  String get settingsProActive;

  /// No description provided for @settingsDailyTarget.
  ///
  /// In en, this message translates to:
  /// **'Daily target: {minutes} minutes'**
  String settingsDailyTarget(int minutes);

  /// No description provided for @settingsSessionsToday.
  ///
  /// In en, this message translates to:
  /// **'Sessions today: {count}'**
  String settingsSessionsToday(int count);

  /// No description provided for @settingsSectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsSectionLanguage;

  /// No description provided for @settingsSectionPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get settingsSectionPractice;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Match device'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Currently active'**
  String get settingsThemeSubtitle;

  /// No description provided for @settingsSectionSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get settingsSectionSubscription;

  /// No description provided for @settingsSectionLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get settingsSectionLegal;

  /// No description provided for @settingsSectionDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get settingsSectionDevelopment;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Interface and lesson prompts'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get settingsRestore;

  /// No description provided for @settingsRestoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recover your subscription after switching devices'**
  String get settingsRestoreSubtitle;

  /// No description provided for @settingsManage.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get settingsManage;

  /// No description provided for @settingsManageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change or cancel through Google Play'**
  String get settingsManageSubtitle;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacy;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get settingsTerms;

  /// No description provided for @settingsDevToggle.
  ///
  /// In en, this message translates to:
  /// **'DEV: Force Pro access'**
  String get settingsDevToggle;

  /// No description provided for @settingsDevToggleBody.
  ///
  /// In en, this message translates to:
  /// **'Unlocks every module and unlimited sessions without a purchase, for testing only. Never shown in release builds.'**
  String get settingsDevToggleBody;

  /// No description provided for @settingsRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Subscription restored.'**
  String get settingsRestoreSuccess;

  /// No description provided for @settingsRestoreEmpty.
  ///
  /// In en, this message translates to:
  /// **'No subscription to restore.'**
  String get settingsRestoreEmpty;

  /// No description provided for @settingsCannotOpen.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open {url}'**
  String settingsCannotOpen(String url);

  /// No description provided for @paywallHeadline.
  ///
  /// In en, this message translates to:
  /// **'Unlock\nyour full\npotential'**
  String get paywallHeadline;

  /// No description provided for @paywallBody.
  ///
  /// In en, this message translates to:
  /// **'Don\'t let your muscle memory fade. Drill the patterns that still make you hesitate, until Japanese comes out without thinking.'**
  String get paywallBody;

  /// No description provided for @paywallBenefitModules.
  ///
  /// In en, this message translates to:
  /// **'Every module and unlimited daily sessions'**
  String get paywallBenefitModules;

  /// No description provided for @paywallBenefitMap.
  ///
  /// In en, this message translates to:
  /// **'The full weak-spot map, not a summary'**
  String get paywallBenefitMap;

  /// No description provided for @paywallBenefitAuto.
  ///
  /// In en, this message translates to:
  /// **'Sessions built automatically from your weak patterns'**
  String get paywallBenefitAuto;

  /// No description provided for @paywallBenefitHistory.
  ///
  /// In en, this message translates to:
  /// **'Reflex score history and weekly progress'**
  String get paywallBenefitHistory;

  /// No description provided for @paywallCta.
  ///
  /// In en, this message translates to:
  /// **'Start subscription'**
  String get paywallCta;

  /// No description provided for @paywallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get paywallRestore;

  /// No description provided for @paywallDisclosure.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions renew automatically until cancelled. Cancel any time in your store account settings.'**
  String get paywallDisclosure;

  /// No description provided for @paywallPricesLoading.
  ///
  /// In en, this message translates to:
  /// **'Fetching prices from the store...'**
  String get paywallPricesLoading;

  /// No description provided for @paywallPricesErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Prices unavailable'**
  String get paywallPricesErrorTitle;

  /// No description provided for @paywallPricesErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection, then reload the plans.'**
  String get paywallPricesErrorBody;

  /// No description provided for @paywallPurchaseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Subscription active. Happy drilling!'**
  String get paywallPurchaseSuccess;

  /// No description provided for @paywallPurchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed.'**
  String get paywallPurchaseFailed;

  /// No description provided for @paywallTestStore.
  ///
  /// In en, this message translates to:
  /// **'TEST STORE MODE — purchases are not charged'**
  String get paywallTestStore;

  /// No description provided for @paywallRecommended.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get paywallRecommended;

  /// No description provided for @paywallSavePercent.
  ///
  /// In en, this message translates to:
  /// **'Save {percent}%'**
  String paywallSavePercent(int percent);

  /// No description provided for @planPeriodWeekly.
  ///
  /// In en, this message translates to:
  /// **'/ week'**
  String get planPeriodWeekly;

  /// No description provided for @planPeriodMonthly.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get planPeriodMonthly;

  /// No description provided for @planPeriodAnnual.
  ///
  /// In en, this message translates to:
  /// **'/ year'**
  String get planPeriodAnnual;

  /// No description provided for @planPeriodLifetime.
  ///
  /// In en, this message translates to:
  /// **'one-time'**
  String get planPeriodLifetime;

  /// No description provided for @planTitleWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly plan'**
  String get planTitleWeekly;

  /// No description provided for @planTitleMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly plan'**
  String get planTitleMonthly;

  /// No description provided for @planTitleAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual plan'**
  String get planTitleAnnual;

  /// No description provided for @planTitleLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime access'**
  String get planTitleLifetime;

  /// No description provided for @planTrialFree.
  ///
  /// In en, this message translates to:
  /// **'{count} {unit} free'**
  String planTrialFree(int count, String unit);

  /// No description provided for @planUnitDay.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get planUnitDay;

  /// No description provided for @planUnitWeek.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get planUnitWeek;

  /// No description provided for @planUnitMonth.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get planUnitMonth;

  /// No description provided for @planUnitYear.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get planUnitYear;

  /// No description provided for @patternParticlePlace.
  ///
  /// In en, this message translates to:
  /// **'Place particle'**
  String get patternParticlePlace;

  /// No description provided for @patternParticleObject.
  ///
  /// In en, this message translates to:
  /// **'Object particle'**
  String get patternParticleObject;

  /// No description provided for @patternParticleTopic.
  ///
  /// In en, this message translates to:
  /// **'Topic particle'**
  String get patternParticleTopic;

  /// No description provided for @patternWordOrderTime.
  ///
  /// In en, this message translates to:
  /// **'Time expression order'**
  String get patternWordOrderTime;

  /// No description provided for @patternPoliteForm.
  ///
  /// In en, this message translates to:
  /// **'Polite form'**
  String get patternPoliteForm;

  /// No description provided for @patternPastForm.
  ///
  /// In en, this message translates to:
  /// **'Past form'**
  String get patternPastForm;

  /// No description provided for @patternNegativeForm.
  ///
  /// In en, this message translates to:
  /// **'Negative form'**
  String get patternNegativeForm;

  /// No description provided for @patternCounterWord.
  ///
  /// In en, this message translates to:
  /// **'Counter word'**
  String get patternCounterWord;

  /// No description provided for @kanaSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Refresh the letters first'**
  String get kanaSectionTitle;

  /// No description provided for @kanaSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Free reference, no session needed'**
  String get kanaSectionSubtitle;

  /// No description provided for @kanaFreeBadge.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get kanaFreeBadge;

  /// No description provided for @kanaHiragana.
  ///
  /// In en, this message translates to:
  /// **'Hiragana'**
  String get kanaHiragana;

  /// No description provided for @kanaKatakana.
  ///
  /// In en, this message translates to:
  /// **'Katakana'**
  String get kanaKatakana;

  /// No description provided for @kanaLetterCount.
  ///
  /// In en, this message translates to:
  /// **'{count} letters'**
  String kanaLetterCount(int count);

  /// No description provided for @kanaSectionBase.
  ///
  /// In en, this message translates to:
  /// **'Gojūon · 46 base letters'**
  String get kanaSectionBase;

  /// No description provided for @kanaSectionVoiced.
  ///
  /// In en, this message translates to:
  /// **'Dakuten · voiced letters'**
  String get kanaSectionVoiced;

  /// No description provided for @kanaSectionCombined.
  ///
  /// In en, this message translates to:
  /// **'Yōon · combinations'**
  String get kanaSectionCombined;

  /// No description provided for @kanaUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'When do you use it?'**
  String get kanaUsageTitle;

  /// No description provided for @kanaHiraganaUsage.
  ///
  /// In en, this message translates to:
  /// **'Hiragana is the base script. Use it for native Japanese words, for particles like は and を, and for the verb endings that keep changing shape. When you don\'t know the kanji for a word, hiragana is the safe fallback that everyone still reads.'**
  String get kanaHiraganaUsage;

  /// No description provided for @kanaKatakanaUsage.
  ///
  /// In en, this message translates to:
  /// **'Katakana marks words that arrived from outside Japanese — コーヒー for coffee, パソコン for a computer, and foreign names including yours. You will also meet it on menus, packaging, and signage, and it is used for emphasis the way italics work in English.'**
  String get kanaKatakanaUsage;

  /// No description provided for @kanaTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading it faster'**
  String get kanaTipTitle;

  /// No description provided for @kanaTipBody.
  ///
  /// In en, this message translates to:
  /// **'Read across the rows, not down the columns: the consonant stays and only the vowel changes. Once a row feels automatic, move to the next one instead of trying to memorise the whole chart at once.'**
  String get kanaTipBody;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Ohayou, {name}!'**
  String homeGreetingMorning(String name);

  /// No description provided for @homeGreetingMidday.
  ///
  /// In en, this message translates to:
  /// **'Konnichiwa, {name}!'**
  String homeGreetingMidday(String name);

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Konnichiwa, {name}!'**
  String homeGreetingAfternoon(String name);

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Konbanwa, {name}!'**
  String homeGreetingEvening(String name);

  /// No description provided for @homeSubtitleMorning.
  ///
  /// In en, this message translates to:
  /// **'A short session now sets the tone for the day'**
  String get homeSubtitleMorning;

  /// No description provided for @homeSubtitleMidday.
  ///
  /// In en, this message translates to:
  /// **'Ten minutes between tasks is enough'**
  String get homeSubtitleMidday;

  /// No description provided for @homeSubtitleAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Beat the afternoon slump with one quick drill'**
  String get homeSubtitleAfternoon;

  /// No description provided for @homeSubtitleEvening.
  ///
  /// In en, this message translates to:
  /// **'Close the day by locking in what you practised'**
  String get homeSubtitleEvening;

  /// No description provided for @settingsSectionReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get settingsSectionReminder;

  /// No description provided for @settingsReminderToggle.
  ///
  /// In en, this message translates to:
  /// **'Remind me to practise'**
  String get settingsReminderToggle;

  /// No description provided for @settingsReminderToggleBody.
  ///
  /// In en, this message translates to:
  /// **'One notification a day, skipped automatically when you have already practised.'**
  String get settingsReminderToggleBody;

  /// No description provided for @settingsReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get settingsReminderTime;

  /// No description provided for @settingsReminderTimeValue.
  ///
  /// In en, this message translates to:
  /// **'Every day at {time}'**
  String settingsReminderTimeValue(String time);

  /// No description provided for @settingsReminderPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off for DilSensei. Enable them in your system settings.'**
  String get settingsReminderPermissionDenied;

  /// No description provided for @reminderTitleWeakAccuracy.
  ///
  /// In en, this message translates to:
  /// **'{pattern} is still slipping'**
  String reminderTitleWeakAccuracy(String pattern);

  /// No description provided for @reminderBodyWeakAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Three minutes is enough to turn it around. Want to drill just that pattern?'**
  String get reminderBodyWeakAccuracy;

  /// No description provided for @reminderTitleWeakSpeed.
  ///
  /// In en, this message translates to:
  /// **'{pattern} is right but slow'**
  String reminderTitleWeakSpeed(String pattern);

  /// No description provided for @reminderBodyWeakSpeed.
  ///
  /// In en, this message translates to:
  /// **'Correct is not the same as reflex. One quick session tightens it up.'**
  String get reminderBodyWeakSpeed;

  /// No description provided for @reminderTitleStreak.
  ///
  /// In en, this message translates to:
  /// **'Your streak is waiting'**
  String get reminderTitleStreak;

  /// No description provided for @reminderBodyStreak.
  ///
  /// In en, this message translates to:
  /// **'One session keeps it alive. It takes less time than scrolling.'**
  String get reminderBodyStreak;

  /// No description provided for @reminderTitleFirst.
  ///
  /// In en, this message translates to:
  /// **'Ready for your first drill?'**
  String get reminderTitleFirst;

  /// No description provided for @reminderBodyFirst.
  ///
  /// In en, this message translates to:
  /// **'Five minutes, one module, and you will already feel the rhythm.'**
  String get reminderBodyFirst;

  /// No description provided for @recordUnlockedCta.
  ///
  /// In en, this message translates to:
  /// **'See your Training Record'**
  String get recordUnlockedCta;

  /// No description provided for @recordEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Training Record'**
  String get recordEntryTitle;

  /// No description provided for @recordEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Proof that you finished every module'**
  String get recordEntrySubtitle;

  /// No description provided for @recordEntryLocked.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} modules done'**
  String recordEntryLocked(int completed, int total);

  /// No description provided for @purchaseErrorPlanNotFound.
  ///
  /// In en, this message translates to:
  /// **'That plan is not available right now.'**
  String get purchaseErrorPlanNotFound;

  /// No description provided for @purchaseErrorNotActive.
  ///
  /// In en, this message translates to:
  /// **'The subscription is not active yet.'**
  String get purchaseErrorNotActive;

  /// No description provided for @purchaseErrorStore.
  ///
  /// In en, this message translates to:
  /// **'The store could not complete the purchase.'**
  String get purchaseErrorStore;

  /// No description provided for @purchaseErrorNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Purchases are not available in this build.'**
  String get purchaseErrorNotConfigured;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'A newer version of DilSensei is on Google Play.'**
  String get updateAvailableBody;

  /// No description provided for @updateAction.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateAction;

  /// No description provided for @updateDismiss.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateDismiss;

  /// No description provided for @updateDownloadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Downloading update'**
  String get updateDownloadingTitle;

  /// No description provided for @updateDownloadingBody.
  ///
  /// In en, this message translates to:
  /// **'You can keep practising while it downloads.'**
  String get updateDownloadingBody;

  /// No description provided for @updateReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Update ready'**
  String get updateReadyTitle;

  /// No description provided for @updateReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Restart the app to finish installing.'**
  String get updateReadyBody;

  /// No description provided for @updateReadyAction.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get updateReadyAction;

  /// No description provided for @updateFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Update could not start'**
  String get updateFailedTitle;

  /// No description provided for @updateFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Open DilSensei on Google Play to update manually.'**
  String get updateFailedBody;

  /// No description provided for @updateFailedAction.
  ///
  /// In en, this message translates to:
  /// **'Open Google Play'**
  String get updateFailedAction;

  /// No description provided for @diagnosticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get diagnosticsTitle;

  /// No description provided for @diagnosticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Technical log for this session'**
  String get diagnosticsSubtitle;

  /// No description provided for @diagnosticsCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy all'**
  String get diagnosticsCopy;

  /// No description provided for @diagnosticsClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get diagnosticsClear;

  /// No description provided for @diagnosticsCopied.
  ///
  /// In en, this message translates to:
  /// **'Log copied to clipboard'**
  String get diagnosticsCopied;

  /// No description provided for @diagnosticsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded yet. Open the paywall to capture subscription activity.'**
  String get diagnosticsEmpty;

  /// No description provided for @practicePreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice preferences'**
  String get practicePreferencesTitle;

  /// No description provided for @practicePreferencesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change these whenever your reason for learning changes. Your progress and streak are kept.'**
  String get practicePreferencesSubtitle;

  /// No description provided for @practicePreferencesEntry.
  ///
  /// In en, this message translates to:
  /// **'Goal & daily target'**
  String get practicePreferencesEntry;

  /// No description provided for @practicePreferencesError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your preferences.'**
  String get practicePreferencesError;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'id':
      return AppL10nId();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
