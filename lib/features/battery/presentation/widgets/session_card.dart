import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../history/domain/charge_session.dart';

/// Live summary of the charging session in progress.
class SessionCard extends StatelessWidget {
  const SessionCard({super.key, required this.session, required this.localeCode});

  final ChargeSession? session;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final current = session;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.power_rounded, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  l10n.sessionTitle,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (current == null)
              Text(
                l10n.sessionNone,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              )
            else ...[
              _Line(
                icon: Icons.schedule_rounded,
                text: l10n.sessionStarted(
                  Formatters.time(localeCode, current.startedAt),
                ),
              ),
              const SizedBox(height: 8),
              _Line(
                icon: Icons.trending_up_rounded,
                text: l10n.sessionGained(current.startLevel, current.peakLevel),
              ),
              const SizedBox(height: 8),
              _Line(
                icon: Icons.timelapse_rounded,
                text: l10n.historyPluggedFor(
                  Formatters.duration(l10n, current.pluggedDuration()),
                ),
              ),
              const SizedBox(height: 8),
              _Line(
                icon: Icons.notifications_active_outlined,
                text: l10n.sessionAlarms(current.alarmCount),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}
