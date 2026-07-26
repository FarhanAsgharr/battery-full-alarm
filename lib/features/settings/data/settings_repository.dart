import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/platform/native_bridge.dart';
import '../domain/app_settings.dart';

/// Persists settings twice, on purpose.
///
/// `SharedPreferences` holds the copy the Flutter UI reads at launch; the native side
/// holds the copy the foreground service reads while the UI is dead. [save] writes both
/// so the alarm always behaves the way the last edited screen said it should.
class SettingsRepository {
  const SettingsRepository(this._preferences, this._bridge);

  final SharedPreferences _preferences;
  final NativeBridge _bridge;

  AppSettings load() {
    final raw = _preferences.getString(AppConstants.settingsStorageKey);
    if (raw == null || raw.isEmpty) return const AppSettings();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const AppSettings();
      return AppSettings.fromMap(decoded);
    } on FormatException catch (error) {
      // Corrupted entry — fall back to defaults rather than blocking startup.
      debugPrint('SettingsRepository: stored settings are unreadable ($error)');
      return const AppSettings();
    }
  }

  Future<void> save(AppSettings settings) async {
    final sanitized = settings.sanitized();
    final map = sanitized.toMap();
    await _preferences.setString(AppConstants.settingsStorageKey, jsonEncode(map));
    await _bridge.updateSettings(map);
  }
}
