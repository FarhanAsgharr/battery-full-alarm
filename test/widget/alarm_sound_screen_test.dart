import 'package:battery_full_alarm/features/alarm/presentation/alarm_sound_screen.dart';
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

  testWidgets('lists the sounds available on the device', (tester) async {
    await pumpAppWidget(tester, const AlarmSoundScreen(), bridge: bridge);
    final l10n = await english;

    expect(find.text(l10n.soundBuiltIn), findsOneWidget);
    expect(find.text('Default alarm'), findsOneWidget);
    expect(find.text('Oxygen'), findsOneWidget);
    expect(find.text(l10n.soundCustomEmpty), findsOneWidget);
  });

  testWidgets('choosing a sound stores it and plays a preview', (tester) async {
    final container =
        await pumpAppWidget(tester, const AlarmSoundScreen(), bridge: bridge);

    await tester.tap(find.text('Oxygen'));
    await tester.pumpAndSettle();

    final settings = container.read(settingsProvider);
    expect(settings.soundLabel, 'Oxygen');
    expect(settings.soundUri, 'content://media/internal/audio/media/12');
    expect(bridge.previewedUri, settings.soundUri);
    expect(bridge.previewedVolume, settings.alarmVolumePercent);
    expect(bridge.lastSettings!['soundUri'], settings.soundUri);
  });

  testWidgets('importing an audio file selects the imported sound', (tester) async {
    bridge.nextImportResult = {
      'type': 'imported',
      'uri': 'file:///data/user/0/app/files/alarm_sounds/imported_song.mp3',
      'label': 'song',
      'deletable': true,
    };
    final container =
        await pumpAppWidget(tester, const AlarmSoundScreen(), bridge: bridge);
    final l10n = await english;

    await tester.tap(find.widgetWithText(OutlinedButton, l10n.actionImportAudio));
    await tester.pumpAndSettle();

    expect(bridge.calls, contains('pickAudioFile'));
    expect(container.read(settingsProvider).soundLabel, 'song');
  });

  testWidgets('a cancelled import leaves the selection alone', (tester) async {
    bridge.nextImportResult = null;
    final container =
        await pumpAppWidget(tester, const AlarmSoundScreen(), bridge: bridge);
    final l10n = await english;

    await tester.tap(find.widgetWithText(OutlinedButton, l10n.actionImportAudio));
    await tester.pumpAndSettle();

    expect(find.text(l10n.importCancelled), findsOneWidget);
    expect(container.read(settingsProvider).soundUri, isEmpty);
  });

  testWidgets('a custom sound can be deleted', (tester) async {
    bridge = FakeNativeBridge(
      sounds: {
        'builtIn': <Map<String, dynamic>>[
          {
            'type': 'builtin',
            'uri': 'content://settings/system/alarm_alert',
            'label': 'Default alarm',
            'deletable': false,
          },
        ],
        'custom': <Map<String, dynamic>>[
          {
            'type': 'recorded',
            'uri': 'file:///files/alarm_sounds/recorded_clip.m4a',
            'label': 'clip',
            'deletable': true,
          },
        ],
      },
    );
    await pumpAppWidget(tester, const AlarmSoundScreen(), bridge: bridge);
    final l10n = await english;

    expect(find.text('clip'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, l10n.actionDelete));
    await tester.pumpAndSettle();

    expect(bridge.calls, contains('deleteSound'));
    expect(find.text('clip'), findsNothing);
  });

  testWidgets('recording shows progress and selects the saved clip', (tester) async {
    bridge.nextRecordingResult = {
      'type': 'recorded',
      'uri': 'file:///files/alarm_sounds/recorded_20250115.m4a',
      'label': '20250115',
      'deletable': true,
    };
    final container =
        await pumpAppWidget(tester, const AlarmSoundScreen(), bridge: bridge);
    final l10n = await english;

    await tester.tap(find.widgetWithText(FilledButton, l10n.actionRecordVoice));
    await tester.pumpAndSettle();

    expect(find.text(l10n.recordingInProgress), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, l10n.actionStopRecording));
    await tester.pumpAndSettle();

    expect(bridge.calls, contains('stopRecording'));
    expect(container.read(settingsProvider).soundLabel, '20250115');
  });
}
