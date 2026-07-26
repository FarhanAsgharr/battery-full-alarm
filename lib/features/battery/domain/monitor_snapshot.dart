import 'package:flutter/foundation.dart';

import '../../history/domain/charge_session.dart';
import 'battery_status.dart';

/// Everything the native monitor knows, as one immutable value.
///
/// Emitted on the event channel whenever the battery changes, the alarm starts or
/// stops, or monitoring is switched on or off.
@immutable
class MonitorSnapshot {
  const MonitorSnapshot({
    this.battery = const BatteryStatus(),
    this.monitoringEnabled = false,
    this.serviceRunning = false,
    this.alarming = false,
    this.session,
  });

  final BatteryStatus battery;

  /// The user's switch. True even if the service was killed and is restarting.
  final bool monitoringEnabled;

  /// Whether the foreground service is alive right now.
  final bool serviceRunning;
  final bool alarming;
  final ChargeSession? session;

  /// Monitoring is on but the service that does the work is not — the one state the
  /// UI has to surface, because alarms would silently not fire.
  bool get isDegraded => monitoringEnabled && !serviceRunning;

  factory MonitorSnapshot.fromMap(Map<dynamic, dynamic> map) {
    final batteryMap = map['battery'];
    final sessionMap = map['session'];
    return MonitorSnapshot(
      battery: batteryMap is Map ? BatteryStatus.fromMap(batteryMap) : const BatteryStatus(),
      monitoringEnabled: map['monitoring'] as bool? ?? false,
      serviceRunning: map['serviceRunning'] as bool? ?? false,
      alarming: map['alarming'] as bool? ?? false,
      session: sessionMap is Map ? ChargeSession.fromMap(sessionMap) : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonitorSnapshot &&
          other.battery == battery &&
          other.monitoringEnabled == monitoringEnabled &&
          other.serviceRunning == serviceRunning &&
          other.alarming == alarming &&
          other.session == session;

  @override
  int get hashCode =>
      Object.hash(battery, monitoringEnabled, serviceRunning, alarming, session);
}

/// Optional hardware and platform features, queried once at startup so the UI can hide
/// switches the device cannot honour.
@immutable
class DeviceCapabilities {
  const DeviceCapabilities({
    this.hasFlash = false,
    this.hasVibrator = false,
    this.ttsReady = false,
    this.ttsLanguageAvailable = true,
    this.ignoringBatteryOptimizations = true,
    this.canRecord = false,
  });

  final bool hasFlash;
  final bool hasVibrator;
  final bool ttsReady;
  final bool ttsLanguageAvailable;
  final bool ignoringBatteryOptimizations;
  final bool canRecord;

  factory DeviceCapabilities.fromMap(Map<dynamic, dynamic> map) => DeviceCapabilities(
        hasFlash: map['hasFlash'] as bool? ?? false,
        hasVibrator: map['hasVibrator'] as bool? ?? false,
        ttsReady: map['ttsReady'] as bool? ?? false,
        ttsLanguageAvailable: map['ttsLanguageAvailable'] as bool? ?? true,
        ignoringBatteryOptimizations: map['ignoringBatteryOptimizations'] as bool? ?? true,
        canRecord: map['canRecord'] as bool? ?? false,
      );
}
