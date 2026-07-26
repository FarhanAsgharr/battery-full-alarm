import '../../../core/platform/native_bridge.dart';
import '../domain/monitor_snapshot.dart';

/// Read/command access to the native battery monitor.
class BatteryRepository {
  BatteryRepository(this._bridge);

  final NativeBridge _bridge;

  /// Live monitor state, starting with the current value so the UI never flashes empty.
  Stream<MonitorSnapshot> watch() async* {
    yield await snapshot();
    yield* _bridge.watchState().map(MonitorSnapshot.fromMap);
  }

  Future<MonitorSnapshot> snapshot() async =>
      MonitorSnapshot.fromMap(await _bridge.getState());

  Future<DeviceCapabilities> capabilities() async =>
      DeviceCapabilities.fromMap(await _bridge.getCapabilities());

  Future<void> startMonitoring() => _bridge.startMonitoring();

  Future<void> stopMonitoring() => _bridge.stopMonitoring();

  Future<void> stopAlarm() => _bridge.stopAlarm();

  Future<void> testAlarm() => _bridge.testAlarm();

  Future<void> stopTest() => _bridge.stopTest();

  Future<void> openBatteryOptimizationSettings() =>
      _bridge.openBatteryOptimizationSettings();

  Future<void> openNotificationSettings() => _bridge.openNotificationSettings();

  Future<void> openTtsSettings() => _bridge.openTtsSettings();
}
