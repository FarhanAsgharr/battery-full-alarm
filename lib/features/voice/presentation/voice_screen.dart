import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../alarm/providers/sound_providers.dart';
import '../../battery/providers/battery_providers.dart';
import '../../settings/presentation/widgets/slider_tile.dart';
import '../../settings/providers/settings_providers.dart';
import '../domain/message_template.dart';

/// Editor for the spoken announcement: the sentence itself, the tags it can contain,
/// and the speed and pitch it is read at.
class VoiceScreen extends ConsumerStatefulWidget {
  const VoiceScreen({super.key});

  @override
  ConsumerState<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends ConsumerState<VoiceScreen> {
  late final TextEditingController _controller;

  /// Captured up front so a pending edit can still be flushed from [dispose], where
  /// `ref` is no longer usable.
  late final SettingsController _settings;
  Timer? _debounce;

  /// Long enough to coalesce typing, short enough that leaving the screen
  /// immediately after a keystroke still saves (the pending write is flushed in
  /// [dispose] as well).
  static const _debounceDelay = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _settings = ref.read(settingsProvider.notifier);
    _controller = TextEditingController(text: ref.read(settingsProvider).voiceMessage);
    // Keeps the live preview and the empty-message error in step with typing.
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    // Leaving the screen mid-debounce must not silently discard the edit.
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
      final trimmed = _controller.text.trim();
      if (trimmed.isNotEmpty) {
        _settings.edit((current) => current.copyWith(voiceMessage: trimmed));
      }
    }
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  /// Saves after a pause in typing.
  ///
  /// Each save writes to `SharedPreferences` *and* pushes the whole settings map across
  /// the platform channel to the native service; doing that per keystroke made a long
  /// message noticeably janky on a mid-range phone.
  void _commitDebounced(String value) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, () => _commit(value));
  }

  Future<void> _commit(String value) async {
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    await _settings.edit((current) => current.copyWith(voiceMessage: trimmed));
  }

  /// Inserts a tag at the caret, keeping the cursor after it.
  void _insertToken(String token) {
    final selection = _controller.selection;
    final text = _controller.text;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final updated = text.replaceRange(start, end, token);
    _controller.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: start + token.length),
    );
    _commit(updated);
  }

  Future<void> _preview() async {
    // Flush any pending edit first, so the preview speaks what is on screen rather
    // than the last debounced save.
    await _commit(_controller.text);
    if (!mounted) return;
    await ref.read(soundRepositoryProvider).previewVoice();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final level = ref.watch(monitorProvider).battery.level;

    final spoken = MessageTemplate.format(
      template: _controller.text.trim().isEmpty
          ? settings.voiceMessage
          : _controller.text,
      userName: settings.userName,
      batteryLevel: level == 0 ? AppConstants.fullBatteryLevel : level,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.voiceTitle),
        actions: [
          IconButton(
            tooltip: l10n.voiceResetDefault,
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: () {
              _controller.text = AppConstants.defaultVoiceMessage;
              _commit(AppConstants.defaultVoiceMessage);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(l10n.voiceMessageLabel, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: 5,
            maxLength: AppConstants.maxVoiceMessageLength,
            textInputAction: TextInputAction.newline,
            onChanged: _commitDebounced,
            decoration: InputDecoration(
              hintText: AppConstants.defaultVoiceMessage,
              errorText:
                  _controller.text.trim().isEmpty ? l10n.voiceMessageEmpty : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.voiceMessageHelp,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.person_outline, size: 18),
                label: Text(l10n.voiceTokenName),
                onPressed: () => _insertToken(AppConstants.nameToken),
              ),
              ActionChip(
                avatar: const Icon(Icons.battery_full_outlined, size: 18),
                label: Text(l10n.voiceTokenLevel),
                onPressed: () => _insertToken(AppConstants.levelToken),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Card(
            color: theme.colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.voicePreviewTitle,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '"$spoken"',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(
                      onPressed: _preview,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(l10n.actionPlayPreview),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  SliderTile(
                    icon: Icons.speed_rounded,
                    title: l10n.settingSpeechRate,
                    value: settings.speechRate,
                    min: AppConstants.minSpeechRate,
                    max: AppConstants.maxSpeechRate,
                    divisions: 15,
                    formatValue: (value) => '${value.toStringAsFixed(1)}×',
                    onCommit: (value) =>
                        controller.edit((current) => current.copyWith(speechRate: value)),
                  ),
                  SliderTile(
                    icon: Icons.graphic_eq_rounded,
                    title: l10n.settingSpeechPitch,
                    value: settings.speechPitch,
                    min: AppConstants.minSpeechPitch,
                    max: AppConstants.maxSpeechPitch,
                    divisions: 15,
                    formatValue: (value) => '${value.toStringAsFixed(1)}×',
                    onCommit: (value) =>
                        controller.edit((current) => current.copyWith(speechPitch: value)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text(l10n.voicePresets, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final suggestion in MessageTemplate.suggestions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  title: Text(
                    MessageTemplate.format(
                      template: suggestion,
                      userName: settings.userName,
                      batteryLevel: AppConstants.fullBatteryLevel,
                    ),
                  ),
                  trailing: const Icon(Icons.north_east_rounded, size: 18),
                  onTap: () {
                    _controller.text = suggestion;
                    _commit(suggestion);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
