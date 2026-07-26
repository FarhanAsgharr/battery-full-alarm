import 'package:battery_full_alarm/features/battery/domain/battery_status.dart';
import 'package:battery_full_alarm/features/battery/domain/monitor_snapshot.dart';
import 'package:battery_full_alarm/features/battery/providers/battery_providers.dart';
import 'package:battery_full_alarm/features/settings/domain/app_settings.dart';
import 'package:battery_full_alarm/features/settings/providers/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_native_bridge.dart';
import '../../helpers/test_harness.dart';

/// Battery simulation and background-service behaviour, driven through the same
/// providers the UI uses but with the platform layer faked.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeNativeBridge bridge;

  setUp(() => bridge = FakeNativeBridge());
  tearDown(() => bridge.dispose());

  group('decoding platform state', () {
    test('reads a discharging battery', () {
      final snapshot = MonitorSnapshot.fromMap(const {
        'battery': {
          'level': 55,
          'isCharging': false,
          'isPluggedIn': false,
          'plugName': 'none',
          'temperature': 30.0,
          'voltage': 4000,
          'health': 'good',
          'technology': 'Li-ion',
        },
        'monitoring': true,
        'serviceRunning': true,
        'alarming': false,
      });

      expect(snapshot.battery.level, 55);
      expect(snapshot.battery.isFull, isFalse);
      expect(snapshot.battery.source, PowerSource.none);
      expect(snapshot.battery.health, BatteryHealth.good);
      expect(snapshot.isDegraded, isFalse);
    });

    test('flags a degraded monitor when the service is not running', () {
      const snapshot = MonitorSnapshot(monitoringEnabled: true, serviceRunning: false);
      expect(snapshot.isDegraded, isTrue);
    });

    test('an unknown plug name decodes as no power source', () {
      final battery = BatteryStatus.fromMap(const {'level': 10, 'plugName': 'mystery'});
      expect(battery.source, PowerSource.none);
    });

    test('a missing battery map yields safe defaults instead of throwing', () {
      final snapshot = MonitorSnapshot.fromMap(const {});

      expect(snapshot.battery.level, 0);
      expect(snapshot.monitoringEnabled, isFalse);
      expect(snapshot.session, isNull);
    });
  });

  group('charging simulation', () {
    test('the monitor stream tracks a full charge-and-unplug cycle', () async {
      final container = await buildContainer(bridge: bridge);
      final states = <MonitorSnapshot>[];
      final subscription = container.listen(
        monitorStreamProvider,
        (_, next) {
          final value = next.valueOrNull;
          if (value != null) states.add(value);
        },
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      // Charger goes in at 62%, climbs to 100%, alarm fires, user unplugs.
      await container.read(monitorControllerProvider).setMonitoring(true);
      await pumpEventQueue();
      bridge.emit(level: 62, isPluggedIn: true);
      await pumpEventQueue();
      bridge.emit(level: 100);
      await pumpEventQueue();
      bridge.emit(alarming: true);
      await pumpEventQueue();
      bridge.emit(level: 100, isPluggedIn: false, alarming: false);
      await pumpEventQueue();

      expect(states.any((state) => state.battery.isPluggedIn && state.battery.level == 62), isTrue);
      expect(states.any((state) => state.battery.isFull && state.alarming), isTrue);
      expect(states.last.alarming, isFalse);
      expect(states.last.battery.isPluggedIn, isFalse);
    });
  });

  group('monitoring controls', () {
    test('turning monitoring on starts the native service', () async {
      final container = await buildContainer(bridge: bridge);

      await container.read(monitorControllerProvider).setMonitoring(true);

      expect(bridge.calls, contains('startMonitoring'));
      expect(bridge.monitoring, isTrue);
    });

    test('turning monitoring off stops the native service', () async {
      final container = await buildContainer(bridge: bridge);

      await container.read(monitorControllerProvider).setMonitoring(true);
      await container.read(monitorControllerProvider).setMonitoring(false);

      expect(bridge.calls, contains('stopMonitoring'));
      expect(bridge.monitoring, isFalse);
    });

    test('stopping the alarm reaches the platform', () async {
      final container = await buildContainer(bridge: bridge);

      await container.read(monitorControllerProvider).stopAlarm();

      expect(bridge.alarmStopped, isTrue);
    });

    test('the test alarm starts and can be cancelled', () async {
      final container = await buildContainer(bridge: bridge);
      final controller = container.read(monitorControllerProvider);

      await controller.testAlarm();
      expect(bridge.testAlarmStarted, isTrue);

      await controller.stopTest();
      expect(bridge.testAlarmStarted, isFalse);
    });
  });

  group('settings propagation', () {
    test('every change is pushed to the native service', () async {
      final container = await buildContainer(bridge: bridge);

      await container.read(settingsProvider.notifier).edit(
            (current) => current.copyWith(
              userName: 'Muhammad',
              alarmIntervalSeconds: 30,
              flashEnabled: true,
            ),
          );

      expect(bridge.lastSettings, isNotNull);
      expect(bridge.lastSettings!['userName'], 'Muhammad');
      expect(bridge.lastSettings!['alarmIntervalSeconds'], 30);
      expect(bridge.lastSettings!['flashEnabled'], true);
    });

    test('settings survive a restart through shared preferences', () async {
      final first = await buildContainer(bridge: bridge);
      await first
          .read(settingsProvider.notifier)
          .edit((current) => current.copyWith(userName: 'Ali', language: AppLanguage.urdu));

      // A new container over the same backing store, as a relaunch would be.
      final second = await buildContainer(bridge: bridge, resetStore: false);
      final restored = second.read(settingsProvider);

      expect(restored.userName, 'Ali');
      expect(restored.language, AppLanguage.urdu);
    });

    test('an out-of-range value never reaches the platform', () async {
      final container = await buildContainer(bridge: bridge);

      await container
          .read(settingsProvider.notifier)
          .edit((current) => current.copyWith(alarmVolumePercent: 400));

      expect(bridge.lastSettings!['alarmVolumePercent'], 100);
    });
  });
}
