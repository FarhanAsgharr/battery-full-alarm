/// Values shared across features. Anything that also exists on the Kotlin side is
/// noted so the two stay in step.
library;

class AppConstants {
  const AppConstants._();

  /// Mirrors `com.hananideas.batteryalarm.core.Channels`.
  static const methodChannel = 'com.hananideas.batteryalarm/methods';
  static const eventChannel = 'com.hananideas.batteryalarm/events';

  /// Mirrors `AppSettings.ALLOWED_INTERVALS` in Kotlin.
  static const alarmIntervals = <int>[5, 10, 15, 30, 60];

  /// Mirrors `AppSettings.DEFAULT_MESSAGE` in Kotlin.
  static const defaultVoiceMessage =
      '{name}, your phone battery is fully charged. Please remove the charger.';

  /// Placeholders understood by [MessageTemplate] and by Kotlin's `MessageFormatter`.
  static const nameToken = '{name}';
  static const levelToken = '{level}';

  static const minSpeechRate = 0.5;
  static const maxSpeechRate = 2.0;
  static const minSpeechPitch = 0.5;
  static const maxSpeechPitch = 2.0;

  static const minAlarmVolume = 10;
  static const maxAlarmVolume = 100;

  static const maxUserNameLength = 40;
  static const maxVoiceMessageLength = 300;

  /// The battery level that triggers the alarm. Fixed at 100% by design.
  static const fullBatteryLevel = 100;

  static const settingsStorageKey = 'app_settings_v1';
}
