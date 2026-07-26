import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/sound_repository.dart';

import '../../../l10n/app_localizations.dart';
import '../../notifications/providers/notification_providers.dart';
import '../../settings/providers/settings_providers.dart';
import '../domain/alarm_sound.dart';
import '../providers/sound_providers.dart';

/// Picker for the alarm tone: the device's own alarm ringtones, plus anything the
/// user imported or recorded. Everything is stored locally.
class AlarmSoundScreen extends ConsumerStatefulWidget {
  const AlarmSoundScreen({super.key});

  @override
  ConsumerState<AlarmSoundScreen> createState() => _AlarmSoundScreenState();
}

class _AlarmSoundScreenState extends ConsumerState<AlarmSoundScreen> {
  /// Resolved eagerly in [initState].
  ///
  /// Every action on this screen waits on something the user can walk away from — a
  /// system file picker, a permission dialog, a confirmation. Touching `ref` after one
  /// of those completes throws if the screen has been popped in the meantime, so the
  /// dependencies are captured once here and the awaits are guarded by [mounted].
  late final SoundRepository _repository;
  late final SoundController _controller;
  late final PermissionController _permissions;

  @override
  void initState() {
    super.initState();
    _repository = ref.read(soundRepositoryProvider);
    _controller = ref.read(soundControllerProvider);
    _permissions = ref.read(permissionControllerProvider);
  }

  @override
  void dispose() {
    // A preview must never outlive the screen that started it.
    _repository.stopPreview();
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _select(AlarmSound? sound) async {
    await _controller.select(sound);
    if (!mounted) return;
    await _controller.preview(sound);
  }

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context);
    try {
      final imported = await _controller.importFile();
      if (!mounted) return;
      if (imported == null) {
        _snack(l10n.importCancelled);
        return;
      }
      await _select(imported);
    } on PlatformException {
      // The native side reports an unreadable or uncopyable file this way.
      _snack(l10n.importFailed);
    }
  }

  Future<void> _toggleRecording() async {
    final l10n = AppLocalizations.of(context);

    if (ref.read(isRecordingProvider)) {
      final saved = await _controller.stopRecording();
      if (!mounted) return;
      if (saved == null) {
        _snack(l10n.recordingFailed);
        return;
      }
      _snack(l10n.recordingSaved);
      await _select(saved);
      return;
    }

    final granted = await _permissions.requestMicrophone();
    if (!mounted) return;
    if (!granted) {
      _snack(l10n.recordingPermission);
      return;
    }
    final label = DateFormat('yyyyMMdd-HHmm').format(DateTime.now());
    final started = await _controller.startRecording(label);
    if (!started) _snack(l10n.recordingFailed);
  }

  Future<void> _delete(AlarmSound sound) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.actionDelete),
        content: Text(l10n.soundDeleteConfirm(sound.label)),
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
    if (confirmed != true || !mounted) return;

    final wasSelected = await _controller.delete(sound);
    _snack(wasSelected ? l10n.soundInUseReset : l10n.soundDeleted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final library = ref.watch(soundLibraryProvider);
    final selectedUri = ref.watch(settingsProvider.select((value) => value.soundUri));
    final recording = ref.watch(isRecordingProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.soundTitle)),
      body: library.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('$error', textAlign: TextAlign.center),
          ),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            if (recording)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Card(
                  color: theme.colorScheme.errorContainer,
                  child: ListTile(
                    leading: Icon(Icons.fiber_manual_record,
                        color: theme.colorScheme.onErrorContainer),
                    title: Text(
                      l10n.recordingInProgress,
                      style: TextStyle(color: theme.colorScheme.onErrorContainer),
                    ),
                  ),
                ),
              ),

            _Heading(l10n.soundCustom),
            if (data.custom.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  l10n.soundCustomEmpty,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              )
            else
              for (final sound in data.custom)
                _SoundTile(
                  sound: sound,
                  selected: sound.uri == selectedUri,
                  onSelect: () => _select(sound),
                  onDelete: () => _delete(sound),
                ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: recording ? null : _import,
                      icon: const Icon(Icons.file_open_outlined),
                      label: Text(l10n.actionImportAudio),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: _toggleRecording,
                      icon: Icon(recording ? Icons.stop_rounded : Icons.mic_none_rounded),
                      label: Text(
                        recording ? l10n.actionStopRecording : l10n.actionRecordVoice,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _Heading(l10n.soundBuiltIn),
            for (final sound in data.builtIn)
              _SoundTile(
                sound: sound,
                selected: sound.uri == selectedUri ||
                    (selectedUri.isEmpty && sound == data.builtIn.first),
                onSelect: () => _select(sound),
              ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _SoundTile extends StatelessWidget {
  const _SoundTile({
    required this.sound,
    required this.selected,
    required this.onSelect,
    this.onDelete,
  });

  final AlarmSound sound;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        switch (sound.kind) {
          AlarmSoundKind.recorded => Icons.mic_rounded,
          AlarmSoundKind.imported => Icons.audiotrack_rounded,
          AlarmSoundKind.builtIn => Icons.notifications_active_outlined,
        },
        color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        sound.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w400),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected)
            Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: onDelete,
            ),
        ],
      ),
      onTap: onSelect,
    );
  }
}
