import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/section_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../battery/providers/battery_providers.dart';
import '../../history/providers/history_providers.dart';
import '../domain/app_settings.dart';
import '../providers/settings_providers.dart';
import 'widgets/choice_tile.dart';
import 'widgets/slider_tile.dart';
import 'widgets/text_field_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final capabilities = ref.watch(capabilitiesProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // ---------------------------------------------------------- voice
          SectionCard(
            title: l10n.sectionVoice,
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(l10n.settingUserName),
                subtitle: Text(
                  settings.userName.isEmpty ? l10n.settingUserNameEmpty : settings.userName,
                ),
                onTap: () async {
                  final name = await showTextFieldDialog(
                    context: context,
                    title: l10n.settingUserName,
                    hint: l10n.settingUserNameHint,
                    initialValue: settings.userName,
                    maxLength: AppConstants.maxUserNameLength,
                  );
                  if (name != null) {
                    await controller.edit((current) => current.copyWith(userName: name));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.record_voice_over_outlined),
                title: Text(l10n.settingVoiceMessage),
                subtitle: Text(
                  settings.voiceMessage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.voice),
              ),
              SwitchListTile.adaptive(
                secondary: const Icon(Icons.campaign_outlined),
                value: settings.voiceEnabled,
                title: Text(l10n.settingVoiceEnabled),
                subtitle: Text(l10n.settingVoiceEnabledBody),
                onChanged: (value) =>
                    controller.edit((current) => current.copyWith(voiceEnabled: value)),
              ),
            ],
          ),

          // ---------------------------------------------------------- alarm
          SectionCard(
            title: l10n.sectionAlarm,
            children: [
              ListTile(
                leading: const Icon(Icons.music_note_outlined),
                title: Text(l10n.settingAlarmSound),
                subtitle: Text(
                  settings.soundLabel.isEmpty
                      ? l10n.settingAlarmSoundDefault
                      : settings.soundLabel,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.sound),
              ),
              SwitchListTile.adaptive(
                secondary: const Icon(Icons.volume_up_outlined),
                value: settings.soundEnabled,
                title: Text(l10n.settingSoundEnabled),
                onChanged: (value) =>
                    controller.edit((current) => current.copyWith(soundEnabled: value)),
              ),
              ChoiceTile<int>(
                icon: Icons.repeat_rounded,
                title: l10n.settingAlarmInterval,
                value: settings.alarmIntervalSeconds,
                options: [
                  for (final seconds in AppConstants.alarmIntervals)
                    ChoiceOption(value: seconds, label: Formatters.interval(l10n, seconds)),
                ],
                onChanged: (value) => controller
                    .edit((current) => current.copyWith(alarmIntervalSeconds: value)),
              ),
              SliderTile(
                icon: Icons.graphic_eq_rounded,
                title: l10n.settingAlarmVolume,
                value: settings.alarmVolumePercent.toDouble(),
                min: AppConstants.minAlarmVolume.toDouble(),
                max: AppConstants.maxAlarmVolume.toDouble(),
                divisions: 18,
                formatValue: (value) => l10n.percentValue(value.round()),
                onCommit: (value) => controller.edit(
                  (current) => current.copyWith(alarmVolumePercent: value.round()),
                ),
              ),
            ],
          ),

          // --------------------------------------------------------- alerts
          SectionCard(
            title: l10n.sectionAlerts,
            children: [
              SwitchListTile.adaptive(
                secondary: const Icon(Icons.vibration_rounded),
                value: settings.vibrationEnabled && (capabilities?.hasVibrator ?? true),
                title: Text(l10n.settingVibration),
                subtitle: capabilities != null && !capabilities.hasVibrator
                    ? Text(l10n.settingVibrationUnavailable)
                    : null,
                onChanged: capabilities != null && !capabilities.hasVibrator
                    ? null
                    : (value) => controller
                        .edit((current) => current.copyWith(vibrationEnabled: value)),
              ),
              SwitchListTile.adaptive(
                secondary: const Icon(Icons.flashlight_on_outlined),
                value: settings.flashEnabled && (capabilities?.hasFlash ?? true),
                title: Text(l10n.settingFlash),
                subtitle: capabilities != null && !capabilities.hasFlash
                    ? Text(l10n.settingFlashUnavailable)
                    : null,
                onChanged: capabilities != null && !capabilities.hasFlash
                    ? null
                    : (value) =>
                        controller.edit((current) => current.copyWith(flashEnabled: value)),
              ),
              SwitchListTile.adaptive(
                secondary: const Icon(Icons.notifications_outlined),
                value: settings.notificationsEnabled,
                title: Text(l10n.settingNotifications),
                subtitle: Text(l10n.settingNotificationsBody),
                onChanged: (value) => controller
                    .edit((current) => current.copyWith(notificationsEnabled: value)),
              ),
            ],
          ),

          // -------------------------------------------------------- startup
          SectionCard(
            title: l10n.sectionStartup,
            children: [
              SwitchListTile.adaptive(
                secondary: const Icon(Icons.play_circle_outline),
                value: settings.autoStartMonitoring,
                title: Text(l10n.settingAutoStart),
                subtitle: Text(l10n.settingAutoStartBody),
                onChanged: (value) => controller
                    .edit((current) => current.copyWith(autoStartMonitoring: value)),
              ),
              SwitchListTile.adaptive(
                secondary: const Icon(Icons.restart_alt_rounded),
                value: settings.autoStartAfterBoot,
                title: Text(l10n.settingAutoStartBoot),
                subtitle: Text(l10n.settingAutoStartBootBody),
                onChanged: (value) => controller
                    .edit((current) => current.copyWith(autoStartAfterBoot: value)),
              ),
              ListTile(
                leading: const Icon(Icons.battery_saver_outlined),
                title: Text(l10n.settingBatteryOptimization),
                subtitle: Text(
                  (capabilities?.ignoringBatteryOptimizations ?? true)
                      ? l10n.settingBatteryOptimizationOk
                      : l10n.settingBatteryOptimizationBad,
                ),
                trailing: const Icon(Icons.open_in_new_rounded, size: 20),
                onTap: () =>
                    ref.read(monitorControllerProvider).openBatteryOptimizationSettings(),
              ),
            ],
          ),

          // ----------------------------------------------------- appearance
          SectionCard(
            title: l10n.sectionAppearance,
            children: [
              ChoiceTile<AppThemeChoice>(
                icon: Icons.palette_outlined,
                title: l10n.settingTheme,
                value: settings.themeChoice,
                options: [
                  ChoiceOption(value: AppThemeChoice.system, label: l10n.themeSystem),
                  ChoiceOption(value: AppThemeChoice.light, label: l10n.themeLight),
                  ChoiceOption(value: AppThemeChoice.dark, label: l10n.themeDark),
                ],
                onChanged: (value) =>
                    controller.edit((current) => current.copyWith(themeChoice: value)),
              ),
              ChoiceTile<AppLanguage>(
                icon: Icons.translate_rounded,
                title: l10n.settingLanguage,
                value: settings.language,
                options: [
                  ChoiceOption(value: AppLanguage.english, label: l10n.languageEnglish),
                  ChoiceOption(value: AppLanguage.urdu, label: l10n.languageUrdu),
                  ChoiceOption(value: AppLanguage.arabic, label: l10n.languageArabic),
                  ChoiceOption(value: AppLanguage.hindi, label: l10n.languageHindi),
                ],
                onChanged: (value) async {
                  await controller.edit((current) => current.copyWith(language: value));
                  ref.read(monitorControllerProvider).refreshCapabilities();
                },
              ),
            ],
          ),

          // ----------------------------------------------------------- data
          SectionCard(
            title: l10n.sectionData,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_sweep_outlined),
                title: Text(l10n.actionClearHistory),
                onTap: () => _confirmClearHistory(context, ref),
              ),
            ],
          ),

          // ---------------------------------------------------------- about
          SectionCard(
            title: l10n.sectionAbout,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.aboutTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.about),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearHistory(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    // Resolved before the dialog: `ref` may no longer be usable by the time it closes
    // if the user navigates away while it is open.
    final history = ref.read(historyControllerProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.actionClearHistory),
        content: Text(l10n.historyClearConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await history.clear();
    messenger.showSnackBar(SnackBar(content: Text(l10n.historyCleared)));
  }
}
