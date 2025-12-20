class SimSnapshot {
  final int tick;

  /// json-safe, primitive-only, stable ordering handled elsewhere if needed.
  final Map<String, Object?> data;

  const SimSnapshot({
    required this.tick,
    required this.data,
  });

  Map<String, Object?> toJson() => <String, Object?>{
        'tick': tick,
        'data': data,
      };

  @override
  String toString() => 'SimSnapshot(tick=$tick, keys=${data.keys.length})';
}
