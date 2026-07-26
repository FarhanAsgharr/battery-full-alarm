import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// The master on/off switch for background monitoring.
class MonitoringCard extends StatelessWidget {
  const MonitoringCard({
    super.key,
    required this.enabled,
    required this.onChanged,
    this.busy = false,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      color: enabled ? scheme.primaryContainer : scheme.surfaceContainerLow,
      child: SwitchListTile.adaptive(
        value: enabled,
        onChanged: busy ? null : onChanged,
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
        secondary: Icon(
          enabled ? Icons.shield_rounded : Icons.shield_outlined,
          color: enabled ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
          size: 28,
        ),
        title: Text(
          enabled ? l10n.monitoringOn : l10n.monitoringOff,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: enabled ? scheme.onPrimaryContainer : scheme.onSurface,
          ),
        ),
        subtitle: Text(
          enabled ? l10n.monitoringOnBody : l10n.monitoringOffBody,
          style: theme.textTheme.bodySmall?.copyWith(
            color: enabled ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
