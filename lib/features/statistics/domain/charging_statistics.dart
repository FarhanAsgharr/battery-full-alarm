import 'package:flutter/foundation.dart';

import '../../history/domain/charge_session.dart';

/// The window a statistics page summarises.
enum StatsPeriod { daily, weekly, monthly }

/// Aggregated view of a set of charging sessions.
///
/// Pure data + pure computation: [ChargingStatistics.from] is the only place these
/// numbers are derived, which is what makes them straightforward to unit-test.
@immutable
class ChargingStatistics {
  const ChargingStatistics({
    required this.period,
    required this.sessionCount,
    required this.fullChargeCount,
    required this.totalAlarms,
    required this.averageTimeToFull,
    required this.averagePluggedTime,
    required this.averageStartLevel,
    required this.averageLevelGained,
    required this.sessionsPerDay,
  });

  final StatsPeriod period;
  final int sessionCount;

  /// Sessions that actually reached 100%.
  final int fullChargeCount;
  final int totalAlarms;

  /// Averaged over [fullChargeCount] sessions only; null when none reached full.
  final Duration? averageTimeToFull;

  /// Averaged over completed sessions; null when none have finished.
  final Duration? averagePluggedTime;
  final int? averageStartLevel;
  final int? averageLevelGained;

  /// Session count keyed by calendar day, oldest first — drives the bar chart.
  final Map<DateTime, int> sessionsPerDay;

  bool get isEmpty => sessionCount == 0;

  /// Inclusive start of [period] relative to [now].
  static DateTime startOf(StatsPeriod period, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return switch (period) {
      StatsPeriod.daily => today,
      // Week starts on Monday; `weekday` is 1 (Mon) … 7 (Sun).
      StatsPeriod.weekly => today.subtract(Duration(days: today.weekday - 1)),
      StatsPeriod.monthly => DateTime(now.year, now.month),
    };
  }

  static List<ChargeSession> filter(
    List<ChargeSession> sessions,
    StatsPeriod period,
    DateTime now,
  ) {
    final from = startOf(period, now);
    return sessions
        .where((session) => !session.startedAt.isBefore(from))
        .toList(growable: false);
  }

  factory ChargingStatistics.from(
    List<ChargeSession> sessions,
    StatsPeriod period,
    DateTime now,
  ) {
    final windowed = filter(sessions, period, now);

    if (windowed.isEmpty) {
      return ChargingStatistics(
        period: period,
        sessionCount: 0,
        fullChargeCount: 0,
        totalAlarms: 0,
        averageTimeToFull: null,
        averagePluggedTime: null,
        averageStartLevel: null,
        averageLevelGained: null,
        sessionsPerDay: const {},
      );
    }

    final full = windowed.where((session) => session.reachedFull).toList(growable: false);
    final completed = windowed.where((session) => !session.isActive).toList(growable: false);

    Duration? averageOf(Iterable<Duration> values) {
      final list = values.toList(growable: false);
      if (list.isEmpty) return null;
      final micros = list.fold<int>(0, (sum, value) => sum + value.inMicroseconds);
      return Duration(microseconds: micros ~/ list.length);
    }

    int? averageInt(Iterable<int> values) {
      final list = values.toList(growable: false);
      if (list.isEmpty) return null;
      return (list.reduce((a, b) => a + b) / list.length).round();
    }

    final perDay = <DateTime, int>{};
    for (final session in windowed) {
      final day = DateTime(
        session.startedAt.year,
        session.startedAt.month,
        session.startedAt.day,
      );
      perDay[day] = (perDay[day] ?? 0) + 1;
    }
    final orderedDays = perDay.keys.toList()..sort();

    return ChargingStatistics(
      period: period,
      sessionCount: windowed.length,
      fullChargeCount: full.length,
      totalAlarms: windowed.fold<int>(0, (sum, session) => sum + session.alarmCount),
      averageTimeToFull: averageOf(full.map((session) => session.timeToFull!)),
      averagePluggedTime: averageOf(completed.map((session) => session.pluggedDuration())),
      averageStartLevel: averageInt(windowed.map((session) => session.startLevel)),
      averageLevelGained: averageInt(windowed.map((session) => session.levelGained)),
      sessionsPerDay: {for (final day in orderedDays) day: perDay[day]!},
    );
  }
}
