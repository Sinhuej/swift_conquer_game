typedef LogPayload = Map<String, Object?>;

class SimLogEntry {
  final int tick;
  final String category;
  final String message;

  /// Payload must be primitives / json-safe only.
  final LogPayload payload;

  const SimLogEntry({
    required this.tick,
    required this.category,
    required this.message,
    LogPayload? payload,
  }) : payload = payload ?? const {};

  Map<String, Object?> toJson() => <String, Object?>{
        'tick': tick,
        'category': category,
        'message': message,
        'payload': payload,
      };

  @override
  String toString() => '[$tick][$category] $message $payload';
}
