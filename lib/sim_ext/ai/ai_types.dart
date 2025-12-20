/// Phase 101: AI core primitives (headless, inert).
///
/// These types are intentionally engine-agnostic so we can wire them into
/// SystemManager later without risking core determinism.

typedef AiPayload = Map<String, Object?>;

class AiAction {
  final String type;
  final AiPayload payload;

  const AiAction(this.type, [this.payload = const {}]);

  Map<String, Object?> toJson() => {
        'type': type,
        'payload': payload,
      };

  @override
  String toString() => 'AiAction(type=$type, payload=$payload)';
}

class AiObservation {
  final AiPayload data;

  const AiObservation(this.data);

  Map<String, Object?> toJson() => Map<String, Object?>.from(data);
}

class AiDecision {
  final int tick;
  final String agentId;
  final AiAction action;
  final AiPayload meta;

  const AiDecision({
    required this.tick,
    required this.agentId,
    required this.action,
    this.meta = const {},
  });

  Map<String, Object?> toJson() => {
        'tick': tick,
        'agentId': agentId,
        'action': action.toJson(),
        'meta': meta,
      };
}
