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
    this.deletable = false,
  });

  final String uri;
  final String label;
  final AlarmSoundKind kind;

  /// Only sounds the app itself stores can be deleted; device ringtones cannot.
  final bool deletable;

  factory AlarmSound.fromMap(Map<dynamic, dynamic> map) => AlarmSound(
        uri: map['uri'] as String? ?? '',
        label: map['label'] as String? ?? '',
        kind: switch (map['type'] as String?) {
          'imported' => AlarmSoundKind.imported,
          'recorded' => AlarmSoundKind.recorded,
          _ => AlarmSoundKind.builtIn,
        },
        deletable: map['deletable'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmSound &&
          other.uri == uri &&
          other.label == label &&
          other.kind == kind &&
          other.deletable == deletable;

  @override
  int get hashCode => Object.hash(uri, label, kind, deletable);
}

/// The full sound catalogue, split the way the picker renders it.
@immutable
class AlarmSoundLibrary {
  const AlarmSoundLibrary({this.builtIn = const [], this.custom = const []});

  final List<AlarmSound> builtIn;
  final List<AlarmSound> custom;

  factory AlarmSoundLibrary.fromMap(Map<dynamic, dynamic> map) {
    List<AlarmSound> parse(Object? raw) => raw is List
        ? raw.whereType<Map>().map(AlarmSound.fromMap).toList(growable: false)
        : const [];
    return AlarmSoundLibrary(
      builtIn: parse(map['builtIn']),
      custom: parse(map['custom']),
    );
  }
}
