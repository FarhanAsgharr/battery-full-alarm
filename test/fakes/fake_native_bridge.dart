import 'dart:async';

import 'package:battery_full_alarm/core/platform/native_bridge.dart';

/// An in-memory stand-in for the Kotlin side.
///
/// It records the calls the UI makes and lets a test push battery readings into the
/// event stream, which is what makes charging scenarios testable without a device.
class FakeNativeBridge extends NativeBridge {
  FakeNativeBridge({
    Map<String, dynamic>? initialState,
    Map<String, dynamic>? capabilities,
    List<Map<String, dynamic>>? history,
    Map<String, dynamic>? sounds,
  })  : _state = initialState ?? _defaultState(),
        _capabilities = capabilities ?? _defaultCapabilities(),
        _history = history ?? <Map<String, dynamic>>[],
        _sounds = sounds ?? _defaultSounds();

  final _controller = StreamController<Map<dynamic, dynamic>>.broadcast();

  Map<String, dynamic> _state;
  final Map<String, dynamic> _capabilities;
  final List<Map<String, dynamic>> _history;
  final Map<String, dynamic> _sounds;

  /// Every method name invoked, in order.
  final List<String> calls = <String>[];

  /// The last settings map pushed to the platform.
  Map<String, dynamic>? lastSettings;

  /// The most recent `previewSound` arguments.
  String? previewedUri;
  int? previewedVolume;

  bool monitoring = false;
  bool alarmStopped = false;
  bool testAlarmStarted = false;
  Map<String, dynamic>? nextImportResult;
  Map<String, dynamic>? nextRecordingResult;
  bool recordingStarts = true;

  // ------------------------------------------------------------ test controls

  /// Pushes a battery reading through the event channel, as the service would.
  void emit({
    int? level,
    bool? isPluggedIn,
    bool? alarming,
    bool? monitoringEnabled,
    bool? serviceRunning,
    Map<String, dynamic>? session,
  }) {
    final battery = Map<String, dynamic>.from(_state['battery'] as Map);
    if (level != null) battery['level'] = level;
    if (isPluggedIn != null) {
      battery['isPluggedIn'] = isPluggedIn;
      battery['isCharging'] = isPluggedIn;
      battery['plugName'] = isPluggedIn ? 'ac' : 'none';
    }
    battery['isFull'] = (battery['level'] as int) >= 100;

    _state = {
      ..._state,
      'battery': battery,
      // Null-aware entries: an omitted argument leaves the previous value in place.
      'alarming': ?alarming,
      'monitoring': ?monitoringEnabled,
      'serviceRunning': ?serviceRunning,
      'session': session ?? _state['session'],
    };
    _controller.add(Map<dynamic, dynamic>.from(_state));
  }

  void setHistory(List<Map<String, dynamic>> entries) {
    _history
      ..clear()
      ..addAll(entries);
  }

  Future<void> dispose() => _controller.close();

  // ---------------------------------------------------------------- overrides

  @override
  Stream<Map<dynamic, dynamic>> watchState() => _controller.stream;

  @override
  Future<Map<dynamic, dynamic>> getState() async {
    calls.add('getState');
    return Map<dynamic, dynamic>.from(_state);
  }

  @override
  Future<Map<dynamic, dynamic>> getCapabilities() async {
    calls.add('getCapabilities');
    return Map<dynamic, dynamic>.from(_capabilities);
  }

  @override
  Future<void> startMonitoring() async {
    calls.add('startMonitoring');
    monitoring = true;
    emit(monitoringEnabled: true, serviceRunning: true);
  }

  @override
  Future<void> stopMonitoring() async {
    calls.add('stopMonitoring');
    monitoring = false;
    emit(monitoringEnabled: false, serviceRunning: false, alarming: false);
  }

  @override
  Future<void> updateSettings(Map<String, dynamic> settings) async {
    calls.add('updateSettings');
    lastSettings = Map<String, dynamic>.from(settings);
  }

  @override
  Future<void> stopAlarm() async {
    calls.add('stopAlarm');
    alarmStopped = true;
    emit(alarming: false);
  }

  @override
  Future<void> testAlarm() async {
    calls.add('testAlarm');
    testAlarmStarted = true;
  }

  @override
  Future<void> stopTest() async {
    calls.add('stopTest');
    testAlarmStarted = false;
  }

  @override
  Future<void> previewSound({String? uri, int? volume}) async {
    calls.add('previewSound');
    previewedUri = uri;
    previewedVolume = volume;
  }

  @override
  Future<void> previewVoice() async => calls.add('previewVoice');

  @override
  Future<void> stopPreview() async => calls.add('stopPreview');

  @override
  Future<Map<dynamic, dynamic>> getSounds() async {
    calls.add('getSounds');
    return Map<dynamic, dynamic>.from(_sounds);
  }

  @override
  Future<Map<dynamic, dynamic>?> pickAudioFile() async {
    calls.add('pickAudioFile');
    return nextImportResult;
  }

  @override
  Future<bool> deleteSound(String uri) async {
    calls.add('deleteSound');
    final custom = (_sounds['custom'] as List).cast<Map<String, dynamic>>();
    final before = custom.length;
    custom.removeWhere((sound) => sound['uri'] == uri);
    return custom.length != before;
  }

  @override
  Future<bool> startRecording(String label) async {
    calls.add('startRecording');
    return recordingStarts;
  }

  @override
  Future<Map<dynamic, dynamic>?> stopRecording() async {
    calls.add('stopRecording');
    return nextRecordingResult;
  }

  @override
  Future<void> cancelRecording() async => calls.add('cancelRecording');

  @override
  Future<List<Map<dynamic, dynamic>>> getHistory() async {
    calls.add('getHistory');
    return _history.map(Map<dynamic, dynamic>.from).toList();
  }

  @override
  Future<void> deleteHistoryEntry(int id) async {
    calls.add('deleteHistoryEntry');
    _history.removeWhere((entry) => entry['id'] == id);
  }

  @override
  Future<void> clearHistory() async {
    calls.add('clearHistory');
    _history.clear();
  }

  @override
  Future<void> openBatteryOptimizationSettings() async =>
      calls.add('openBatteryOptimizationSettings');

  @override
  Future<void> openNotificationSettings() async => calls.add('openNotificationSettings');

  @override
  Future<void> openTtsSettings() async => calls.add('openTtsSettings');

  // ----------------------------------------------------------------- defaults

  static Map<String, dynamic> _defaultState() => {
        'battery': <String, dynamic>{
          'level': 62,
          'isCharging': false,
          'isPluggedIn': false,
          'isFull': false,
          'plugName': 'none',
          'temperature': 28.5,
          'voltage': 4150,
          'health': 'good',
          'technology': 'Li-ion',
        },
        'monitoring': false,
        'serviceRunning': false,
        'alarming': false,
        'session': null,
      };

  static Map<String, dynamic> _defaultCapabilities() => {
        'hasFlash': true,
        'hasVibrator': true,
        'ttsReady': true,
        'ttsLanguageAvailable': true,
        'ignoringBatteryOptimizations': true,
        'canRecord': true,
      };

  static Map<String, dynamic> _defaultSounds() => {
        'builtIn': <Map<String, dynamic>>[
          {
            'type': 'builtin',
            'uri': 'content://settings/system/alarm_alert',
            'label': 'Default alarm',
            'deletable': false,
          },
          {
            'type': 'builtin',
            'uri': 'content://media/internal/audio/media/12',
            'label': 'Oxygen',
            'deletable': false,
          },
        ],
        'custom': <Map<String, dynamic>>[],
      };
}
