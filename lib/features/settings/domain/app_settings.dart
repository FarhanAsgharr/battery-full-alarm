import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

/// The four languages the UI and the spoken announcement support.
enum AppLanguage {
  english('en'),
  urdu('ur'),
  arabic('ar'),
  hindi('hi');

  const AppLanguage(this.code);

  final String code;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) => AppLanguage.values.firstWhere(
        (language) => language.code == code,
        orElse: () => AppLanguage.english,
      );
}

enum AppThemeChoice {
  system('system', ThemeMode.system),
  light('light', ThemeMode.light),
  dark('dark', ThemeMode.dark);

  const AppThemeChoice(this.code, this.themeMode);

  final String code;
  final ThemeMode themeMode;

  static AppThemeChoice fromCode(String? code) => AppThemeChoice.values.firstWhere(
        (choice) => choice.code == code,
        orElse: () => AppThemeChoice.system,
      );
}

/// Every user-configurable value.
///
/// Kept in lockstep with `AppSettings.kt`: the same map shape crosses the method
/// channel in both directions, so a field added here must be added there too.
@immutable
class AppSettings {
  const AppSettings({
    this.userName = '',
    this.voiceMessage = AppConstants.defaultVoiceMessage,
    this.voiceEnabled = true,
    this.speechRate = 1.0,
    this.speechPitch = 1.0,
    this.language = AppLanguage.english,
    this.alarmIntervalSeconds = 10,
    this.alarmVolumePercent = 80,
    this.soundEnabled = true,
    this.soundUri = '',
    this.soundLabel = '',
    this.vibrationEnabled = true,
    this.flashEnabled = false,
    this.notificationsEnabled = true,
    this.autoStartMonitoring = true,
    this.autoStartAfterBoot = true,
    this.themeChoice = AppThemeChoice.system,
  });

  final String userName;
  final String voiceMessage;
  final bool voiceEnabled;
  final double speechRate;
  final double speechPitch;
  final AppLanguage language;
  final int alarmIntervalSeconds;
  final int alarmVolumePercent;
  final bool soundEnabled;

  /// Empty means "use the device's default alarm tone".
  final String soundUri;
  final String soundLabel;
  final bool vibrationEnabled;
  final bool flashEnabled;
  final bool notificationsEnabled;
  final bool autoStartMonitoring;
  final bool autoStartAfterBoot;
  final AppThemeChoice themeChoice;

  AppSettings copyWith({
    String? userName,
    String? voiceMessage,
    bool? voiceEnabled,
    double? speechRate,
    double? speechPitch,
    AppLanguage? language,
    int? alarmIntervalSeconds,
    int? alarmVolumePercent,
    bool? soundEnabled,
    String? soundUri,
    String? soundLabel,
    bool? vibrationEnabled,
    bool? flashEnabled,
    bool? notificationsEnabled,
    bool? autoStartMonitoring,
    bool? autoStartAfterBoot,
    AppThemeChoice? themeChoice,
  }) {
    return AppSettings(
      userName: userName ?? this.userName,
      voiceMessage: voiceMessage ?? this.voiceMessage,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      speechRate: speechRate ?? this.speechRate,
      speechPitch: speechPitch ?? this.speechPitch,
      language: language ?? this.language,
      alarmIntervalSeconds: alarmIntervalSeconds ?? this.alarmIntervalSeconds,
      alarmVolumePercent: alarmVolumePercent ?? this.alarmVolumePercent,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      soundUri: soundUri ?? this.soundUri,
      soundLabel: soundLabel ?? this.soundLabel,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      flashEnabled: flashEnabled ?? this.flashEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoStartMonitoring: autoStartMonitoring ?? this.autoStartMonitoring,
      autoStartAfterBoot: autoStartAfterBoot ?? this.autoStartAfterBoot,
      themeChoice: themeChoice ?? this.themeChoice,
    );
  }

