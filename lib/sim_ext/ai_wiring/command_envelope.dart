/// Phase 121: Engine-agnostic command envelope emitted by AI.
/// This is intentionally NOT tied to game/commands yet to avoid signature risk.
class CommandEnvelope {
  final int tick;
  final String agentId;
  final String commandType;
  final Map<String, Object?> payload;

  const CommandEnvelope({
    required this.tick,
    required this.agentId,
    required this.commandType,
    required this.payload,
  });

  Map<String, Object?> toJson() => {
        'tick': tick,
        'agentId': agentId,
        'commandType': commandType,
        'payload': payload,
      };

  @override
  String toString() =>
      'CommandEnvelope(tick=$tick, agentId=$agentId, commandType=$commandType, payload=$payload)';
}
