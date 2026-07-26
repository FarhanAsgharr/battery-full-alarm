import 'package:intl/intl.dart';

import '../../features/battery/domain/battery_status.dart';
import '../../l10n/app_localizations.dart';

/// Locale-aware formatting shared by the history, statistics and home screens.
class Formatters {
  const Formatters._();

  /// "2h 15m", "45m" or "30s" depending on magnitude — long charge sessions read
  /// better without seconds, short ones need them.
  static String duration(AppLocalizations l10n, Duration value) {
    final total = value.isNegative ? Duration.zero : value;
    if (total.inHours > 0) {
      return l10n.durationHoursMinutes(total.inHours, total.inMinutes.remainder(60));
    }
    if (total.inMinutes > 0) return l10n.durationMinutes(total.inMinutes);
    return l10n.durationSeconds(total.inSeconds);
  }

  static String time(String localeCode, DateTime value) =>
      DateFormat.jm(localeCode).format(value);

  static String dateTime(String localeCode, DateTime value) =>
      DateFormat.yMMMd(localeCode).add_jm().format(value);

  static String dayLabel(String localeCode, DateTime value) =>
      DateFormat.MMMd(localeCode).format(value);

  static String weekdayShort(String localeCode, DateTime value) =>
      DateFormat.E(localeCode).format(value);

  static String temperature(double celsius) => '${celsius.toStringAsFixed(1)} °C';

  static String voltage(int milliVolts) =>
      '${(milliVolts / 1000).toStringAsFixed(2)} V';

  static String interval(AppLocalizations l10n, int seconds) =>
      seconds == 60 ? l10n.intervalMinute : l10n.intervalSeconds(seconds);

  static String powerSource(AppLocalizations l10n, PowerSource source) => switch (source) {
        PowerSource.ac => l10n.chargerAc,
        PowerSource.usb => l10n.chargerUsb,
        PowerSource.wireless => l10n.chargerWireless,
        PowerSource.other => l10n.chargerOther,
        PowerSource.none => l10n.chargerNone,
      };

  static String health(AppLocalizations l10n, BatteryHealth health) => switch (health) {
        BatteryHealth.good => l10n.healthGood,
        BatteryHealth.overheat => l10n.healthOverheat,
        BatteryHealth.dead => l10n.healthDead,
        BatteryHealth.overVoltage => l10n.healthOverVoltage,
        BatteryHealth.cold => l10n.healthCold,
        BatteryHealth.failure => l10n.healthFailure,
        BatteryHealth.unknown => l10n.healthUnknown,
      };

  static String batteryStatus(AppLocalizations l10n, BatteryStatus battery) {
    if (battery.isPluggedIn && battery.isFull) return l10n.statusFull;
    if (battery.isPluggedIn) return l10n.statusCharging;
    return l10n.statusDischarging;
  }
}
