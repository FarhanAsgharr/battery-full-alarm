import 'package:battery_full_alarm/features/alarm/domain/alarm_sound.dart';
import 'package:battery_full_alarm/features/alarm/presentation/alarm_sound_screen.dart';
import 'package:battery_full_alarm/features/alarm/providers/sound_providers.dart';
import 'package:battery_full_alarm/features/settings/presentation/settings_screen.dart';
import 'package:battery_full_alarm/features/settings/providers/settings_providers.dart';
import 'package:battery_full_alarm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_native_bridge.dart';
import '../helpers/test_harness.dart';

/// Removing alarm sounds.
///
/// The device ringtones cannot be deleted — they belong to the phone, and deleting one
/// would take it from the clock app too — so removing one hides it. These tests pin
/// down that distinction, the fallback when the active alarm is removed, and the fact
/// that hiding survives a restart.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final english = AppLocalizations.delegate.load(const Locale('en'));

  const defaultUri = 'content://settings/system/alarm_alert';
  const oxygenUri = 'content://media/internal/audio/media/12';
  const clipUri = 'file:///files/alarm_sounds/recorded_clip.m4a';

  Map<String, dynamic> soundsWithCustom() => {
        'builtIn': <Map<String, dynamic>>[
          {'type': 'builtin', 'uri': defaultUri, 'label': 'Default alarm'},
          {'type': 'builtin', 'uri': oxygenUri, 'label': 'Oxygen'},
        ],
        'custom': <Map<String, dynamic>>[
          {'type': 'recorded', 'uri': clipUri, 'label': 'clip'},
        ],
      };

  late FakeNativeBridge bridge;

  setUp(() => bridge = FakeNativeBridge(sounds: soundsWithCustom()));
  tearDown(() => bridge.dispose());

  /// Taps the delete icon on the row carrying [label] and confirms the dialog.
  Future<void> deleteRow(WidgetTester tester, String label, String confirmLabel) async {
    final row = find.ancestor(of: find.text(label), matching: find.byType(ListTile));
    await tester.tap(
      find.descendant(of: row, matching: find.byIcon(Icons.delete_outline_rounded)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, confirmLabel));
    await tester.pumpAndSettle();
  }

  group('the delete affordance', () {
    testWidgets('every sound has one, device ringtones included', (tester) async {
      await pumpAppWidget(tester, const AlarmSoundScreen(), bridge: bridge);

      // Two device sounds plus one recorded clip.
      expect(find.byIcon(Icons.delete_outline_rounded), findsNWidgets(3));
    });

    testWidgets('the dialog uses the required title and message', (tester) async {
      await pumpAppWidget(tester, const AlarmSoundScreen(), bridge: bridge);
      final l10n = await english;

      final row = find.ancestor(of: find.text('Oxygen'), matching: find.byType(ListTile));
      await tester.tap(
        find.descendant(of: row, matching: find.byIcon(Icons.delete_outline_rounded)),
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.soundDeleteTitle), findsOneWidget);
      expect(find.text(l10n.soundDeleteMessage), findsOneWidget);
      expect(find.widgetWithText(TextButton, l10n.actionCancel), findsOneWidget);
      expect(find.widgetWithText(FilledButton, l10n.actionDelete), findsOneWidget);
      // A device sound also explains that it is hidden, not deleted.
      expect(find.text(l10n.soundDeleteDeviceNote), findsOneWidget);
    });

    testWidgets('cancelling leaves the sound in place', (tester) async {
      await pumpAppWidget(tester, const AlarmSoundScreen(), bridge: bridge);
      final l10n = await english;

      final row = find.ancestor(of: find.text('Oxygen'), matching: find.byType(ListTile));
      await tester.tap(
        find.descendant(of: row, matching: find.byIcon(Icons.delete_outline_rounded)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, l10n.actionCancel));
      await tester.pumpAndSettle();

      expect(find.text('Oxygen'), findsOneWidget);
      expect(bridge.calls, isNot(contains('removeSound')));
    });
  });

  group('imported and recorded sounds', () {
    testWidgets('are deleted outright and leave the list', (tester) async {
      await pumpAppWidget(tester, const AlarmSoundScreen(), bridge: bridge);
      final l10n = await english;

      await deleteRow(tester, 'clip', l10n.actionDelete);

      expect(find.text('clip'), findsNothing);
      expect(find.text(l10n.soundDeletedFile), findsOneWidget);
      // Not hidden — actually gone.
      expect(bridge.hiddenSounds, isEmpty);
    });
  });

  group('device sounds', () {
    testWidgets('are hidden rather than deleted, and leave the list', (tester) async {
      await pumpAppWidget(tester, const AlarmSoundScreen(), bridge: bridge);
      final l10n = await english;

      await deleteRow(tester, 'Oxygen', l10n.actionDelete);

      expect(find.text('Oxygen'), findsNothing);
      expect(find.text(l10n.soundHiddenFromList), findsOneWidget);
      expect(bridge.hiddenSounds, contains(oxygenUri));
    });

    testWidgets('stay hidden after a restart', (tester) async {
      await pumpAppWidget(tester, const AlarmSoundScreen(), bridge: bridge);
      final l10n = await english;
      await deleteRow(tester, 'Oxygen', l10n.actionDelete);

      // A second bridge over the same hidden set is what a relaunch looks like.
      final restarted = FakeNativeBridge(sounds: soundsWithCustom())
        ..hiddenSounds.addAll(bridge.hiddenSounds);
      addTearDown(restarted.dispose);

      await pumpAppWidget(tester, const AlarmSoundScreen(), bridge: restarted);

      expect(find.text('Oxygen'), findsNothing);
      expect(find.text('Default alarm'), findsOneWidget);
    });
  });

  group('the active alarm', () {
    testWidgets('falls back to the device default when its sound is removed',
        (tester) async {
      final container =
          await pumpAppWidget(tester, const AlarmSoundScreen(), bridge: bridge);
      final l10n = await english;

      // Select Oxygen, then remove it.
      await tester.tap(find.text('Oxygen'));
      await tester.pumpAndSettle();
      expect(container.read(settingsProvider).soundUri, oxygenUri);

      await deleteRow(tester, 'Oxygen', l10n.actionDelete);

      // Empty soundUri means "use the device default alarm tone".
      expect(container.read(settingsProvider).soundUri, isEmpty);
      expect(container.read(settingsProvider).soundLabel, isEmpty);
      expect(find.text(l10n.soundActiveFallback), findsOneWidget);
      // The platform was told, so the service cannot keep pointing at it.
      expect(bridge.lastSettings!['soundUri'], isEmpty);
    });

    testWidgets('is untouched when a different sound is removed', (tester) async {
      final container =
          await pumpAppWidget(tester, const AlarmSoundScreen(), bridge: bridge);
      final l10n = await english;

      await tester.tap(find.text('Oxygen'));
      await tester.pumpAndSettle();

      await deleteRow(tester, 'clip', l10n.actionDelete);

      expect(container.read(settingsProvider).soundUri, oxygenUri);
    });
  });

  group('when everything is gone', () {
    testWidgets('the picker explains the fallback instead of showing nothing',
        (tester) async {
      bridge.hiddenSounds.addAll({defaultUri, oxygenUri});
      await pumpAppWidget(tester, const AlarmSoundScreen(), bridge: bridge);
      final l10n = await english;

      expect(find.text(l10n.soundNoneTitle), findsOneWidget);
      expect(find.text(l10n.soundNoneBody), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a restore button is offered right there', (tester) async {
      bridge.hiddenSounds.addAll({defaultUri, oxygenUri});
      await pumpAppWidget(tester, const AlarmSoundScreen(), bridge: bridge);
      final l10n = await english;

      await tester.tap(
        find.widgetWithText(OutlinedButton, l10n.settingRestoreSounds),
      );
      await tester.pumpAndSettle();

      expect(find.text('Default alarm'), findsOneWidget);
      expect(find.text('Oxygen'), findsOneWidget);
      expect(bridge.hiddenSounds, isEmpty);
    });

    testWidgets('removing every sound in turn never throws', (tester) async {
      await pumpAppWidget(tester, const AlarmSoundScreen(), bridge: bridge);
      final l10n = await english;

      for (final label in ['clip', 'Oxygen', 'Default alarm']) {
        await deleteRow(tester, label, l10n.actionDelete);
        expect(tester.takeException(), isNull, reason: 'after removing $label');
      }

      expect(find.text(l10n.soundNoneTitle), findsOneWidget);
    });
  });

  group('Restore default sounds in Settings', () {
    testWidgets('is disabled while nothing is hidden', (tester) async {
      await pumpAppWidget(tester, const SettingsScreen(), bridge: bridge);
      final l10n = await english;

      await tester.scrollUntilVisible(find.text(l10n.settingRestoreSounds), 200);
      expect(find.text(l10n.settingRestoreSoundsNone), findsOneWidget);

      final tile = tester.widget<ListTile>(
        find.ancestor(
          of: find.text(l10n.settingRestoreSounds),
          matching: find.byType(ListTile),
        ),
      );
      expect(tile.enabled, isFalse);
    });

    testWidgets('reports how many are hidden and restores them on confirm',
        (tester) async {
      bridge.hiddenSounds.addAll({defaultUri, oxygenUri});
      final container =
          await pumpAppWidget(tester, const SettingsScreen(), bridge: bridge);
      final l10n = await english;

      await tester.scrollUntilVisible(find.text(l10n.settingRestoreSounds), 200);
      expect(find.text(l10n.settingRestoreSoundsCount(2)), findsOneWidget);

      await tester.tap(find.text(l10n.settingRestoreSounds));
      await tester.pumpAndSettle();
      expect(find.text(l10n.restoreSoundsConfirm), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, l10n.actionReset));
      await tester.pumpAndSettle();

      expect(bridge.calls, contains('restoreDefaultSounds'));
      expect(bridge.hiddenSounds, isEmpty);
      final library = await container.read(soundLibraryProvider.future);
      expect(library.hiddenCount, 0);
      expect(library.builtIn, hasLength(2));
    });

    testWidgets('cancelling restores nothing', (tester) async {
      bridge.hiddenSounds.add(oxygenUri);
      await pumpAppWidget(tester, const SettingsScreen(), bridge: bridge);
      final l10n = await english;

      await tester.scrollUntilVisible(find.text(l10n.settingRestoreSounds), 200);
      await tester.tap(find.text(l10n.settingRestoreSounds));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, l10n.actionCancel));
      await tester.pumpAndSettle();

      expect(bridge.hiddenSounds, contains(oxygenUri));
      expect(bridge.calls, isNot(contains('restoreDefaultSounds')));
    });
  });

  group('domain model', () {
    test('a removal outcome decodes from the platform string', () {
      expect(AlarmSoundRemoval.fromName('deleted'), AlarmSoundRemoval.deleted);
      expect(AlarmSoundRemoval.fromName('hidden'), AlarmSoundRemoval.hidden);
      expect(AlarmSoundRemoval.fromName('missing'), AlarmSoundRemoval.missing);
      expect(AlarmSoundRemoval.fromName(null), AlarmSoundRemoval.missing);
      expect(AlarmSoundRemoval.fromName('nonsense'), AlarmSoundRemoval.missing);
    });

    test('only device sounds report themselves as such', () {
      const device = AlarmSound(uri: 'a', label: 'a', kind: AlarmSoundKind.builtIn);
      const imported = AlarmSound(uri: 'b', label: 'b', kind: AlarmSoundKind.imported);
      const recorded = AlarmSound(uri: 'c', label: 'c', kind: AlarmSoundKind.recorded);

      expect(device.isDeviceSound, isTrue);
      expect(imported.isDeviceSound, isFalse);
      expect(recorded.isDeviceSound, isFalse);
    });

    test('a library reports emptiness and the hidden count', () {
      final library = AlarmSoundLibrary.fromMap(const {
        'builtIn': <Map<String, dynamic>>[],
        'custom': <Map<String, dynamic>>[],
        'hiddenCount': 4,
      });

      expect(library.isEmpty, isTrue);
      expect(library.hiddenCount, 4);
    });
  });
}
