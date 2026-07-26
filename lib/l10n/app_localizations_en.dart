// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Battery Full Alarm';

  @override
  String get navHome => 'Home';

  @override
  String get navHistory => 'History';

  @override
  String get navStats => 'Statistics';

  @override
  String get navSettings => 'Settings';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionClose => 'Close';

  @override
  String get actionReset => 'Reset';

  @override
  String get actionOpenSettings => 'Open settings';

  @override
  String get actionAllow => 'Allow';

  @override
  String get actionNotNow => 'Not now';

  @override
  String get monitoringOn => 'Monitoring is on';

  @override
  String get monitoringOff => 'Monitoring is off';

  @override
  String get monitoringOnBody =>
      'You will be alerted the moment the battery reaches 100%.';

  @override
  String get monitoringOffBody =>
      'Turn this on to be alerted when charging completes.';

  @override
  String get statusCharging => 'Charging';

  @override
  String get statusFull => 'Fully charged';

  @override
  String get statusDischarging => 'On battery';

  @override
  String get chargerAc => 'AC charger';

  @override
  String get chargerUsb => 'USB';

  @override
  String get chargerWireless => 'Wireless';

  @override
  String get chargerNone => 'Not connected';

  @override
  String get chargerOther => 'External power';

  @override
  String get alarmRinging => 'Alarm is ringing';

  @override
  String get alarmRingingBody => 'Unplug the charger, or stop it here.';

  @override
  String get actionStopAlarm => 'Stop alarm';

  @override
  String get actionTestAlarm => 'Test alarm';

  @override
  String get testAlarmStarted => 'Playing one alarm cycle…';

  @override
  String get detailsTitle => 'Battery details';

  @override
  String get detailTemperature => 'Temperature';

  @override
  String get detailVoltage => 'Voltage';

  @override
  String get detailHealth => 'Health';

  @override
  String get detailTechnology => 'Technology';

  @override
  String get detailCharger => 'Power source';

  @override
  String get healthGood => 'Good';

  @override
  String get healthOverheat => 'Overheating';

  @override
  String get healthDead => 'Dead';

  @override
  String get healthOverVoltage => 'Over voltage';

  @override
  String get healthCold => 'Cold';

  @override
  String get healthFailure => 'Failure';

  @override
  String get healthUnknown => 'Unknown';

  @override
  String get sessionTitle => 'Current charging session';

  @override
  String get sessionNone => 'Not charging right now.';

  @override
  String sessionStarted(String time) {
    return 'Started at $time';
  }

  @override
  String sessionGained(int from, int to) {
    return '$from% → $to%';
  }

  @override
  String sessionAlarms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alarms played',
      one: '1 alarm played',
      zero: 'No alarms yet',
    );
    return '$_temp0';
  }

  @override
  String get warnNotificationsTitle => 'Notifications are blocked';

  @override
  String get warnNotificationsBody =>
      'Android needs notification access to keep battery monitoring running.';

  @override
  String get warnBatteryOptimTitle => 'Battery optimisation is on';

  @override
  String get warnBatteryOptimBody =>
      'Android may stop monitoring in the background. Allow unrestricted battery use for reliable alarms.';

  @override
  String get warnServiceStoppedTitle => 'Monitoring service is not running';

  @override
  String get warnServiceStoppedBody =>
      'Turn monitoring off and on again to restart it.';

  @override
  String get warnTtsTitle => 'Voice not available for this language';

  @override
  String get warnTtsBody =>
      'Install the voice data in your device\'s text-to-speech settings, or the alarm will speak English.';

  @override
  String get actionTtsSettings => 'Text-to-speech settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionVoice => 'Voice announcement';

  @override
  String get sectionAlarm => 'Alarm';

  @override
  String get sectionAlerts => 'Alerts';

  @override
  String get sectionStartup => 'Startup';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get sectionData => 'Data';

  @override
  String get sectionAbout => 'About';

  @override
  String get settingUserName => 'Your name';

  @override
  String get settingUserNameHint => 'Used in the spoken message';

  @override
  String get settingUserNameEmpty => 'Not set';

  @override
  String get settingVoiceMessage => 'Announcement';

  @override
  String get settingVoiceEnabled => 'Speak the message';

  @override
  String get settingVoiceEnabledBody =>
      'Uses your phone\'s built-in text-to-speech.';

  @override
  String get settingSpeechRate => 'Speech speed';

  @override
  String get settingSpeechPitch => 'Speech pitch';

  @override
  String get settingAlarmSound => 'Alarm sound';

  @override
  String get settingAlarmSoundDefault => 'Default alarm';

  @override
  String get settingSoundEnabled => 'Play alarm sound';

  @override
  String get settingAlarmInterval => 'Repeat every';

  @override
  String get settingAlarmVolume => 'Alarm volume';

  @override
  String get settingVibration => 'Vibrate';

  @override
  String get settingFlash => 'Flash the torch';

  @override
  String get settingFlashUnavailable => 'This device has no flash';

  @override
  String get settingVibrationUnavailable =>
      'This device has no vibration motor';

  @override
  String get settingNotifications => 'Alarm notification';

  @override
  String get settingNotificationsBody =>
      'Shows a notification with a Stop button while the alarm rings. The ongoing monitor notification cannot be hidden — Android needs it to keep monitoring alive.';

  @override
  String get settingAutoStart => 'Start monitoring automatically';

  @override
  String get settingAutoStartBody =>
      'Re-arms monitoring when a charger is connected.';

  @override
  String get settingAutoStartBoot => 'Start after restart';

  @override
  String get settingAutoStartBootBody =>
      'Resume monitoring when the phone reboots.';

  @override
  String get settingLanguage => 'Language';

  @override
  String get settingTheme => 'Theme';

  @override
  String get settingBatteryOptimization => 'Background restrictions';

  @override
  String get settingBatteryOptimizationOk =>
      'Unrestricted — alarms are reliable';

  @override
  String get settingBatteryOptimizationBad =>
      'Restricted — alarms may be delayed';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUrdu => 'اردو';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String intervalSeconds(int count) {
    return '$count seconds';
  }

  @override
  String get intervalMinute => '1 minute';

  @override
  String get voiceTitle => 'Voice announcement';

  @override
  String get voiceMessageLabel => 'What should the phone say?';

  @override
  String get voiceMessageHelp =>
      'Tap a tag to insert it. Tags are replaced when the message is spoken.';

  @override
  String get voiceTokenName => 'Your name';

  @override
  String get voiceTokenLevel => 'Battery level';

  @override
  String get voicePreviewTitle => 'Preview';

  @override
  String get actionPlayPreview => 'Play preview';

  @override
  String get actionStopPreview => 'Stop';

  @override
  String get voicePresets => 'Suggestions';

  @override
  String get voiceMessageEmpty => 'The announcement cannot be empty.';

  @override
  String get voiceResetDefault => 'Restore the default message';

  @override
  String get soundTitle => 'Alarm sound';

  @override
  String get soundBuiltIn => 'On this device';

  @override
  String get soundCustom => 'Your sounds';

  @override
  String get soundCustomEmpty =>
      'Import an audio file or record your voice to add your own alarm.';

  @override
  String get actionImportAudio => 'Import audio file';

  @override
  String get actionRecordVoice => 'Record your voice';

  @override
  String get actionStopRecording => 'Stop recording';

  @override
  String get recordingInProgress => 'Recording… tap stop when you are done.';

  @override
  String get recordingSaved => 'Recording saved.';

  @override
  String get recordingFailed => 'The recording could not be saved.';

  @override
  String get recordingPermission =>
      'Microphone access is needed to record an alarm.';

  @override
  String get importFailed => 'That file could not be imported.';

  @override
  String get importCancelled => 'No file selected.';

  @override
  String get historyTitle => 'Charging history';

  @override
  String get historyEmpty => 'No charging sessions recorded yet.';

  @override
  String get historyEmptyBody =>
      'Plug in your charger and the session will appear here.';

  @override
  String get actionClearHistory => 'Clear history';

  @override
  String get historyClearConfirm => 'Delete every recorded charging session?';

  @override
  String get historyCleared => 'History cleared.';

  @override
  String get historyEntryDeleted => 'Entry deleted.';

  @override
  String get historyInProgress => 'In progress';

  @override
  String historyReachedFull(String duration) {
    return 'Reached 100% in $duration';
  }

  @override
  String get historyNeverFull => 'Did not reach 100%';

  @override
  String historyPluggedFor(String duration) {
    return 'Plugged in for $duration';
  }

  @override
  String historyAlarms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alarms',
      one: '1 alarm',
      zero: 'No alarms',
    );
    return '$_temp0';
  }

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsDaily => 'Today';

  @override
  String get statsWeekly => 'This week';

  @override
  String get statsMonthly => 'This month';

  @override
  String get statsNoData => 'No charging data for this period yet.';

  @override
  String get statsSessions => 'Charging sessions';

  @override
  String get statsFullCharges => 'Reached 100%';

  @override
  String get statsAvgChargeTime => 'Average time to full';

  @override
  String get statsAvgPluggedTime => 'Average time plugged in';

  @override
  String get statsTotalAlarms => 'Alarms played';

  @override
  String get statsAvgStartLevel => 'Average level when plugged in';

  @override
  String get statsEnergyGained => 'Average charge gained';

  @override
  String get statsChartTitle => 'Sessions per day';

  @override
  String get aboutTitle => 'About';

  @override
  String aboutVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String aboutDevice(String release, int sdk) {
    return 'Android $release (API $sdk)';
  }

  @override
  String get aboutOfflineTitle => 'Works completely offline';

  @override
  String get aboutOfflineBody =>
      'This app has no internet permission. Your name, message, recordings and history never leave the phone.';

  @override
  String get aboutPermissionsTitle => 'Permissions used';

  @override
  String get aboutHowItWorksTitle => 'How it works';

  @override
  String get aboutHowItWorksBody =>
      'A foreground service watches the system battery broadcast. When the level hits 100% while a charger is attached, the alarm sound, spoken message, vibration and torch repeat at your chosen interval until you unplug.';

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String durationMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String durationSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String get valueUnavailable => '—';

  @override
  String percentValue(int value) {
    return '$value%';
  }

  @override
  String get soundDeleteTitle => 'Delete alarm sound?';

  @override
  String get soundDeleteMessage =>
      'Are you sure you want to remove this alarm sound?';

  @override
  String get soundDeleteDeviceNote =>
      'This is one of your device\'s ringtones. It will be hidden from this list, not deleted from your phone, and you can restore it from Settings.';

  @override
  String get soundDeletedFile => 'Sound deleted.';

  @override
  String get soundHiddenFromList => 'Sound hidden. Restore it from Settings.';

  @override
  String get soundActiveFallback =>
      'That was your alarm sound, so the alarm switched back to your device\'s default.';

  @override
  String get soundNoneTitle => 'No sounds in the list';

  @override
  String get soundNoneBody =>
      'The alarm will use your device\'s default sound. Restore the built-in list to choose a different one.';

  @override
  String get settingRestoreSounds => 'Restore default sounds';

  @override
  String get settingRestoreSoundsNone => 'Nothing is hidden';

  @override
  String settingRestoreSoundsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sounds hidden',
      one: '1 sound hidden',
    );
    return '$_temp0';
  }

  @override
  String get restoreSoundsConfirm =>
      'Bring back every alarm sound you have hidden?';

  @override
  String soundsRestored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sounds restored',
      one: '1 sound restored',
      zero: 'Nothing to restore',
    );
    return '$_temp0';
  }
}
