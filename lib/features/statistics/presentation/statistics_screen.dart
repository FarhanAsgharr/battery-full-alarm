import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/providers/settings_providers.dart';
import '../domain/charging_statistics.dart';
import '../providers/statistics_providers.dart';
import 'widgets/sessions_bar_chart.dart';

/// Daily / weekly / monthly summary of the local charging log.
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final period = ref.watch(statsPeriodProvider);
    final stats = ref.watch(statisticsProvider);
    final localeCode = ref.watch(settingsProvider.select((value) => value.language.code));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SegmentedButton<StatsPeriod>(
              segments: [
                ButtonSegment(value: StatsPeriod.daily, label: Text(l10n.statsDaily)),
                ButtonSegment(value: StatsPeriod.weekly, label: Text(l10n.statsWeekly)),
                ButtonSegment(value: StatsPeriod.monthly, label: Text(l10n.statsMonthly)),
              ],
              selected: {period},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  ref.read(statsPeriodProvider.notifier).state = selection.first,
            ),
          ),
          Expanded(
            child: stats.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('$error')),
              data: (data) => data.isEmpty
                  ? _Empty(message: l10n.statsNoData)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      children: [
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.45,
                          children: [
                            _StatTile(
                              icon: Icons.power_rounded,
                              label: l10n.statsSessions,
                              value: '${data.sessionCount}',
                            ),
                            _StatTile(
                              icon: Icons.check_circle_outline,
                              label: l10n.statsFullCharges,
                              value: '${data.fullChargeCount}',
                            ),
                            _StatTile(
                              icon: Icons.timer_outlined,
                              label: l10n.statsAvgChargeTime,
                              value: data.averageTimeToFull == null
                                  ? l10n.valueUnavailable
                                  : Formatters.duration(l10n, data.averageTimeToFull!),
                            ),
                            _StatTile(
                              icon: Icons.timelapse_rounded,
                              label: l10n.statsAvgPluggedTime,
                              value: data.averagePluggedTime == null
                                  ? l10n.valueUnavailable
                                  : Formatters.duration(l10n, data.averagePluggedTime!),
                            ),
                            _StatTile(
                              icon: Icons.notifications_active_outlined,
                              label: l10n.statsTotalAlarms,
                              value: '${data.totalAlarms}',
                            ),
                            _StatTile(
                              icon: Icons.battery_std_rounded,
                              label: l10n.statsAvgStartLevel,
                              value: data.averageStartLevel == null
                                  ? l10n.valueUnavailable
                                  : l10n.percentValue(data.averageStartLevel!),
                            ),
                            _StatTile(
                              icon: Icons.trending_up_rounded,
                              label: l10n.statsEnergyGained,
                              value: data.averageLevelGained == null
                                  ? l10n.valueUnavailable
                                  : l10n.percentValue(data.averageLevelGained!),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.statsChartTitle,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        SessionsBarChart(
                          data: data.sessionsPerDay,
                          localeCode: localeCode,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        // The grid gives each tile a fixed aspect ratio, so its three lines cannot
        // grow without bound; clamp rather than overflow at large system font sizes.
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 22, color: theme.colorScheme.primary),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insights_rounded,
                size: 56, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
