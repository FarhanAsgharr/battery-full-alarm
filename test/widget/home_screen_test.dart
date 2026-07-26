import 'package:battery_full_alarm/features/battery/presentation/home_screen.dart';
import 'package:battery_full_alarm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_native_bridge.dart';
import '../helpers/test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeNativeBridge bridge;
  final english = AppLocalizations.delegate.load(const Locale('en'));

  setUp(() => bridge = FakeNativeBridge());
  tearDown(() => bridge.dispose());

  testWidgets('shows the current battery level and status', (tester) async {
    await pumpAppWidget(tester, const HomeScreen(), bridge: bridge);

    expect(find.text('62%'), findsOneWidget);
    expect(find.textContaining((await english).statusDischarging), findsWidgets);
  });

  testWidgets('the monitoring switch starts the native service', (tester) async {
    await pumpAppWidget(tester, const HomeScreen(), bridge: bridge);
    final l10n = await english;

    expect(find.text(l10n.monitoringOff), findsOneWidget);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(bridge.calls, contains('startMonitoring'));
    expect(find.text(l10n.monitoringOn), findsOneWidget);
  });

  testWidgets('a battery update from the platform is reflected in the UI',
      (tester) async {
    await pumpAppWidget(tester, const HomeScreen(), bridge: bridge);

    bridge.emit(level: 100, isPluggedIn: true);
    await tester.pumpAndSettle();

    expect(find.text('100%'), findsOneWidget);
    expect(find.textContaining((await english).statusFull), findsWidgets);
  });

  testWidgets('the alarm banner appears while ringing and stops the alarm',
      (tester) async {
    await pumpAppWidget(tester, const HomeScreen(), bridge: bridge);
    final l10n = await english;

    bridge.emit(level: 100, isPluggedIn: true, alarming: true);
    await tester.pumpAndSettle();
    expect(find.text(l10n.alarmRinging), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, l10n.actionStopAlarm));
    await tester.pumpAndSettle();

    expect(bridge.alarmStopped, isTrue);
    expect(find.text(l10n.alarmRinging), findsNothing);
  });

  testWidgets('the test alarm button reaches the platform', (tester) async {
    await pumpAppWidget(tester, const HomeScreen(), bridge: bridge);
    final l10n = await english;

    await tester.scrollUntilVisible(
      find.widgetWithText(OutlinedButton, l10n.actionTestAlarm),
      200,
    );
    await tester.tap(find.widgetWithText(OutlinedButton, l10n.actionTestAlarm));
    await tester.pumpAndSettle();

    expect(bridge.testAlarmStarted, isTrue);
  });

  testWidgets('warns when background restrictions would delay alarms', (tester) async {
    bridge = FakeNativeBridge(
      capabilities: const {
        'hasFlash': true,
        'hasVibrator': true,
        'ttsReady': true,
        'ttsLanguageAvailable': true,
        'ignoringBatteryOptimizations': false,
        'canRecord': true,
      },
    );
    await pumpAppWidget(tester, const HomeScreen(), bridge: bridge);
    final l10n = await english;

    expect(find.text(l10n.warnBatteryOptimTitle), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, l10n.actionOpenSettings));
    await tester.pumpAndSettle();

    expect(bridge.calls, contains('openBatteryOptimizationSettings'));
  });

  testWidgets('warns when the chosen language has no installed voice', (tester) async {
    bridge = FakeNativeBridge(
      capabilities: const {
        'hasFlash': true,
        'hasVibrator': true,
        'ttsReady': true,
        'ttsLanguageAvailable': false,
        'ignoringBatteryOptimizations': true,
        'canRecord': true,
      },
    );
    await pumpAppWidget(tester, const HomeScreen(), bridge: bridge);

    expect(find.text((await english).warnTtsTitle), findsOneWidget);
  });

  testWidgets('warns when monitoring is on but the service is dead', (tester) async {
    await pumpAppWidget(tester, const HomeScreen(), bridge: bridge);

    bridge.emit(monitoringEnabled: true, serviceRunning: false);
    await tester.pumpAndSettle();

    expect(find.text((await english).warnServiceStoppedTitle), findsOneWidget);
  });

  testWidgets('renders right-to-left in Urdu without overflowing', (tester) async {
    await pumpAppWidget(
      tester,
      const HomeScreen(),
      bridge: bridge,
      locale: const Locale('ur'),
    );

    final urdu = await AppLocalizations.delegate.load(const Locale('ur'));
    expect(find.text(urdu.appTitle), findsOneWidget);
    expect(Directionality.of(tester.element(find.byType(HomeScreen))), TextDirection.rtl);
    expect(tester.takeException(), isNull);
  });
}
