import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../platform/native_bridge.dart';

/// Overridden in `main()` once the plugin has loaded, so every dependent provider can
/// read settings synchronously instead of threading a `FutureProvider` through the UI.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

/// Overridden in tests with a fake implementation.
final nativeBridgeProvider = Provider<NativeBridge>((ref) => NativeBridge());
