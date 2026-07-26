import 'package:flutter/foundation.dart';

/// Where an alarm sound came from.
enum AlarmSoundKind {
  /// A ringtone already present on the device.
  builtIn,

  /// An audio file the user imported, copied into app storage.
  imported,

  /// A clip the user recorded in the app.
  recorded,
}

/// One selectable entry in the alarm sound picker.
@immutable
class AlarmSound {
  const AlarmSound({
    required this.uri,
    required this.label,
    required this.kind,
  });

  final String uri;
  final String label;
  final AlarmSoundKind kind;

  /// True for the device ringtones the app did not create. Removing one hides it
  /// rather than deleting it — see [AlarmSoundRemoval].
  bool get isDeviceSound => kind == AlarmSoundKind.builtIn;

  factory AlarmSound.fromMap(Map<dynamic, dynamic> map) => AlarmSound(
        uri: map['uri'] as String? ?? '',
        label: map['label'] as String? ?? '',
        kind: switch (map['type'] as String?) {
          'imported' => AlarmSoundKind.imported,
          'recorded' => AlarmSoundKind.recorded,
          _ => AlarmSoundKind.builtIn,
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmSound &&
          other.uri == uri &&
          other.label == label &&
          other.kind == kind;

  @override
  int get hashCode => Object.hash(uri, label, kind);
}

/// The full sound catalogue, split the way the picker renders it.
@immutable
class AlarmSoundLibrary {
  const AlarmSoundLibrary({
    this.builtIn = const [],
    this.custom = const [],
    this.hiddenCount = 0,
  });

  final List<AlarmSound> builtIn;
  final List<AlarmSound> custom;

  /// How many device sounds the user has hidden. Drives the Restore action.
  final int hiddenCount;

  /// True when the picker has nothing left to offer. The alarm still works — it falls
  /// back to the device's default tone — but the UI has to say so.
  bool get isEmpty => builtIn.isEmpty && custom.isEmpty;

  factory AlarmSoundLibrary.fromMap(Map<dynamic, dynamic> map) {
    List<AlarmSound> parse(Object? raw) => raw is List
        ? raw.whereType<Map>().map(AlarmSound.fromMap).toList(growable: false)
        : const [];
    return AlarmSoundLibrary(
      builtIn: parse(map['builtIn']),
      custom: parse(map['custom']),
      hiddenCount: (map['hiddenCount'] as num?)?.toInt() ?? 0,
    );
  }
}

/// What happened when a sound was removed.
///
/// The distinction matters to the user: a file they imported is gone for good, while a
/// device ringtone is only hidden and can be brought back from Settings.
enum AlarmSoundRemoval {
  /// A file this app owned was deleted from storage.
  deleted,

  /// A device ringtone was hidden from the picker.
  hidden,

  /// Nothing matched — already gone. Treated as success by the UI.
  missing;

  static AlarmSoundRemoval fromName(String? value) => switch (value) {
        'deleted' => AlarmSoundRemoval.deleted,
        'hidden' => AlarmSoundRemoval.hidden,
        _ => AlarmSoundRemoval.missing,
      };
}
