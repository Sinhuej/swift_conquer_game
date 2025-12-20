import 'ai_personality.dart';
import 'ai_rng.dart';
import 'ai_types.dart';

/// Phase 104: policy interface for AI decision making.
abstract class AiPolicy {
  String get name;

  /// Called to produce a decision for an agent at a given tick.
  AiDecision decide({
    required int tick,
    required String agentId,
    required AiObservation obs,
    required AiPersonality personality,
    required AiDifficultyTuning difficulty,
    required AiRng rng,
  });
}
