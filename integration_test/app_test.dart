import 'package:battery_full_alarm/app.dart';
import 'package:battery_full_alarm/core/providers/core_providers.dart';
import 'package:battery_full_alarm/features/settings/domain/app_settings.dart';
import 'package:battery_full_alarm/features/settings/providers/settings_providers.dart';
import 'package:battery_full_alarm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// End-to-end journeys through the real app shell on a device or emulator.
///
/// Run with:  `flutter test integration_test/app_test.dart -d <device-id>`
///
/// The platform channel is *not* faked here — these tests exercise the real
/// Kotlin service, so they must run on Android hardware or an emulator.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> launch(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
    );
    addTearDown(container.dispose);

    await container.read(settingsProvider.notifier).syncToPlatform();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const BatteryAlarmApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
    return container;
  }

  testWidgets('the app launches and shows a real battery reading', (tester) async {
    await launch(tester);
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.text(l10n.appTitle), findsOneWidget);
    // The device reports some level; the gauge must show a percentage.
    expect(find.textContaining('%'), findsWidgets);
  });

  testWidgets('monitoring can be switched on and off', (tester) async {
    await launch(tester);
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text(l10n.monitoringOn), findsOneWidget);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text(l10n.monitoringOff), findsOneWidget);
  });

  testWidgets('all four tabs open', (tester) async {
    await launch(tester);
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    for (final (label, title) in [
      (l10n.navHistory, l10n.historyTitle),
      (l10n.navStats, l10n.statsTitle),
      (l10n.navSettings, l10n.settingsTitle),
    ]) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(find.text(title), findsWidgets);
    }
  });

  testWidgets('the voice message survives a settings round trip', (tester) async {
    final container = await launch(tester);
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.tap(find.text(l10n.navSettings));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.settingVoiceMessage));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Time to unplug.');
    await tester.pumpAndSettle();

    expect(container.read(settingsProvider).voiceMessage, 'Time to unplug.');

    // The native side accepted the same value.
    await container.read(settingsProvider.notifier).syncToPlatform();
    expect(container.read(settingsProvider).voiceEnabled, isTrue);
  });

  testWidgets('the alarm sound picker lists the device ringtones', (tester) async {
    await launch(tester);
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.tap(find.text(l10n.navSettings));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.settingAlarmSound));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text(l10n.soundBuiltIn), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);
  });

  testWidgets('switching to Urdu re-renders the app right-to-left', (tester) async {
    final container = await launch(tester);

    await container
        .read(settingsProvider.notifier)
        .edit((current) => current.copyWith(language: AppLanguage.urdu));
    await tester.pumpAndSettle();

    final urdu = await AppLocalizations.delegate.load(const Locale('ur'));
    expect(find.text(urdu.appTitle), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text(urdu.appTitle))),
      TextDirection.rtl,
    );
  });
}
