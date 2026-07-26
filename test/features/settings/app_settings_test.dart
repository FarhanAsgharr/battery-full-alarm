import 'package:battery_full_alarm/core/constants/app_constants.dart';
import 'package:battery_full_alarm/features/settings/domain/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSettings.sanitized', () {
    test('snaps an unsupported interval to the nearest allowed value', () {
      expect(
        const AppSettings(alarmIntervalSeconds: 17).sanitized().alarmIntervalSeconds,
        15,
      );
      expect(
        const AppSettings(alarmIntervalSeconds: 1).sanitized().alarmIntervalSeconds,
        5,
      );
      expect(
        const AppSettings(alarmIntervalSeconds: 900).sanitized().alarmIntervalSeconds,
        60,
      );
    });

    test('clamps the volume into an audible range', () {
      expect(const AppSettings(alarmVolumePercent: -5).sanitized().alarmVolumePercent, 10);
      expect(const AppSettings(alarmVolumePercent: 250).sanitized().alarmVolumePercent, 100);
    });

    test('clamps speech rate and pitch', () {
      const extreme = AppSettings(speechRate: 9, speechPitch: 0.01);
      expect(extreme.sanitized().speechRate, AppConstants.maxSpeechRate);
      expect(extreme.sanitized().speechPitch, AppConstants.minSpeechPitch);
    });

    test('restores the default message when the announcement is blank', () {
      expect(
        const AppSettings(voiceMessage: '   ').sanitized().voiceMessage,
        AppConstants.defaultVoiceMessage,
      );
    });

    test('trims and truncates an overlong name', () {
      final settings = AppSettings(userName: '  ${'x' * 200}  ').sanitized();
      expect(settings.userName.length, AppConstants.maxUserNameLength);
    });
  });

  group('serialisation', () {
    test('round-trips through the platform map', () {
      const original = AppSettings(
        userName: 'Muhammad',
        voiceMessage: '{name}, unplug it.',
        alarmIntervalSeconds: 30,
        alarmVolumePercent: 65,
        flashEnabled: true,
        language: AppLanguage.urdu,
        themeChoice: AppThemeChoice.dark,
      );

      expect(AppSettings.fromMap(original.toMap()), original);
    });

    test('falls back to defaults for missing keys', () {
      final parsed = AppSettings.fromMap(const {'userName': 'Ali'});

      expect(parsed.userName, 'Ali');
      expect(parsed.alarmIntervalSeconds, const AppSettings().alarmIntervalSeconds);
      expect(parsed.language, AppLanguage.english);
    });

    test('ignores values of the wrong type instead of throwing', () {
      final parsed = AppSettings.fromMap(const {
        'userName': 42,
        'voiceEnabled': 'yes',
        'alarmVolumePercent': 'loud',
      });

      expect(parsed.userName, '');
      expect(parsed.voiceEnabled, true);
      expect(parsed.alarmVolumePercent, const AppSettings().alarmVolumePercent);
    });

    test('the map keys match the ones Kotlin reads', () {
      // Guards against a rename on one side silently dropping a setting.
      expect(
        const AppSettings().toMap().keys.toSet(),
        {
          'userName',
          'voiceMessage',
          'voiceEnabled',
          'speechRate',
          'speechPitch',
          'language',
          'alarmIntervalSeconds',
          'alarmVolumePercent',
          'soundEnabled',
          'soundUri',
          'soundLabel',
          'vibrationEnabled',
          'flashEnabled',
          'notificationsEnabled',
          'autoStartMonitoring',
          'autoStartAfterBoot',
          'themeMode',
        },
      );
    });
  });

  group('enums', () {
    test('language codes map to locales', () {
      expect(AppLanguage.fromCode('ur'), AppLanguage.urdu);
      expect(AppLanguage.fromCode('ar').locale, const Locale('ar'));
      expect(AppLanguage.fromCode('nonsense'), AppLanguage.english);
    });

    test('theme codes map to Flutter theme modes', () {
      expect(AppThemeChoice.fromCode('dark').themeMode, ThemeMode.dark);
      expect(AppThemeChoice.fromCode(null).themeMode, ThemeMode.system);
    });
  });
}
