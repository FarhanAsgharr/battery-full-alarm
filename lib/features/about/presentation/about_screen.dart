import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/widgets/section_card.dart';
import '../../../l10n/app_localizations.dart';

/// Version, device and a plain statement of what the app does and does not do.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final info = ref.watch(_appInfoProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.battery_charging_full_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.appTitle, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text(
                        info.valueOrNull?.version ?? '',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SectionCard(
            title: l10n.aboutOfflineTitle,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  l10n.aboutOfflineBody,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),

          SectionCard(
            title: l10n.aboutHowItWorksTitle,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  l10n.aboutHowItWorksBody,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),

          SectionCard(
            title: l10n.aboutPermissionsTitle,
            children: const [
              InfoRow(
                icon: Icons.notifications_outlined,
                label: 'POST_NOTIFICATIONS',
                value: 'Ongoing monitor notification',
              ),
              InfoRow(
                icon: Icons.play_circle_outline,
                label: 'FOREGROUND_SERVICE',
                value: 'Battery observation',
              ),
              InfoRow(
                icon: Icons.vibration_rounded,
                label: 'VIBRATE',
                value: 'Alarm vibration',
              ),
              InfoRow(
                icon: Icons.lock_clock_outlined,
                label: 'WAKE_LOCK',
                value: 'Alarm while screen is off',
              ),
              InfoRow(
                icon: Icons.restart_alt_rounded,
                label: 'RECEIVE_BOOT_COMPLETED',
                value: 'Optional — resume after restart',
              ),
              InfoRow(
                icon: Icons.mic_none_rounded,
                label: 'RECORD_AUDIO',
                value: 'Optional — record an alarm clip',
              ),
            ],
          ),

          SectionCard(
            children: [
              InfoRow(
                icon: Icons.tag_rounded,
                label: 'Version',
                value: info.valueOrNull?.version ?? '…',
              ),
              InfoRow(
                icon: Icons.phone_android_rounded,
                label: 'Device',
                value: info.valueOrNull?.device ?? '…',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

@immutable
class _AppInfo {
  const _AppInfo({required this.version, required this.device});

  final String version;
  final String device;
}

/// Version and OS strings, read once. Localised lazily inside the provider is not
/// possible (no context), so the raw values are formatted here and labelled above.
final _appInfoProvider = FutureProvider<_AppInfo>((ref) async {
  final package = await PackageInfo.fromPlatform();
  final android = await DeviceInfoPlugin().androidInfo;
  return _AppInfo(
    version: '${package.version} (${package.buildNumber})',
    device: 'Android ${android.version.release} · API ${android.version.sdkInt}',
  );
});
