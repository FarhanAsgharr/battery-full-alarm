import 'package:flutter/foundation.dart';

/// One charger-in → charger-out cycle, as recorded by the native service.
@immutable
class ChargeSession {
  const ChargeSession({
    required this.id,
    required this.startedAt,
    this.endedAt,
    this.startLevel = 0,
    this.endLevel = 0,
    this.peakLevel = 0,
    this.fullAt,
    this.alarmCount = 0,
    this.plugType = 'unknown',
  });

  final int id;
  final DateTime startedAt;

  /// Null while the charger is still connected.
  final DateTime? endedAt;
  final int startLevel;
  final int endLevel;
  final int peakLevel;

  /// When the battery first reached 100%, or null if it never did.
  final DateTime? fullAt;
  final int alarmCount;
  final String plugType;

  bool get isActive => endedAt == null;
  bool get reachedFull => fullAt != null;

  /// Total time the charger stayed connected. For an active session this grows with
  /// [now], which the caller supplies so widgets stay testable and rebuild predictably.
  Duration pluggedDuration([DateTime? now]) =>
      (endedAt ?? now ?? DateTime.now()).difference(startedAt);

  /// Time spent charging up to 100%. Null when the session never got there.
  Duration? get timeToFull => fullAt?.difference(startedAt);

  /// Percentage points gained over the session.
  int get levelGained => (peakLevel - startLevel).clamp(0, 100);

  factory ChargeSession.fromMap(Map<dynamic, dynamic> map) {
    DateTime? at(String key) {
      final raw = (map[key] as num?)?.toInt() ?? 0;
      return raw > 0 ? DateTime.fromMillisecondsSinceEpoch(raw) : null;
    }

    final started = at('startedAt') ?? DateTime.fromMillisecondsSinceEpoch(0);
    return ChargeSession(
      id: (map['id'] as num?)?.toInt() ?? started.millisecondsSinceEpoch,
      startedAt: started,
      endedAt: at('endedAt'),
      startLevel: (map['startLevel'] as num?)?.toInt() ?? 0,
      endLevel: (map['endLevel'] as num?)?.toInt() ?? 0,
      peakLevel: (map['peakLevel'] as num?)?.toInt() ?? 0,
      fullAt: at('fullAt'),
      alarmCount: (map['alarmCount'] as num?)?.toInt() ?? 0,
      plugType: map['plugType'] as String? ?? 'unknown',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChargeSession &&
          other.id == id &&
          other.startedAt == startedAt &&
          other.endedAt == endedAt &&
          other.startLevel == startLevel &&
          other.endLevel == endLevel &&
          other.peakLevel == peakLevel &&
          other.fullAt == fullAt &&
          other.alarmCount == alarmCount &&
          other.plugType == plugType;

  @override
  int get hashCode => Object.hash(
        id,
        startedAt,
        endedAt,
        startLevel,
        endLevel,
        peakLevel,
        fullAt,
        alarmCount,
        plugType,
      );
}
