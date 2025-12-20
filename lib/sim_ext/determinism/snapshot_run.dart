typedef SnapshotAtTick = Map<String, Object?>;

class SnapshotRun {
  final Map<int, SnapshotAtTick> snapshots;

  SnapshotRun(this.snapshots);

  SnapshotAtTick? at(int tick) => snapshots[tick];

  List<int> get ticks {
    final t = snapshots.keys.toList();
    t.sort();
    return t;
  }
}
