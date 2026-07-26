import 'package:battery_full_alarm/features/settings/domain/app_settings.dart';
import 'package:battery_full_alarm/features/settings/presentation/settings_screen.dart';
import 'package:battery_full_alarm/features/settings/providers/settings_providers.dart';
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

  /// Scrolls a settings row fully into view before tapping it. `scrollUntilVisible`
  /// alone can leave a row clipped at the bottom edge, where the tap misses.
  Future<void> tapRow(WidgetTester tester, Finder row) async {
    await tester.scrollUntilVisible(row, 300);
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();
  }

  testWidgets('renders every settings section', (tester) async {
    await pumpAppWidget(tester, const SettingsScreen(), bridge: bridge);
    final l10n = await english;

    final expected = {
      l10n.sectionVoice,
      l10n.sectionAlarm,
      l10n.sectionAlerts,
      l10n.sectionStartup,
      l10n.sectionAppearance,
      l10n.sectionData,
      l10n.sectionAbout,
    };

    // Scroll the whole list, collecting headings as they are built. Matching on text
    // rather than scrolling to each one keeps this working for "About", which is both
    // a heading and the row inside it.
    final seen = <String>{};
    for (var attempt = 0; attempt < 15 && seen.length < expected.length; attempt++) {
      seen.addAll(
        expected.where((section) => find.text(section).evaluate().isNotEmpty),
      );
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
    }

    expect(seen, expected);
  });

  testWidgets('editing the name persists it and pushes it to the platform',
      (tester) async {
    final container =
        await pumpAppWidget(tester, const SettingsScreen(), bridge: bridge);
    final l10n = await english;

    await tapRow(tester, find.text(l10n.settingUserName));

    await tester.enterText(find.byType(TextField), 'Muhammad');
    await tester.tap(find.widgetWithText(FilledButton, l10n.actionSave));
    await tester.pumpAndSettle();

    expect(container.read(settingsProvider).userName, 'Muhammad');
    expect(bridge.lastSettings!['userName'], 'Muhammad');
  });

  testWidgets('changing the alarm interval updates settings', (tester) async {
    final container =
        await pumpAppWidget(tester, const SettingsScreen(), bridge: bridge);
    final l10n = await english;

    await tapRow(tester, find.text(l10n.settingAlarmInterval));

    await tester.tap(find.text(l10n.intervalSeconds(30)).last);
    await tester.pumpAndSettle();

    expect(container.read(settingsProvider).alarmIntervalSeconds, 30);
    expect(bridge.lastSettings!['alarmIntervalSeconds'], 30);
  });

  testWidgets('switching the theme updates settings', (tester) async {
    final container =
        await pumpAppWidget(tester, const SettingsScreen(), bridge: bridge);
    final l10n = await english;

    await tapRow(tester, find.text(l10n.settingTheme));

    await tester.tap(find.text(l10n.themeDark).last);
    await tester.pumpAndSettle();

    expect(container.read(settingsProvider).themeChoice, AppThemeChoice.dark);
  });

  testWidgets('switching the language updates settings and the UI', (tester) async {
    final container =
        await pumpAppWidget(tester, const SettingsScreen(), bridge: bridge);
    final l10n = await english;

    await tapRow(tester, find.text(l10n.settingLanguage));

    await tester.tap(find.text(l10n.languageUrdu).last);
    await tester.pumpAndSettle();

    expect(container.read(settingsProvider).language, AppLanguage.urdu);
    expect(bridge.lastSettings!['language'], 'ur');
  });

  testWidgets('toggling vibration and flash reaches the platform', (tester) async {
    final container =
        await pumpAppWidget(tester, const SettingsScreen(), bridge: bridge);
    final l10n = await english;

    await tapRow(tester, find.text(l10n.settingVibration));

    expect(container.read(settingsProvider).vibrationEnabled, isFalse);
    expect(bridge.lastSettings!['vibrationEnabled'], false);
  });

  testWidgets('a device with no flash disables the flash switch', (tester) async {
    bridge = FakeNativeBridge(
      capabilities: const {
        'hasFlash': false,
        'hasVibrator': false,
        'ttsReady': true,
        'ttsLanguageAvailable': true,
        'ignoringBatteryOptimizations': true,
        'canRecord': true,
      },
    );
    await pumpAppWidget(tester, const SettingsScreen(), bridge: bridge);
    final l10n = await english;

    await tester.scrollUntilVisible(find.text(l10n.settingFlash), 300);
    expect(find.text(l10n.settingFlashUnavailable), findsOneWidget);
    expect(find.text(l10n.settingVibrationUnavailable), findsOneWidget);

    final flashSwitch = tester.widget<SwitchListTile>(
      find.ancestor(
        of: find.text(l10n.settingFlash),
        matching: find.byType(SwitchListTile),
      ),
    );
    expect(flashSwitch.onChanged, isNull);
  });

  testWidgets('clearing history from settings empties the native log', (tester) async {
    bridge.setHistory([
      sessionMap(id: 1, startedAt: DateTime(2025, 1, 1, 8)),
    ]);
    await pumpAppWidget(tester, const SettingsScreen(), bridge: bridge);
    final l10n = await english;

    await tapRow(tester, find.text(l10n.actionClearHistory));

    await tester.tap(find.widgetWithText(FilledButton, l10n.actionDelete));
    await tester.pumpAndSettle();

    expect(bridge.calls, contains('clearHistory'));
    expect(await bridge.getHistory(), isEmpty);
  });
}
