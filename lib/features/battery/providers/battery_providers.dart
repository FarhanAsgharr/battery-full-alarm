import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/battery_repository.dart';
import '../domain/monitor_snapshot.dart';

final batteryRepositoryProvider = Provider<BatteryRepository>(
  (ref) => BatteryRepository(ref.watch(nativeBridgeProvider)),
);

/// Live state from the foreground service.
final monitorStreamProvider = StreamProvider<MonitorSnapshot>(
  (ref) => ref.watch(batteryRepositoryProvider).watch(),
);

/// The value widgets actually read: the last known snapshot, defaulting to an empty one
/// while the first platform message is in flight.
final monitorProvider = Provider<MonitorSnapshot>((ref) {
  return ref.watch(monitorStreamProvider).maybeWhen(
        data: (snapshot) => snapshot,
        orElse: () => const MonitorSnapshot(),
      );
});

/// Optional hardware support. Refreshed on demand after permission changes.
final capabilitiesProvider = FutureProvider<DeviceCapabilities>(
  (ref) => ref.watch(batteryRepositoryProvider).capabilities(),
);

/// Commands the home screen issues. Separated from [monitorProvider] so reading state
/// never pulls in the side-effecting methods.
final monitorControllerProvider = Provider<MonitorController>(
  (ref) => MonitorController(ref),
);

class MonitorController {
  MonitorController(this._ref);

  final Ref _ref;

  BatteryRepository get _repository => _ref.read(batteryRepositoryProvider);

  Future<void> setMonitoring(bool enabled) async {
    if (enabled) {
      await _repository.startMonitoring();
    } else {
      await _repository.stopMonitoring();
    }
    _ref.invalidate(capabilitiesProvider);
  }

  Future<void> stopAlarm() => _repository.stopAlarm();

  Future<void> testAlarm() => _repository.testAlarm();

  Future<void> stopTest() => _repository.stopTest();

  Future<void> openBatteryOptimizationSettings() =>
      _repository.openBatteryOptimizationSettings();

  Future<void> openNotificationSettings() => _repository.openNotificationSettings();

  Future<void> openTtsSettings() => _repository.openTtsSettings();

  void refreshCapabilities() => _ref.invalidate(capabilitiesProvider);
}
