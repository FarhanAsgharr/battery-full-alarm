import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
    Locale('ar'),
    Locale('en'),
    Locale('hi'),
    Locale('ur'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Battery Full Alarm'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get navStats;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get actionReset;

  /// No description provided for @actionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get actionOpenSettings;

  /// No description provided for @actionAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get actionAllow;

  /// No description provided for @actionNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get actionNotNow;

  /// No description provided for @monitoringOn.
  ///
  /// In en, this message translates to:
  /// **'Monitoring is on'**
  String get monitoringOn;

  /// No description provided for @monitoringOff.
  ///
  /// In en, this message translates to:
  /// **'Monitoring is off'**
  String get monitoringOff;

  /// No description provided for @monitoringOnBody.
  ///
  /// In en, this message translates to:
  /// **'You will be alerted the moment the battery reaches 100%.'**
  String get monitoringOnBody;

  /// No description provided for @monitoringOffBody.
  ///
  /// In en, this message translates to:
  /// **'Turn this on to be alerted when charging completes.'**
  String get monitoringOffBody;

  /// No description provided for @statusCharging.
  ///
  /// In en, this message translates to:
  /// **'Charging'**
  String get statusCharging;

  /// No description provided for @statusFull.
  ///
  /// In en, this message translates to:
  /// **'Fully charged'**
  String get statusFull;

  /// No description provided for @statusDischarging.
  ///
  /// In en, this message translates to:
  /// **'On battery'**
  String get statusDischarging;

  /// No description provided for @chargerAc.
  ///
  /// In en, this message translates to:
  /// **'AC charger'**
  String get chargerAc;

  /// No description provided for @chargerUsb.
  ///
  /// In en, this message translates to:
  /// **'USB'**
  String get chargerUsb;

  /// No description provided for @chargerWireless.
  ///
  /// In en, this message translates to:
  /// **'Wireless'**
  String get chargerWireless;

  /// No description provided for @chargerNone.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get chargerNone;

  /// No description provided for @chargerOther.
  ///
  /// In en, this message translates to:
  /// **'External power'**
  String get chargerOther;

  /// No description provided for @alarmRinging.
  ///
  /// In en, this message translates to:
  /// **'Alarm is ringing'**
  String get alarmRinging;

  /// No description provided for @alarmRingingBody.
  ///
  /// In en, this message translates to:
  /// **'Unplug the charger, or stop it here.'**
  String get alarmRingingBody;

  /// No description provided for @actionStopAlarm.
  ///
  /// In en, this message translates to:
  /// **'Stop alarm'**
  String get actionStopAlarm;

  /// No description provided for @actionTestAlarm.
  ///
  /// In en, this message translates to:
  /// **'Test alarm'**
  String get actionTestAlarm;

  /// No description provided for @testAlarmStarted.
  ///
  /// In en, this message translates to:
  /// **'Playing one alarm cycle…'**
  String get testAlarmStarted;

  /// No description provided for @detailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Battery details'**
  String get detailsTitle;

  /// No description provided for @detailTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get detailTemperature;

  /// No description provided for @detailVoltage.
  ///
  /// In en, this message translates to:
  /// **'Voltage'**
  String get detailVoltage;

  /// No description provided for @detailHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get detailHealth;

  /// No description provided for @detailTechnology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get detailTechnology;

  /// No description provided for @detailCharger.
  ///
  /// In en, this message translates to:
  /// **'Power source'**
  String get detailCharger;

  /// No description provided for @healthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get healthGood;

  /// No description provided for @healthOverheat.
  ///
  /// In en, this message translates to:
  /// **'Overheating'**
  String get healthOverheat;

  /// No description provided for @healthDead.
  ///
  /// In en, this message translates to:
  /// **'Dead'**
  String get healthDead;

  /// No description provided for @healthOverVoltage.
  ///
  /// In en, this message translates to:
  /// **'Over voltage'**
  String get healthOverVoltage;

  /// No description provided for @healthCold.
  ///
  /// In en, this message translates to:
  /// **'Cold'**
  String get healthCold;

  /// No description provided for @healthFailure.
  ///
  /// In en, this message translates to:
  /// **'Failure'**
  String get healthFailure;

  /// No description provided for @healthUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get healthUnknown;

  /// No description provided for @sessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Current charging session'**
  String get sessionTitle;

  /// No description provided for @sessionNone.
  ///
  /// In en, this message translates to:
  /// **'Not charging right now.'**
  String get sessionNone;

  /// No description provided for @sessionStarted.
  ///
  /// In en, this message translates to:
  /// **'Started at {time}'**
  String sessionStarted(String time);

  /// No description provided for @sessionGained.
  ///
  /// In en, this message translates to:
  /// **'{from}% → {to}%'**
  String sessionGained(int from, int to);

  /// No description provided for @sessionAlarms.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No alarms yet} =1{1 alarm played} other{{count} alarms played}}'**
  String sessionAlarms(int count);

  /// No description provided for @warnNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked'**
  String get warnNotificationsTitle;

  /// No description provided for @warnNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Android needs notification access to keep battery monitoring running.'**
  String get warnNotificationsBody;

  /// No description provided for @warnBatteryOptimTitle.
  ///
  /// In en, this message translates to:
  /// **'Battery optimisation is on'**
  String get warnBatteryOptimTitle;

  /// No description provided for @warnBatteryOptimBody.
  ///
  /// In en, this message translates to:
  /// **'Android may stop monitoring in the background. Allow unrestricted battery use for reliable alarms.'**
  String get warnBatteryOptimBody;

  /// No description provided for @warnServiceStoppedTitle.
  ///
  /// In en, this message translates to:
  /// **'Monitoring service is not running'**
  String get warnServiceStoppedTitle;

  /// No description provided for @warnServiceStoppedBody.
  ///
  /// In en, this message translates to:
  /// **'Turn monitoring off and on again to restart it.'**
  String get warnServiceStoppedBody;

  /// No description provided for @warnTtsTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice not available for this language'**
  String get warnTtsTitle;

  /// No description provided for @warnTtsBody.
  ///
  /// In en, this message translates to:
  /// **'Install the voice data in your device\'s text-to-speech settings, or the alarm will speak English.'**
  String get warnTtsBody;

  /// No description provided for @actionTtsSettings.
  ///
  /// In en, this message translates to:
  /// **'Text-to-speech settings'**
  String get actionTtsSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sectionVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice announcement'**
  String get sectionVoice;

  /// No description provided for @sectionAlarm.
  ///
  /// In en, this message translates to:
  /// **'Alarm'**
  String get sectionAlarm;

  /// No description provided for @sectionAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get sectionAlerts;

  /// No description provided for @sectionStartup.
  ///
  /// In en, this message translates to:
  /// **'Startup'**
  String get sectionStartup;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @sectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get sectionData;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @settingUserName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get settingUserName;

  /// No description provided for @settingUserNameHint.
  ///
  /// In en, this message translates to:
  /// **'Used in the spoken message'**
  String get settingUserNameHint;

  /// No description provided for @settingUserNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get settingUserNameEmpty;

  /// No description provided for @settingVoiceMessage.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get settingVoiceMessage;

  /// No description provided for @settingVoiceEnabled.
  ///
  /// In en, this message translates to:
  /// **'Speak the message'**
  String get settingVoiceEnabled;

  /// No description provided for @settingVoiceEnabledBody.
  ///
  /// In en, this message translates to:
  /// **'Uses your phone\'s built-in text-to-speech.'**
  String get settingVoiceEnabledBody;

  /// No description provided for @settingSpeechRate.
  ///
  /// In en, this message translates to:
  /// **'Speech speed'**
  String get settingSpeechRate;

  /// No description provided for @settingSpeechPitch.
  ///
  /// In en, this message translates to:
  /// **'Speech pitch'**
  String get settingSpeechPitch;

  /// No description provided for @settingAlarmSound.
  ///
  /// In en, this message translates to:
  /// **'Alarm sound'**
  String get settingAlarmSound;

  /// No description provided for @settingAlarmSoundDefault.
  ///
  /// In en, this message translates to:
  /// **'Default alarm'**
  String get settingAlarmSoundDefault;

  /// No description provided for @settingSoundEnabled.
  ///
  /// In en, this message translates to:
  /// **'Play alarm sound'**
  String get settingSoundEnabled;

  /// No description provided for @settingAlarmInterval.
  ///
  /// In en, this message translates to:
  /// **'Repeat every'**
  String get settingAlarmInterval;

  /// No description provided for @settingAlarmVolume.
  ///
  /// In en, this message translates to:
  /// **'Alarm volume'**
  String get settingAlarmVolume;

  /// No description provided for @settingVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibrate'**
  String get settingVibration;

  /// No description provided for @settingFlash.
  ///
  /// In en, this message translates to:
  /// **'Flash the torch'**
  String get settingFlash;

  /// No description provided for @settingFlashUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This device has no flash'**
  String get settingFlashUnavailable;

  /// No description provided for @settingVibrationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This device has no vibration motor'**
  String get settingVibrationUnavailable;

  /// No description provided for @settingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Alarm notification'**
  String get settingNotifications;

  /// No description provided for @settingNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Shows a notification with a Stop button while the alarm rings. The ongoing monitor notification cannot be hidden — Android needs it to keep monitoring alive.'**
  String get settingNotificationsBody;

  /// No description provided for @settingAutoStart.
  ///
  /// In en, this message translates to:
  /// **'Start monitoring automatically'**
  String get settingAutoStart;

  /// No description provided for @settingAutoStartBody.
  ///
  /// In en, this message translates to:
  /// **'Re-arms monitoring when a charger is connected.'**
  String get settingAutoStartBody;

  /// No description provided for @settingAutoStartBoot.
  ///
  /// In en, this message translates to:
  /// **'Start after restart'**
  String get settingAutoStartBoot;

  /// No description provided for @settingAutoStartBootBody.
  ///
  /// In en, this message translates to:
  /// **'Resume monitoring when the phone reboots.'**
  String get settingAutoStartBootBody;

  /// No description provided for @settingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingLanguage;

  /// No description provided for @settingTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingTheme;

  /// No description provided for @settingBatteryOptimization.
  ///
  /// In en, this message translates to:
  /// **'Background restrictions'**
  String get settingBatteryOptimization;

  /// No description provided for @settingBatteryOptimizationOk.
  ///
  /// In en, this message translates to:
  /// **'Unrestricted — alarms are reliable'**
  String get settingBatteryOptimizationOk;

  /// No description provided for @settingBatteryOptimizationBad.
  ///
  /// In en, this message translates to:
  /// **'Restricted — alarms may be delayed'**
  String get settingBatteryOptimizationBad;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
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

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageUrdu.
  ///
  /// In en, this message translates to:
  /// **'اردو'**
  String get languageUrdu;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get languageHindi;

  /// No description provided for @intervalSeconds.
  ///
  /// In en, this message translates to:
  /// **'{count} seconds'**
  String intervalSeconds(int count);

  /// No description provided for @intervalMinute.
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get intervalMinute;

  /// No description provided for @voiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice announcement'**
  String get voiceTitle;

  /// No description provided for @voiceMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'What should the phone say?'**
  String get voiceMessageLabel;

  /// No description provided for @voiceMessageHelp.
  ///
  /// In en, this message translates to:
  /// **'Tap a tag to insert it. Tags are replaced when the message is spoken.'**
  String get voiceMessageHelp;

  /// No description provided for @voiceTokenName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get voiceTokenName;

  /// No description provided for @voiceTokenLevel.
  ///
  /// In en, this message translates to:
  /// **'Battery level'**
  String get voiceTokenLevel;

  /// No description provided for @voicePreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get voicePreviewTitle;

  /// No description provided for @actionPlayPreview.
  ///
  /// In en, this message translates to:
  /// **'Play preview'**
  String get actionPlayPreview;

  /// No description provided for @actionStopPreview.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get actionStopPreview;

  /// No description provided for @voicePresets.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get voicePresets;

  /// No description provided for @voiceMessageEmpty.
  ///
  /// In en, this message translates to:
  /// **'The announcement cannot be empty.'**
  String get voiceMessageEmpty;

  /// No description provided for @voiceResetDefault.
  ///
  /// In en, this message translates to:
  /// **'Restore the default message'**
  String get voiceResetDefault;

  /// No description provided for @soundTitle.
  ///
  /// In en, this message translates to:
  /// **'Alarm sound'**
  String get soundTitle;

  /// No description provided for @soundBuiltIn.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get soundBuiltIn;

  /// No description provided for @soundCustom.
  ///
  /// In en, this message translates to:
  /// **'Your sounds'**
  String get soundCustom;

  /// No description provided for @soundCustomEmpty.
  ///
  /// In en, this message translates to:
  /// **'Import an audio file or record your voice to add your own alarm.'**
  String get soundCustomEmpty;

  /// No description provided for @actionImportAudio.
  ///
  /// In en, this message translates to:
  /// **'Import audio file'**
  String get actionImportAudio;

  /// No description provided for @actionRecordVoice.
  ///
  /// In en, this message translates to:
  /// **'Record your voice'**
  String get actionRecordVoice;

  /// No description provided for @actionStopRecording.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get actionStopRecording;

  /// No description provided for @recordingInProgress.
  ///
  /// In en, this message translates to:
  /// **'Recording… tap stop when you are done.'**
  String get recordingInProgress;

  /// No description provided for @recordingSaved.
  ///
  /// In en, this message translates to:
  /// **'Recording saved.'**
  String get recordingSaved;

  /// No description provided for @recordingFailed.
  ///
  /// In en, this message translates to:
  /// **'The recording could not be saved.'**
  String get recordingFailed;

  /// No description provided for @recordingPermission.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is needed to record an alarm.'**
  String get recordingPermission;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'That file could not be imported.'**
  String get importFailed;

  /// No description provided for @importCancelled.
  ///
  /// In en, this message translates to:
  /// **'No file selected.'**
  String get importCancelled;

  /// No description provided for @soundDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String soundDeleteConfirm(String name);

  /// No description provided for @soundDeleted.
  ///
  /// In en, this message translates to:
  /// **'Sound deleted.'**
  String get soundDeleted;

  /// No description provided for @soundInUseReset.
  ///
  /// In en, this message translates to:
  /// **'The alarm was switched back to the default sound.'**
  String get soundInUseReset;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Charging history'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No charging sessions recorded yet.'**
  String get historyEmpty;

  /// No description provided for @historyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Plug in your charger and the session will appear here.'**
  String get historyEmptyBody;

  /// No description provided for @actionClearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get actionClearHistory;

  /// No description provided for @historyClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete every recorded charging session?'**
  String get historyClearConfirm;

  /// No description provided for @historyCleared.
  ///
  /// In en, this message translates to:
  /// **'History cleared.'**
  String get historyCleared;

  /// No description provided for @historyEntryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted.'**
  String get historyEntryDeleted;

  /// No description provided for @historyInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get historyInProgress;

  /// No description provided for @historyReachedFull.
  ///
  /// In en, this message translates to:
  /// **'Reached 100% in {duration}'**
  String historyReachedFull(String duration);

  /// No description provided for @historyNeverFull.
  ///
  /// In en, this message translates to:
  /// **'Did not reach 100%'**
  String get historyNeverFull;

  /// No description provided for @historyPluggedFor.
  ///
  /// In en, this message translates to:
  /// **'Plugged in for {duration}'**
  String historyPluggedFor(String duration);

  /// No description provided for @historyAlarms.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No alarms} =1{1 alarm} other{{count} alarms}}'**
  String historyAlarms(int count);

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @statsDaily.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get statsDaily;

  /// No description provided for @statsWeekly.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get statsWeekly;

  /// No description provided for @statsMonthly.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get statsMonthly;

  /// No description provided for @statsNoData.
  ///
  /// In en, this message translates to:
  /// **'No charging data for this period yet.'**
  String get statsNoData;

  /// No description provided for @statsSessions.
  ///
  /// In en, this message translates to:
  /// **'Charging sessions'**
  String get statsSessions;

  /// No description provided for @statsFullCharges.
  ///
  /// In en, this message translates to:
  /// **'Reached 100%'**
  String get statsFullCharges;

  /// No description provided for @statsAvgChargeTime.
  ///
  /// In en, this message translates to:
  /// **'Average time to full'**
  String get statsAvgChargeTime;

  /// No description provided for @statsAvgPluggedTime.
  ///
  /// In en, this message translates to:
  /// **'Average time plugged in'**
  String get statsAvgPluggedTime;

  /// No description provided for @statsTotalAlarms.
  ///
  /// In en, this message translates to:
  /// **'Alarms played'**
  String get statsTotalAlarms;

  /// No description provided for @statsAvgStartLevel.
  ///
  /// In en, this message translates to:
  /// **'Average level when plugged in'**
  String get statsAvgStartLevel;

  /// No description provided for @statsEnergyGained.
  ///
  /// In en, this message translates to:
  /// **'Average charge gained'**
  String get statsEnergyGained;

  /// No description provided for @statsChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Sessions per day'**
  String get statsChartTitle;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build})'**
  String aboutVersion(String version, String build);

  /// No description provided for @aboutDevice.
  ///
  /// In en, this message translates to:
  /// **'Android {release} (API {sdk})'**
  String aboutDevice(String release, int sdk);

  /// No description provided for @aboutOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Works completely offline'**
  String get aboutOfflineTitle;

  /// No description provided for @aboutOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'This app has no internet permission. Your name, message, recordings and history never leave the phone.'**
  String get aboutOfflineBody;

  /// No description provided for @aboutPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions used'**
  String get aboutPermissionsTitle;

  /// No description provided for @aboutHowItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get aboutHowItWorksTitle;

  /// No description provided for @aboutHowItWorksBody.
  ///
  /// In en, this message translates to:
  /// **'A foreground service watches the system battery broadcast. When the level hits 100% while a charger is attached, the alarm sound, spoken message, vibration and torch repeat at your chosen interval until you unplug.'**
  String get aboutHowItWorksBody;

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String durationMinutes(int minutes);

  /// No description provided for @durationSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String durationSeconds(int seconds);

  /// No description provided for @valueUnavailable.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get valueUnavailable;

  /// No description provided for @percentValue.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String percentValue(int value);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'hi', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
