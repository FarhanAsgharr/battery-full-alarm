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

  /// Deletes a custom sound, falling back to the default tone if it was in use.
  /// Returns true when the deleted sound was the selected one.
  Future<bool> delete(AlarmSound sound) async {
    await _repository.delete(sound);
    final wasSelected = _ref.read(settingsProvider).soundUri == sound.uri;
    if (wasSelected) await select(null);
    _ref.invalidate(soundLibraryProvider);
    return wasSelected;
  }
}
