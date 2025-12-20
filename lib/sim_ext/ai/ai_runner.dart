import 'ai_personality.dart';
import 'ai_policy.dart';
import 'ai_rng.dart';
import 'ai_types.dart';

/// Phase 111–115: AI runner that decides on cadence (thinkEveryTicks).
///
/// No engine mutation; this returns decisions and lets caller apply them.
class AiRunner {
  final AiPolicy policy;
  final AiPersonality personality;
  final AiDifficultyTuning difficulty;
  final AiRng rng;

  AiRunner({
    required this.policy,
    required this.personality,
    required this.difficulty,
    required int seed,
  }) : rng = AiRng(seed: seed);

  bool shouldThink(int tick) => tick % difficulty.thinkEveryTicks == 0;

  AiDecision? maybeDecide({
    required int tick,
    required String agentId,
    required AiObservation obs,
  }) {
    if (!shouldThink(tick)) return null;

    return policy.decide(
      tick: tick,
      agentId: agentId,
      obs: obs,
      personality: personality,
      difficulty: difficulty,
      rng: rng,
    );
  }
}
