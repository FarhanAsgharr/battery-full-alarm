import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/notice_banner.dart';
import '../../../l10n/app_localizations.dart';
import '../../notifications/providers/notification_providers.dart';
import '../../settings/providers/settings_providers.dart';
import '../domain/monitor_snapshot.dart';
import '../providers/battery_providers.dart';
import 'widgets/battery_details_card.dart';
import 'widgets/battery_gauge.dart';
import 'widgets/monitoring_card.dart';
import 'widgets/session_card.dart';

/// The screen the user lands on: current battery, the monitoring switch, anything
/// blocking alarms from working, and the live charging session.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Permissions and battery-optimisation status can change while the user is away
    // in system settings; re-read them when we come back rather than showing stale
    // warnings.
    if (state == AppLifecycleState.resumed) {
      ref.read(permissionControllerProvider).refresh();
      ref.read(monitorControllerProvider).refreshCapabilities();
    }
  }

  Future<void> _setMonitoring(bool enabled) async {
    setState(() => _busy = true);
    try {
      await ref.read(monitorControllerProvider).setMonitoring(enabled);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (enabled) unawaited(_ensureNotificationPermission());
  }

  /// The ongoing notification is how Android keeps the service alive, so prompt for it
  /// when monitoring is switched on.
  ///
  /// Deliberately not awaited by [_setMonitoring]: a refusal, a slow system dialog, or
  /// a host without the permission plugin must never stop the service from starting.
  /// If the grant is missing the home screen shows a banner instead.
  Future<void> _ensureNotificationPermission() async {
    try {
      final granted = await ref.read(notificationPermissionProvider.future);
      if (!granted) await ref.read(permissionControllerProvider).requestNotifications();
    } catch (error) {
      debugPrint('Notification permission check unavailable: $error');
    }
  }

  Future<void> _testAlarm() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    // The snackbar is owned by the ScaffoldMessenger and can outlive this screen, so
    // its action must not reach back through `ref`.
    final controller = ref.read(monitorControllerProvider);
    await controller.testAlarm();
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.testAlarmStarted),
        action: SnackBarAction(
          label: l10n.actionStopPreview,
          onPressed: controller.stopTest,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final monitor = ref.watch(monitorProvider);
    final settings = ref.watch(settingsProvider);
    final battery = monitor.battery;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(monitorStreamProvider);
            ref.read(monitorControllerProvider).refreshCapabilities();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Center(
                child: BatteryGauge(
                  level: battery.level,
                  charging: battery.isPluggedIn,
                  color: AppTheme.levelColor(
                    battery.level,
                    charging: battery.isPluggedIn,
                  ),
                  statusLabel: battery.isPluggedIn
                      ? '${Formatters.batteryStatus(l10n, battery)} · '
                          '${Formatters.powerSource(l10n, battery.source)}'
                      : Formatters.batteryStatus(l10n, battery),
                ),
              ),
              const SizedBox(height: 24),

              if (monitor.alarming) ...[
                _AlarmBanner(
                  onStop: () => ref.read(monitorControllerProvider).stopAlarm(),
                ),
                const SizedBox(height: 12),
              ],

              MonitoringCard(
                enabled: monitor.monitoringEnabled,
                busy: _busy,
                onChanged: _setMonitoring,
              ),
              const SizedBox(height: 12),

              ..._notices(context, monitor),

              SessionCard(session: monitor.session, localeCode: settings.language.code),
              const SizedBox(height: 12),

              BatteryDetailsCard(battery: battery),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: _testAlarm,
                icon: const Icon(Icons.volume_up_outlined),
                label: Text(l10n.actionTestAlarm),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Warnings, in the order that matters most if several apply at once.
  List<Widget> _notices(BuildContext context, MonitorSnapshot monitor) {
    final l10n = AppLocalizations.of(context);
    final notifications = ref.watch(notificationPermissionProvider).valueOrNull ?? true;
    final capabilities = ref.watch(capabilitiesProvider).valueOrNull;
    final controller = ref.read(monitorControllerProvider);
    final notices = <Widget>[];

    void add(Widget notice) {
      notices
        ..add(notice)
        ..add(const SizedBox(height: 12));
    }

    if (monitor.isDegraded) {
      add(NoticeBanner(
        icon: Icons.error_outline,
        severity: NoticeSeverity.error,
        title: l10n.warnServiceStoppedTitle,
        body: l10n.warnServiceStoppedBody,
      ));
    }

    if (!notifications) {
      add(NoticeBanner(
        icon: Icons.notifications_off_outlined,
        title: l10n.warnNotificationsTitle,
        body: l10n.warnNotificationsBody,
        actionLabel: l10n.actionAllow,
        onAction: () async {
          final granted =
              await ref.read(permissionControllerProvider).requestNotifications();
          if (!granted) await controller.openNotificationSettings();
        },
      ));
    }

    if (capabilities != null && !capabilities.ignoringBatteryOptimizations) {
      add(NoticeBanner(
        icon: Icons.battery_saver_outlined,
        title: l10n.warnBatteryOptimTitle,
        body: l10n.warnBatteryOptimBody,
        actionLabel: l10n.actionOpenSettings,
        onAction: controller.openBatteryOptimizationSettings,
      ));
    }

    if (capabilities != null && !capabilities.ttsLanguageAvailable) {
      add(NoticeBanner(
        icon: Icons.record_voice_over_outlined,
        title: l10n.warnTtsTitle,
        body: l10n.warnTtsBody,
        actionLabel: l10n.actionTtsSettings,
        onAction: controller.openTtsSettings,
      ));
    }

    return notices;
  }
}

class _AlarmBanner extends StatelessWidget {
  const _AlarmBanner({required this.onStop});

  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
        child: Row(
          children: [
            Icon(Icons.notifications_active, color: scheme.onErrorContainer, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.alarmRinging,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.onErrorContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    l10n.alarmRingingBody,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onErrorContainer),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: onStop,
              child: Text(l10n.actionStopAlarm),
            ),
          ],
        ),
      ),
    );
  }
}
