import '../../../core/platform/native_bridge.dart';
import '../domain/alarm_sound.dart';

/// The alarm sound catalogue and the operations that change it.
///
/// Importing and recording are handled natively — an `ACTION_OPEN_DOCUMENT` intent and
/// `MediaRecorder` — so no third-party picker or recorder package is needed and the
/// files land directly in the app's private storage.
class SoundRepository {
  SoundRepository(this._bridge);

  final NativeBridge _bridge;

  Future<AlarmSoundLibrary> load() async =>
      AlarmSoundLibrary.fromMap(await _bridge.getSounds());

  /// Returns the imported sound, or null when the user cancelled the picker.
  Future<AlarmSound?> importFile() async {
    final result = await _bridge.pickAudioFile();
    return result == null ? null : AlarmSound.fromMap(result);
  }

  Future<bool> delete(AlarmSound sound) => _bridge.deleteSound(sound.uri);

  Future<bool> startRecording(String label) => _bridge.startRecording(label);

  /// Returns the saved clip, or null when nothing usable was captured.
  Future<AlarmSound?> stopRecording() async {
    final result = await _bridge.stopRecording();
    return result == null ? null : AlarmSound.fromMap(result);
  }

  Future<void> cancelRecording() => _bridge.cancelRecording();

  Future<void> preview(AlarmSound? sound, int volumePercent) =>
      _bridge.previewSound(uri: sound?.uri, volume: volumePercent);

  Future<void> previewVoice() => _bridge.previewVoice();

  Future<void> stopPreview() => _bridge.stopPreview();
}
