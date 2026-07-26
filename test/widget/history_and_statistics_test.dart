import 'package:battery_full_alarm/features/history/presentation/history_screen.dart';
import 'package:battery_full_alarm/features/statistics/presentation/statistics_screen.dart';
import 'package:battery_full_alarm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_native_bridge.dart';
import '../helpers/test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeNativeBridge bridge;
  final english = AppLocalizations.delegate.load(const Locale('en'));

  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  final today = DateTime.now().subtract(const Duration(hours: 6));

  setUp(() => bridge = FakeNativeBridge());
  tearDown(() => bridge.dispose());

  group('history', () {
    testWidgets('shows an empty state when nothing has been recorded',
        (tester) async {
      await pumpAppWidget(tester, const HistoryScreen(), bridge: bridge);
      final l10n = await english;

      expect(find.text(l10n.historyEmpty), findsOneWidget);
      expect(find.text(l10n.historyEmptyBody), findsOneWidget);
    });

    testWidgets('lists recorded sessions newest first', (tester) async {
      bridge.setHistory([
        sessionMap(
          id: 1,
          startedAt: yesterday,
          endedAt: yesterday.add(const Duration(hours: 4)),
          fullAt: yesterday.add(const Duration(hours: 2)),
          alarmCount: 3,
        ),
        sessionMap(
          id: 2,
          startedAt: today,
          endedAt: today.add(const Duration(hours: 2)),
          fullAt: today.add(const Duration(hours: 1)),
          alarmCount: 1,
        ),
      ]);
      await pumpAppWidget(tester, const HistoryScreen(), bridge: bridge);
      final l10n = await english;

      expect(find.byType(Dismissible), findsNWidgets(2));
      expect(find.text(l10n.historyAlarms(3)), findsOneWidget);
      expect(find.text(l10n.historyAlarms(1)), findsOneWidget);

      // The newer session is rendered above the older one.
      final positions = tester
          .widgetList<Dismissible>(find.byType(Dismissible))
          .map((widget) => (widget.key as ValueKey<int>).value)
          .toList();
      expect(positions, [2, 1]);
    });

    testWidgets('a session still charging is marked in progress', (tester) async {
      bridge.setHistory([sessionMap(id: 3, startedAt: today, peakLevel: 71)]);
      await pumpAppWidget(tester, const HistoryScreen(), bridge: bridge);
      final l10n = await english;

      expect(find.text(l10n.historyInProgress), findsOneWidget);
      expect(find.text(l10n.historyNeverFull), findsOneWidget);
    });

    testWidgets('swiping an entry deletes it', (tester) async {
      bridge.setHistory([
        sessionMap(
          id: 9,
          startedAt: today,
          endedAt: today.add(const Duration(hours: 1)),
        ),
      ]);
      await pumpAppWidget(tester, const HistoryScreen(), bridge: bridge);

      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(bridge.calls, contains('deleteHistoryEntry'));
      expect(await bridge.getHistory(), isEmpty);
    });

    testWidgets('clearing from the app bar empties the log', (tester) async {
      bridge.setHistory([
        sessionMap(
          id: 4,
          startedAt: today,
          endedAt: today.add(const Duration(hours: 1)),
        ),
      ]);
      await pumpAppWidget(tester, const HistoryScreen(), bridge: bridge);
      final l10n = await english;

      await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, l10n.actionDelete));
      await tester.pumpAndSettle();

      expect(find.text(l10n.historyEmpty), findsOneWidget);
    });
  });

  group('statistics', () {
    testWidgets('shows an empty state with no data for the period', (tester) async {
      await pumpAppWidget(tester, const StatisticsScreen(), bridge: bridge);

      expect(find.text((await english).statsNoData), findsOneWidget);
    });

    testWidgets('summarises the sessions in the selected period', (tester) async {
      bridge.setHistory([
        sessionMap(
          id: 1,
          startedAt: today,
          endedAt: today.add(const Duration(hours: 4)),
          fullAt: today.add(const Duration(hours: 2)),
          alarmCount: 3,
        ),
        sessionMap(
          id: 2,
          startedAt: today.subtract(const Duration(hours: 2)),
          endedAt: today.subtract(const Duration(hours: 1)),
          fullAt: today.subtract(const Duration(minutes: 90)),
          alarmCount: 2,
        ),
      ]);
      await pumpAppWidget(tester, const StatisticsScreen(), bridge: bridge);
      final l10n = await english;

      expect(find.text(l10n.statsSessions), findsOneWidget);
      expect(find.text(l10n.statsTotalAlarms), findsOneWidget);
      // Two sessions, five alarms between them.
      expect(find.text('2'), findsWidgets);
      expect(find.text('5'), findsWidgets);
    });

    testWidgets('switching to Today filters older sessions out', (tester) async {
      bridge.setHistory([
        sessionMap(
          id: 1,
          startedAt: DateTime.now().subtract(const Duration(days: 20)),
          endedAt: DateTime.now().subtract(const Duration(days: 20, hours: -2)),
          fullAt: DateTime.now().subtract(const Duration(days: 20, hours: -1)),
        ),
      ]);
      await pumpAppWidget(tester, const StatisticsScreen(), bridge: bridge);
      final l10n = await english;

      await tester.tap(find.text(l10n.statsDaily));
      await tester.pumpAndSettle();

      expect(find.text(l10n.statsNoData), findsOneWidget);
    });
  });
}
