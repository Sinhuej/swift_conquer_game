import '../ai/ai_personality.dart';

/// Phase 128–130: registry of AI agents and their knobs.
/// This is engine-agnostic. Wiring to actual teams/entities comes later.
class AiAgentSpec {
  final String agentId;
  final AiPersonality personality;
  final AiDifficulty difficulty;
  final int seed;

  const AiAgentSpec({
    required this.agentId,
    required this.personality,
    required this.difficulty,
    required this.seed,
  });
}

class AiAgentRegistry {
  final Map<String, AiAgentSpec> _agents = {};

  void register(AiAgentSpec spec) {
    _agents[spec.agentId] = spec;
  }

  AiAgentSpec? get(String agentId) => _agents[agentId];

  List<AiAgentSpec> get all {
    final out = _agents.values.toList();
    out.sort((a, b) => a.agentId.compareTo(b.agentId));
    return out;
  }
}
