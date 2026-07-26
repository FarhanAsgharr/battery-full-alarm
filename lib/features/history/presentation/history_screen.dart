import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/providers/settings_providers.dart';
import '../domain/charge_session.dart';
import '../providers/history_providers.dart';

/// The local charging log. Swipe an entry to remove it; nothing here ever syncs.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  /// Ids swiped away but not yet gone from the native log.
  ///
  /// Deletion is asynchronous, and a `Dismissible` must leave the tree in the same
  /// frame it is dismissed — so the row is hidden here first and the store catches up.
  final _removing = <int>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final history = ref.watch(historyProvider);
    final localeCode = ref.watch(settingsProvider.select((value) => value.language.code));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyTitle),
        actions: [
          if (history.valueOrNull?.isNotEmpty ?? false)
            IconButton(
              tooltip: l10n.actionClearHistory,
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _confirmClear,
            ),
        ],
      ),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _Message(title: '$error'),
        data: (sessions) {
          final visible = sessions
              .where((session) => !_removing.contains(session.id))
              .toList(growable: false);
          if (visible.isEmpty) {
            return _Message(title: l10n.historyEmpty, body: l10n.historyEmptyBody);
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(historyControllerProvider).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: visible.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final session = visible[index];
                return Dismissible(
                  key: ValueKey(session.id),
                  direction: DismissDirection.endToStart,
                  background: _DismissBackground(label: l10n.actionDelete),
                  onDismissed: (_) => _delete(session.id),
                  child: _SessionTile(session: session, localeCode: localeCode),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _delete(int id) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _removing.add(id));
    await ref.read(historyControllerProvider).delete(id);
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(l10n.historyEntryDeleted)));
  }

  Future<void> _confirmClear() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.actionClearHistory),
        content: Text(l10n.historyClearConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(historyControllerProvider).clear();
    messenger.showSnackBar(SnackBar(content: Text(l10n.historyCleared)));
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session, required this.localeCode});

  final ChargeSession session;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    Formatters.dateTime(localeCode, session.startedAt),
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (session.isActive)
                  _Pill(label: l10n.historyInProgress, color: scheme.primaryContainer)
                else if (session.reachedFull)
                  _Pill(label: l10n.statusFull, color: scheme.secondaryContainer),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.battery_charging_full_rounded, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Text(l10n.sessionGained(session.startLevel, session.peakLevel)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.timelapse_rounded, size: 18, color: scheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.historyPluggedFor(
                      Formatters.duration(l10n, session.pluggedDuration()),
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  session.reachedFull ? Icons.check_circle_outline : Icons.remove_circle_outline,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    session.timeToFull != null
                        ? l10n.historyReachedFull(
                            Formatters.duration(l10n, session.timeToFull!),
                          )
                        : l10n.historyNeverFull,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.notifications_active_outlined,
                    size: 18, color: scheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(l10n.historyAlarms(session.alarmCount)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: theme.textTheme.labelSmall),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: scheme.onErrorContainer)),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.title, this.body});

  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_toggle_off_rounded,
                size: 56, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
            if (body != null) ...[
              const SizedBox(height: 6),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
