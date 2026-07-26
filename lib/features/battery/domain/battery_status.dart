import 'package:flutter/foundation.dart';

/// How the phone is receiving power.
enum PowerSource { none, ac, usb, wireless, other }

/// Battery health as reported by the platform.
enum BatteryHealth { good, overheat, dead, overVoltage, cold, failure, unknown }

/// A decoded battery reading pushed up from `BatterySnapshot.kt`.
@immutable
class BatteryStatus {
  const BatteryStatus({
    this.level = 0,
    this.isCharging = false,
    this.isPluggedIn = false,
    this.source = PowerSource.none,
    this.temperatureCelsius = 0,
    this.voltageMilliVolts = 0,
    this.health = BatteryHealth.unknown,
    this.technology = '',
  });

  final int level;
  final bool isCharging;
  final bool isPluggedIn;
  final PowerSource source;
  final double temperatureCelsius;
  final int voltageMilliVolts;
  final BatteryHealth health;
  final String technology;

  bool get isFull => level >= 100;

  /// Progress in the 0–1 range, for gauges and progress indicators.
  double get fraction => (level / 100).clamp(0.0, 1.0);

  factory BatteryStatus.fromMap(Map<dynamic, dynamic> map) => BatteryStatus(
        level: (map['level'] as num?)?.toInt() ?? 0,
        isCharging: map['isCharging'] as bool? ?? false,
        isPluggedIn: map['isPluggedIn'] as bool? ?? false,
        source: _sourceFrom(map['plugName'] as String?),
        temperatureCelsius: (map['temperature'] as num?)?.toDouble() ?? 0,
        voltageMilliVolts: (map['voltage'] as num?)?.toInt() ?? 0,
        health: _healthFrom(map['health'] as String?),
        technology: map['technology'] as String? ?? '',
      );

  static PowerSource _sourceFrom(String? value) => switch (value) {
        'ac' => PowerSource.ac,
        'usb' => PowerSource.usb,
        'wireless' => PowerSource.wireless,
        'other' => PowerSource.other,
        _ => PowerSource.none,
      };

  static BatteryHealth _healthFrom(String? value) => switch (value) {
        'good' => BatteryHealth.good,
        'overheat' => BatteryHealth.overheat,
        'dead' => BatteryHealth.dead,
        'over_voltage' => BatteryHealth.overVoltage,
        'cold' => BatteryHealth.cold,
        'failure' => BatteryHealth.failure,
        _ => BatteryHealth.unknown,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatteryStatus &&
          other.level == level &&
          other.isCharging == isCharging &&
          other.isPluggedIn == isPluggedIn &&
          other.source == source &&
          other.temperatureCelsius == temperatureCelsius &&
          other.voltageMilliVolts == voltageMilliVolts &&
          other.health == health &&
          other.technology == technology;

  @override
  int get hashCode => Object.hash(
        level,
        isCharging,
        isPluggedIn,
        source,
        temperatureCelsius,
        voltageMilliVolts,
        health,
        technology,
      );
}
