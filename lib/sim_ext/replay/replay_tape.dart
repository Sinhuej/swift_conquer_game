class ReplayTape {
  final int seed;
  final String scenarioId;

  /// tick -> list of decisions/inputs in stable order.
  final Map<int, List<Map<String, Object?>>> _eventsByTick = {};

  ReplayTape({
    required this.seed,
    required this.scenarioId,
  });

  void record(int tick, String type, Map<String, Object?> payload) {
    final list = _eventsByTick.putIfAbsent(tick, () => <Map<String, Object?>>[]);
    list.add(<String, Object?>{
      'type': type,
      'payload': payload,
    });
  }

  List<Map<String, Object?>> eventsAt(int tick) =>
      List.unmodifiable(_eventsByTick[tick] ?? const []);

  Map<String, Object?> toJson() => <String, Object?>{
        'seed': seed,
        'scenarioId': scenarioId,
        'eventsByTick': _eventsByTick.map((k, v) => MapEntry(k.toString(), v)),
      };

  static ReplayTape fromJson(Map<String, Object?> json) {
    final seed = json['seed'] as int;
    final scenarioId = json['scenarioId'] as String;

    final tape = ReplayTape(seed: seed, scenarioId: scenarioId);

    final eventsByTick = (json['eventsByTick'] as Map).cast<String, Object?>();
    for (final entry in eventsByTick.entries) {
      final tick = int.parse(entry.key);
      final list = (entry.value as List)
          .map((e) => (e as Map).cast<String, Object?>())
          .toList(growable: false);
      tape._eventsByTick[tick] = list;
    }
    return tape;
  }
}
