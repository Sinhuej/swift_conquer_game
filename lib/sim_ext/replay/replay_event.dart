class ReplayEvent {
  final int tick;
  final String type;
  final Map<String, Object?> payload;

  ReplayEvent({
    required this.tick,
    required this.type,
    required this.payload,
  });

  Map<String, Object?> toJson() => {
        'tick': tick,
        'type': type,
        'payload': payload,
      };
}
