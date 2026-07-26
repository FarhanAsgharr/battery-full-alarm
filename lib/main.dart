import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers/core_providers.dart';
import 'features/settings/providers/settings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Loaded up front so the whole settings tree can be read synchronously and the
  // first frame already shows the user's theme and language.
  final preferences = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
  );

  // Push the stored settings to the native service. On a first run, or after the
  // process was recreated, this is what gives the foreground service the user's
  // message, interval and toggles before the next charge starts.
  await container.read(settingsProvider.notifier).syncToPlatform();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const BatteryAlarmApp(),
    ),
  );
}
