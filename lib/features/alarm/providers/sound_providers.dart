import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../settings/providers/settings_providers.dart';
import '../data/sound_repository.dart';
import '../domain/alarm_sound.dart';

final soundRepositoryProvider = Provider<SoundRepository>(
  (ref) => SoundRepository(ref.watch(nativeBridgeProvider)),
);

final soundLibraryProvider = FutureProvider<AlarmSoundLibrary>(
  (ref) => ref.watch(soundRepositoryProvider).load(),
);

/// True while a voice clip is being captured. Drives the record button's state.
final isRecordingProvider = StateProvider<bool>((ref) => false);

final soundControllerProvider = Provider<SoundController>(
  (ref) => SoundController(ref),
);

/// Outcome of removing a sound, with enough detail for the UI to word the result.
class SoundRemovalResult {
  const SoundRemovalResult({required this.outcome, required this.wasActiveAlarm});

  final AlarmSoundRemoval outcome;

  /// True when the removed sound had been the selected alarm, and the selection has
  /// therefore been reset to the device default.
  final bool wasActiveAlarm;
}

class SoundController {
  SoundController(this._ref);

  final Ref _ref;

  SoundRepository get _repository => _ref.read(soundRepositoryProvider);

  Future<void> select(AlarmSound? sound) async {
    await _ref.read(settingsProvider.notifier).edit(
          (current) => current.copyWith(
            soundUri: sound?.uri ?? '',
            soundLabel: sound?.label ?? '',
          ),
        );
  }

  Future<void> preview(AlarmSound? sound) => _repository.preview(
        sound,
        _ref.read(settingsProvider).alarmVolumePercent,
      );

  Future<void> stopPreview() => _repository.stopPreview();

  /// Returns the imported sound, or null when the user cancelled.
  Future<AlarmSound?> importFile() async {
    final imported = await _repository.importFile();
    if (imported != null) _ref.invalidate(soundLibraryProvider);
    return imported;
  }

  Future<bool> startRecording(String label) async {
    final started = await _repository.startRecording(label);
    _ref.read(isRecordingProvider.notifier).state = started;
    return started;
  }

  Future<AlarmSound?> stopRecording() async {
    final saved = await _repository.stopRecording();
    _ref.read(isRecordingProvider.notifier).state = false;
    if (saved != null) _ref.invalidate(soundLibraryProvider);
    return saved;
  }

  Future<void> cancelRecording() async {
    await _repository.cancelRecording();
    _ref.read(isRecordingProvider.notifier).state = false;
  }

  /// Removes a sound from the picker.
  ///
  /// A file the user imported or recorded is deleted; a device ringtone is hidden and
  /// can be brought back with [restoreDefaults]. If the sound was the active alarm, the
  /// selection falls back to the device default so the alarm can never point at
  /// something that is no longer there.
  Future<SoundRemovalResult> remove(AlarmSound sound) async {
    final wasSelected = _ref.read(settingsProvider).soundUri == sound.uri;
    final outcome = await _repository.remove(sound);
    if (wasSelected) await select(null);
    _ref.invalidate(soundLibraryProvider);
    return SoundRemovalResult(outcome: outcome, wasActiveAlarm: wasSelected);
  }

  /// Brings back every hidden device sound. Returns how many were restored.
  Future<int> restoreDefaults() async {
    final restored = await _repository.restoreDefaults();
    _ref.invalidate(soundLibraryProvider);
    return restored;
  }
}
