import 'package:flutter_riverpod/flutter_riverpod.dart';
// The whole library: `isGranted` and `request()` come from its extensions.
import 'package:permission_handler/permission_handler.dart';

/// Android 13+ requires an explicit grant before the app may post the ongoing
/// notification that keeps the foreground service alive. Without it monitoring still
/// runs, but the user sees nothing — so the home screen surfaces the missing grant.
final notificationPermissionProvider = FutureProvider<bool>(
  (ref) => Permission.notification.isGranted,
);

/// Microphone access, requested only when the user records a custom alarm clip.
final microphonePermissionProvider = FutureProvider<bool>(
  (ref) => Permission.microphone.isGranted,
);

final permissionControllerProvider = Provider<PermissionController>(
  (ref) => PermissionController(ref),
);

class PermissionController {
  PermissionController(this._ref);

  final Ref _ref;

  Future<bool> requestNotifications() async {
    final status = await Permission.notification.request();
    _ref.invalidate(notificationPermissionProvider);
    return status.isGranted;
  }

  Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    _ref.invalidate(microphonePermissionProvider);
    return status.isGranted;
  }

  void refresh() {
    _ref.invalidate(notificationPermissionProvider);
    _ref.invalidate(microphonePermissionProvider);
  }
}
