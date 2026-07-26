import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/settings_repository.dart';
import '../domain/app_settings.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(
    ref.watch(sharedPreferencesProvider),
    ref.watch(nativeBridgeProvider),
  );
});

/// The single source of truth for settings in the UI.
///
/// Every mutation goes through [SettingsController], which writes to storage and pushes
/// the new values to the native service before the new state is visible — so what the
/// screen shows and what the alarm does can never drift apart.
final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(settingsRepositoryProvider).load();

  Future<void> update(AppSettings settings) async {
    final sanitized = settings.sanitized();
    if (sanitized == state) return;
    state = sanitized;
    await ref.read(settingsRepositoryProvider).save(sanitized);
  }

  Future<void> edit(AppSettings Function(AppSettings current) change) =>
      update(change(state));

  /// Re-pushes the current values to the native side. Called once at startup so a
  /// freshly installed or restored app has native storage populated before the first
  /// charge, and after the process is recreated.
  Future<void> syncToPlatform() =>
      ref.read(settingsRepositoryProvider).save(state);
}
