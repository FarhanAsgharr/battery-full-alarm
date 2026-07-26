import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../constants/app_constants.dart';

/// The single seam between Dart and the Kotlin monitoring stack.
///
/// Every method mirrors a case in `MainActivity.handleMethodCall`. Keeping the whole
/// platform surface in one class means tests can swap it wholesale (see
/// `test/fakes/fake_native_bridge.dart`) without any real channel traffic.
class NativeBridge {
  NativeBridge({MethodChannel? methods, EventChannel? events})
      : _methods = methods ?? const MethodChannel(AppConstants.methodChannel),
        _events = events ?? const EventChannel(AppConstants.eventChannel);

  final MethodChannel _methods;
  final EventChannel _events;

  Stream<Map<dynamic, dynamic>>? _stream;

  /// Live monitor state. Broadcast so several widgets can listen without reopening
  /// the platform stream.
  Stream<Map<dynamic, dynamic>> watchState() => _stream ??= _events
      .receiveBroadcastStream()
      .where((event) => event is Map)
      .cast<Map<dynamic, dynamic>>()
      .asBroadcastStream();

  Future<Map<dynamic, dynamic>> getState() => _map('getState');

  Future<Map<dynamic, dynamic>> getCapabilities() => _map('getCapabilities');

  Future<void> startMonitoring() => _void('startMonitoring');

  Future<void> stopMonitoring() => _void('stopMonitoring');

  Future<void> updateSettings(Map<String, dynamic> settings) =>
      _void('updateSettings', settings);

  Future<void> stopAlarm() => _void('stopAlarm');

  Future<void> testAlarm() => _void('testAlarm');

  Future<void> stopTest() => _void('stopTest');

  Future<void> previewSound({String? uri, int? volume}) =>
      _void('previewSound', {'uri': uri, 'volume': volume});

  Future<void> previewVoice() => _void('previewVoice');

  Future<void> stopPreview() => _void('stopPreview');

  Future<Map<dynamic, dynamic>> getSounds() => _map('getSounds');

  /// Opens the system document picker and copies the chosen file into app storage.
  /// Returns null when the user cancels or no picker is available.
  Future<Map<dynamic, dynamic>?> pickAudioFile() async {
    final result = await _methods.invokeMethod<Map<dynamic, dynamic>>('pickAudioFile');
    return result;
  }

  Future<bool> deleteSound(String uri) async =>
      await _methods.invokeMethod<bool>('deleteSound', {'uri': uri}) ?? false;

  Future<bool> startRecording(String label) async =>
      await _methods.invokeMethod<bool>('startRecording', {'label': label}) ?? false;

  Future<Map<dynamic, dynamic>?> stopRecording() =>
      _methods.invokeMethod<Map<dynamic, dynamic>>('stopRecording');

  Future<void> cancelRecording() => _void('cancelRecording');

  Future<List<Map<dynamic, dynamic>>> getHistory() async {
    final result = await _methods.invokeMethod<List<dynamic>>('getHistory');
    return result?.whereType<Map<dynamic, dynamic>>().toList(growable: false) ?? const [];
  }

  Future<void> deleteHistoryEntry(int id) => _void('deleteHistoryEntry', {'id': id});

  Future<void> clearHistory() => _void('clearHistory');

  Future<void> openBatteryOptimizationSettings() =>
      _void('openBatteryOptimizationSettings');

  Future<void> openNotificationSettings() => _void('openNotificationSettings');

  Future<void> openTtsSettings() => _void('openTtsSettings');

  Future<Map<dynamic, dynamic>> _map(String method) async {
    final result = await _methods.invokeMethod<Map<dynamic, dynamic>>(method);
    return result ?? const {};
  }

  Future<void> _void(String method, [Object? arguments]) async {
    try {
      await _methods.invokeMethod<void>(method, arguments);
    } on MissingPluginException {
      // The host does not implement this call — only possible on a non-Android
      // target or in a widget test without a fake. Nothing to recover.
      debugPrint('NativeBridge: $method is not available on this platform');
    }
  }
}
