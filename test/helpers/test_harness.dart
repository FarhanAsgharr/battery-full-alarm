import 'package:battery_full_alarm/core/providers/core_providers.dart';
import 'package:battery_full_alarm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fake_native_bridge.dart';

/// Builds a widget inside the same provider and localisation scope the real app uses,
/// with the platform layer replaced by [bridge].
///
/// Returns the [ProviderContainer] so tests can read providers directly.
Future<ProviderContainer> pumpAppWidget(
  WidgetTester tester,
  Widget child, {
  required FakeNativeBridge bridge,
  Map<String, Object> initialPreferences = const {},
  Locale locale = const Locale('en'),
  bool permissionsGranted = true,
}) async {
  mockPermissionHandler(granted: permissionsGranted);
  SharedPreferences.setMockInitialValues(initialPreferences);
  final preferences = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      nativeBridgeProvider.overrideWithValue(bridge),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

/// A provider container with no widget tree, for testing controllers directly.
///
/// Pass `resetStore: false` to build a second container over the *same* preference
/// store — that is how a relaunch is simulated.
Future<ProviderContainer> buildContainer({
  required FakeNativeBridge bridge,
  Map<String, Object> initialPreferences = const {},
  bool resetStore = true,
}) async {
  if (resetStore) SharedPreferences.setMockInitialValues(initialPreferences);
  final preferences = await SharedPreferences.getInstance();
  await preferences.reload();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      nativeBridgeProvider.overrideWithValue(bridge),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Answers `permission_handler`'s platform channel so permission-gated flows can be
/// exercised in a widget test. Without this the plugin has no host and the call hangs.
void mockPermissionHandler({bool granted = true}) {
  const channel = MethodChannel('flutter.baseflow.com/permissions/methods');
  // PermissionStatus index: 0 = denied, 1 = granted.
  final status = granted ? 1 : 0;

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
    switch (call.method) {
      case 'checkPermissionStatus':
        return status;
      case 'requestPermissions':
        final requested = (call.arguments as List).cast<int>();
        return <int, int>{for (final permission in requested) permission: status};
      case 'checkServiceStatus':
        return 1;
      case 'shouldShowRequestPermissionRationale':
        return false;
      case 'openAppSettings':
        return true;
      default:
        return null;
    }
  });
  addTearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );
}

/// A history entry shaped the way the native store emits it.
Map<String, dynamic> sessionMap({
  required int id,
  required DateTime startedAt,
  DateTime? endedAt,
  int startLevel = 40,
  int endLevel = 100,
  int peakLevel = 100,
  DateTime? fullAt,
  int alarmCount = 0,
  String plugType = 'ac',
}) =>
    {
      'id': id,
      'startedAt': startedAt.millisecondsSinceEpoch,
      'endedAt': endedAt?.millisecondsSinceEpoch ?? 0,
      'startLevel': startLevel,
      'endLevel': endLevel,
      'peakLevel': peakLevel,
      'fullAt': fullAt?.millisecondsSinceEpoch ?? 0,
      'alarmCount': alarmCount,
      'plugType': plugType,
    };
