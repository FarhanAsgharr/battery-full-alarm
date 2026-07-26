import 'package:battery_full_alarm/features/history/domain/charge_session.dart';
import 'package:battery_full_alarm/features/statistics/domain/charging_statistics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A fixed "now" keeps period boundaries deterministic: Wednesday 15 January 2025.
  final now = DateTime(2025, 1, 15, 20, 0);

  ChargeSession session({
    required DateTime startedAt,
    Duration plugged = const Duration(hours: 3),
    Duration? toFull = const Duration(hours: 2),
    int startLevel = 40,
    int peakLevel = 100,
    int alarms = 2,
    bool active = false,
  }) {
    return ChargeSession(
      id: startedAt.millisecondsSinceEpoch,
      startedAt: startedAt,
      endedAt: active ? null : startedAt.add(plugged),
      startLevel: startLevel,
      endLevel: peakLevel,
      peakLevel: peakLevel,
      fullAt: toFull == null ? null : startedAt.add(toFull),
      alarmCount: alarms,
    );
  }

  group('period windows', () {
    test('daily starts at midnight today', () {
      expect(
        ChargingStatistics.startOf(StatsPeriod.daily, now),
        DateTime(2025, 1, 15),
      );
    });

    test('weekly starts on Monday', () {
      // 15 Jan 2025 is a Wednesday, so the week began on the 13th.
      expect(
        ChargingStatistics.startOf(StatsPeriod.weekly, now),
        DateTime(2025, 1, 13),
      );
    });

    test('monthly starts on the first of the month', () {
      expect(
        ChargingStatistics.startOf(StatsPeriod.monthly, now),
        DateTime(2025, 1),
      );
    });

    test('sessions before the window are excluded', () {
      final sessions = [
        session(startedAt: DateTime(2025, 1, 15, 8)),
        session(startedAt: DateTime(2025, 1, 14, 8)),
        session(startedAt: DateTime(2024, 12, 30, 8)),
      ];

      expect(ChargingStatistics.filter(sessions, StatsPeriod.daily, now).length, 1);
      expect(ChargingStatistics.filter(sessions, StatsPeriod.weekly, now).length, 2);
      expect(ChargingStatistics.filter(sessions, StatsPeriod.monthly, now).length, 2);
    });
  });

  group('aggregation', () {
    test('an empty log produces empty statistics rather than throwing', () {
      final stats = ChargingStatistics.from(const [], StatsPeriod.weekly, now);

      expect(stats.isEmpty, isTrue);
      expect(stats.sessionCount, 0);
      expect(stats.averageTimeToFull, isNull);
      expect(stats.averagePluggedTime, isNull);
      expect(stats.sessionsPerDay, isEmpty);
    });

    test('counts sessions, full charges and alarms', () {
      final stats = ChargingStatistics.from(
        [
          session(startedAt: DateTime(2025, 1, 15, 8), alarms: 3),
          session(startedAt: DateTime(2025, 1, 14, 8), alarms: 1),
          session(startedAt: DateTime(2025, 1, 13, 8), toFull: null, alarms: 0),
        ],
        StatsPeriod.weekly,
        now,
      );

      expect(stats.sessionCount, 3);
      expect(stats.fullChargeCount, 2);
      expect(stats.totalAlarms, 4);
    });

    test('average time to full only counts sessions that reached 100%', () {
      final stats = ChargingStatistics.from(
        [
          session(startedAt: DateTime(2025, 1, 15, 8), toFull: const Duration(hours: 1)),
          session(startedAt: DateTime(2025, 1, 14, 8), toFull: const Duration(hours: 3)),
          // Never reached full — must not drag the average down.
          session(startedAt: DateTime(2025, 1, 13, 8), toFull: null),
        ],
        StatsPeriod.weekly,
        now,
      );

      expect(stats.averageTimeToFull, const Duration(hours: 2));
    });

    test('average plugged time ignores a session still in progress', () {
      final stats = ChargingStatistics.from(
        [
          session(startedAt: DateTime(2025, 1, 15, 8), plugged: const Duration(hours: 4)),
          session(startedAt: DateTime(2025, 1, 14, 8), plugged: const Duration(hours: 2)),
          session(startedAt: DateTime(2025, 1, 15, 19), active: true),
        ],
        StatsPeriod.weekly,
        now,
      );

      expect(stats.averagePluggedTime, const Duration(hours: 3));
    });

    test('averages the level plugged in at and the charge gained', () {
      final stats = ChargingStatistics.from(
        [
          session(startedAt: DateTime(2025, 1, 15, 8), startLevel: 20, peakLevel: 100),
          session(startedAt: DateTime(2025, 1, 14, 8), startLevel: 60, peakLevel: 100),
        ],
        StatsPeriod.weekly,
        now,
      );

      expect(stats.averageStartLevel, 40);
      expect(stats.averageLevelGained, 60);
    });

    test('groups sessions by calendar day, oldest first', () {
      final stats = ChargingStatistics.from(
        [
          session(startedAt: DateTime(2025, 1, 15, 8)),
          session(startedAt: DateTime(2025, 1, 15, 20)),
          session(startedAt: DateTime(2025, 1, 13, 9)),
        ],
        StatsPeriod.weekly,
        now,
      );

      expect(stats.sessionsPerDay.keys.toList(), [
        DateTime(2025, 1, 13),
        DateTime(2025, 1, 15),
      ]);
      expect(stats.sessionsPerDay[DateTime(2025, 1, 15)], 2);
    });
  });

  group('ChargeSession', () {
    test('derives durations and level gain', () {
      final start = DateTime(2025, 1, 15, 1);
      final entry = ChargeSession(
        id: 1,
        startedAt: start,
        endedAt: start.add(const Duration(hours: 5)),
        startLevel: 30,
        peakLevel: 100,
        endLevel: 100,
        fullAt: start.add(const Duration(hours: 2, minutes: 30)),
      );

      expect(entry.isActive, isFalse);
      expect(entry.reachedFull, isTrue);
      expect(entry.pluggedDuration(), const Duration(hours: 5));
      expect(entry.timeToFull, const Duration(hours: 2, minutes: 30));
      expect(entry.levelGained, 70);
    });

    test('an active session measures against the supplied now', () {
      final start = DateTime(2025, 1, 15, 18);
      final entry = ChargeSession(id: 1, startedAt: start, startLevel: 50, peakLevel: 70);

      expect(entry.isActive, isTrue);
      expect(entry.reachedFull, isFalse);
      expect(entry.timeToFull, isNull);
      expect(entry.pluggedDuration(now), const Duration(hours: 2));
    });

    test('parses the map shape the native store emits', () {
      final start = DateTime(2025, 1, 15, 1);
      final entry = ChargeSession.fromMap({
        'id': 7,
        'startedAt': start.millisecondsSinceEpoch,
        'endedAt': 0,
        'startLevel': 12,
        'endLevel': 88,
        'peakLevel': 88,
        'fullAt': 0,
        'alarmCount': 4,
        'plugType': 'usb',
      });

      expect(entry.id, 7);
      expect(entry.startedAt, start);
      expect(entry.endedAt, isNull);
      expect(entry.fullAt, isNull);
      expect(entry.alarmCount, 4);
      expect(entry.plugType, 'usb');
    });
  });
}
