import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../battery/providers/battery_providers.dart';
import '../data/history_repository.dart';
import '../domain/charge_session.dart';

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepository(ref.watch(nativeBridgeProvider)),
);

/// Charging sessions, newest first.
///
/// Depends on [monitorProvider] so the list refreshes by itself whenever the service
/// reports a change — plugging in, hitting 100%, or unplugging all rewrite the log.
final historyProvider = FutureProvider<List<ChargeSession>>((ref) {
  // Re-read on the events that rewrite the native log: a new session starts, an alarm
  // is counted, or the charger comes out. Ignoring level changes keeps this from
  // re-reading storage on every battery broadcast.
  ref.watch(
    monitorProvider.select(
      (value) => (value.session?.id, value.session?.alarmCount, value.battery.isPluggedIn),
    ),
  );
  return ref.watch(historyRepositoryProvider).load();
});

final historyControllerProvider = Provider<HistoryController>(
  (ref) => HistoryController(ref),
);

class HistoryController {
  HistoryController(this._ref);

  final Ref _ref;

  Future<void> delete(int id) async {
    await _ref.read(historyRepositoryProvider).delete(id);
    _ref.invalidate(historyProvider);
  }

  Future<void> clear() async {
    await _ref.read(historyRepositoryProvider).clear();
    _ref.invalidate(historyProvider);
  }

  Future<void> refresh() async => _ref.invalidate(historyProvider);
}
