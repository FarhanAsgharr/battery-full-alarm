import '../../../core/platform/native_bridge.dart';
import '../domain/charge_session.dart';

/// Reads the charging log the native service writes.
///
/// The log lives natively because most sessions happen with the Flutter engine shut
/// down; Dart only ever reads and prunes it.
class HistoryRepository {
  HistoryRepository(this._bridge);

  final NativeBridge _bridge;

  Future<List<ChargeSession>> load() async {
    final raw = await _bridge.getHistory();
    final sessions = raw.map(ChargeSession.fromMap).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }

  Future<void> delete(int id) => _bridge.deleteHistoryEntry(id);

  Future<void> clear() => _bridge.clearHistory();
}
