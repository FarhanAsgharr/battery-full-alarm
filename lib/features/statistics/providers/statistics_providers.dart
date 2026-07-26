import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../history/providers/history_providers.dart';
import '../domain/charging_statistics.dart';

/// Which window the statistics screen is showing.
final statsPeriodProvider = StateProvider<StatsPeriod>((ref) => StatsPeriod.weekly);

/// Statistics for the selected period, recomputed whenever the history changes.
final statisticsProvider = Provider<AsyncValue<ChargingStatistics>>((ref) {
  final period = ref.watch(statsPeriodProvider);
  return ref.watch(historyProvider).whenData(
        (sessions) => ChargingStatistics.from(sessions, period, DateTime.now()),
      );
});