  /// Clamps every value into its supported range. Applied on load and before save so
  /// hand-edited or stale stored data can never put the alarm into an odd state.
  AppSettings sanitized() {
    final trimmedName = userName.trim();
    final trimmedMessage = voiceMessage.trim();
    return copyWith(
      userName: trimmedName.length > AppConstants.maxUserNameLength
          ? trimmedName.substring(0, AppConstants.maxUserNameLength)
          : trimmedName,
      voiceMessage: trimmedMessage.isEmpty
          ? AppConstants.defaultVoiceMessage
          : (trimmedMessage.length > AppConstants.maxVoiceMessageLength
              ? trimmedMessage.substring(0, AppConstants.maxVoiceMessageLength)
              : trimmedMessage),
      speechRate: speechRate.clamp(AppConstants.minSpeechRate, AppConstants.maxSpeechRate),
      speechPitch: speechPitch.clamp(AppConstants.minSpeechPitch, AppConstants.maxSpeechPitch),
      alarmIntervalSeconds: AppConstants.alarmIntervals.contains(alarmIntervalSeconds)
          ? alarmIntervalSeconds
          : _nearestInterval(alarmIntervalSeconds),
      alarmVolumePercent:
          alarmVolumePercent.clamp(AppConstants.minAlarmVolume, AppConstants.maxAlarmVolume),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'userName': userName,
        'voiceMessage': voiceMessage,
        'voiceEnabled': voiceEnabled,
        'speechRate': speechRate,
        'speechPitch': speechPitch,
        'language': language.code,
        'alarmIntervalSeconds': alarmIntervalSeconds,
        'alarmVolumePercent': alarmVolumePercent,
        'soundEnabled': soundEnabled,
        'soundUri': soundUri,
        'soundLabel': soundLabel,
        'vibrationEnabled': vibrationEnabled,
        'flashEnabled': flashEnabled,
        'notificationsEnabled': notificationsEnabled,
        'autoStartMonitoring': autoStartMonitoring,
        'autoStartAfterBoot': autoStartAfterBoot,
        'themeMode': themeChoice.code,
      };

  /// Tolerant of anything: a corrupted preferences entry or a stale native map must
  /// degrade to defaults, never throw during startup.
  factory AppSettings.fromMap(Map<dynamic, dynamic> map) {
    const defaults = AppSettings();
    T pick<T>(String key, T fallback) {
      final value = map[key];
      return value is T ? value : fallback;
    }

    double number(String key, double fallback) {
      final value = map[key];
      return value is num ? value.toDouble() : fallback;
    }

    int integer(String key, int fallback) {
      final value = map[key];
      return value is num ? value.toInt() : fallback;
    }

    return AppSettings(
      userName: pick('userName', defaults.userName),
      voiceMessage: pick('voiceMessage', defaults.voiceMessage),
      voiceEnabled: pick('voiceEnabled', defaults.voiceEnabled),
      speechRate: number('speechRate', defaults.speechRate),
      speechPitch: number('speechPitch', defaults.speechPitch),
      language: AppLanguage.fromCode(pick<String?>('language', null)),
      alarmIntervalSeconds: integer('alarmIntervalSeconds', defaults.alarmIntervalSeconds),
      alarmVolumePercent: integer('alarmVolumePercent', defaults.alarmVolumePercent),
      soundEnabled: pick('soundEnabled', defaults.soundEnabled),
      soundUri: pick('soundUri', defaults.soundUri),
      soundLabel: pick('soundLabel', defaults.soundLabel),
      vibrationEnabled: pick('vibrationEnabled', defaults.vibrationEnabled),
      flashEnabled: pick('flashEnabled', defaults.flashEnabled),
      notificationsEnabled: pick('notificationsEnabled', defaults.notificationsEnabled),
      autoStartMonitoring: pick('autoStartMonitoring', defaults.autoStartMonitoring),
      autoStartAfterBoot: pick('autoStartAfterBoot', defaults.autoStartAfterBoot),
      themeChoice: AppThemeChoice.fromCode(pick<String?>('themeMode', null)),
    ).sanitized();
  }

  static int _nearestInterval(int value) {
    var best = AppConstants.alarmIntervals.first;
    for (final option in AppConstants.alarmIntervals) {
      if ((option - value).abs() < (best - value).abs()) best = option;
    }
    return best;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          other.userName == userName &&
          other.voiceMessage == voiceMessage &&
          other.voiceEnabled == voiceEnabled &&
          other.speechRate == speechRate &&
          other.speechPitch == speechPitch &&
          other.language == language &&
          other.alarmIntervalSeconds == alarmIntervalSeconds &&
          other.alarmVolumePercent == alarmVolumePercent &&
          other.soundEnabled == soundEnabled &&
          other.soundUri == soundUri &&
          other.soundLabel == soundLabel &&
          other.vibrationEnabled == vibrationEnabled &&
          other.flashEnabled == flashEnabled &&
          other.notificationsEnabled == notificationsEnabled &&
          other.autoStartMonitoring == autoStartMonitoring &&
          other.autoStartAfterBoot == autoStartAfterBoot &&
          other.themeChoice == themeChoice;

  @override
  int get hashCode => Object.hashAll([
        userName,
        voiceMessage,
        voiceEnabled,
        speechRate,
        speechPitch,
        language,
        alarmIntervalSeconds,
        alarmVolumePercent,
        soundEnabled,
        soundUri,
        soundLabel,
        vibrationEnabled,
        flashEnabled,
        notificationsEnabled,
        autoStartMonitoring,
        autoStartAfterBoot,
        themeChoice,
      ]);
}
