import 'run_meta.dart';
import 'sim_logger.dart';
import 'sim_log_entry.dart';
import 'sim_snapshot.dart';
import 'sim_hasher.dart';

typedef SnapshotBuilder = Map<String, Object?> Function();

class SimInspector {
  final RunMeta meta;
  final SimLogger _logger;

  final int snapshotEveryTicks;
  int _lastSnapTick = -1;

  SimSnapshot? _latestSnapshot;
  String? _latestSnapshotHash;

  final SnapshotBuilder snapshotBuilder;

  SimInspector({
    required this.meta,
    required this.snapshotBuilder,
    int logCapacity = 5000,
    this.snapshotEveryTicks = 0, // 0 disables periodic snapshots
  }) : _logger = SimLogger(capacity: logCapacity);

  void log(
    int tick,
    String category,
    String message, {
    Map<String, Object?>? payload,
  }) {
    _logger.add(SimLogEntry(
      tick: tick,
      category: category,
      message: message,
      payload: payload,
    ));
  }

  List<SimLogEntry> lastNLogs(int n) => _logger.lastN(n);
  List<SimLogEntry> allLogs() => _logger.toList();
  void clearLogs() => _logger.clear();

  SimSnapshot? get latestSnapshot => _latestSnapshot;
  String? get latestSnapshotHash => _latestSnapshotHash;

  /// Call from the sim loop at each tick boundary.
  void onTick(int tick) {
    if (snapshotEveryTicks <= 0) return;
    if (tick == _lastSnapTick) return;

    if (tick % snapshotEveryTicks == 0) {
      captureSnapshot(tick);
      _lastSnapTick = tick;
    }
  }

  /// Explicit snapshot capture (e.g., end of run, or tests).
  SimSnapshot captureSnapshot(int tick) {
    final data = snapshotBuilder();
    final snap = SimSnapshot(tick: tick, data: data);
    _latestSnapshot = snap;
    _latestSnapshotHash = SimHasher.stableHash(snap.toJson());
    return snap;
  }
}
