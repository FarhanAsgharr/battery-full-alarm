import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/battery_status.dart';

/// Read-only battery facts reported by the platform.
class BatteryDetailsCard extends StatelessWidget {
  const BatteryDetailsCard({super.key, required this.battery});

  final BatteryStatus battery;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                l10n.detailsTitle,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            InfoRow(
              icon: Icons.power_outlined,
              label: l10n.detailCharger,
              value: Formatters.powerSource(l10n, battery.source),
            ),
            InfoRow(
              icon: Icons.thermostat_outlined,
              label: l10n.detailTemperature,
              value: battery.temperatureCelsius > 0
                  ? Formatters.temperature(battery.temperatureCelsius)
                  : l10n.valueUnavailable,
            ),
            InfoRow(
              icon: Icons.electric_bolt_outlined,
              label: l10n.detailVoltage,
              value: battery.voltageMilliVolts > 0
                  ? Formatters.voltage(battery.voltageMilliVolts)
                  : l10n.valueUnavailable,
            ),
            InfoRow(
              icon: Icons.favorite_outline,
              label: l10n.detailHealth,
              value: Formatters.health(l10n, battery.health),
            ),
            if (battery.technology.isNotEmpty)
              InfoRow(
                icon: Icons.science_outlined,
                label: l10n.detailTechnology,
                value: battery.technology,
              ),
          ],
        ),
      ),
    );
  }
}
