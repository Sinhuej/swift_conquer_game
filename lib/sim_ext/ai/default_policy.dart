import 'ai_personality.dart';
import 'ai_policy.dart';
import 'ai_rng.dart';
import 'ai_types.dart';
import 'utility_scoring.dart';

/// Phase 106–110: default policy that selects among a small set of actions
/// using utility scoring + deterministic tiebreaks.
///
/// This does NOT mutate engine state; it only produces AiDecision.
/// Wiring happens later.
class DefaultPolicy implements AiPolicy {
  @override
  String get name => 'default-policy';

  @override
  AiDecision decide({
    required int tick,
    required String agentId,
    required AiObservation obs,
    required AiPersonality personality,
    required AiDifficultyTuning difficulty,
    required AiRng rng,
  }) {
    // Minimal observation schema (engine-agnostic)
    final enemiesNearby = (obs.data['enemiesNearby'] as int?) ?? 0;
    final resources = (obs.data['resources'] as int?) ?? 0;
    final underAttack = (obs.data['underAttack'] as bool?) ?? false;

    final candidates = <AiAction>[
      const AiAction('IDLE'),
      const AiAction('SCOUT'),
      const AiAction('GATHER'),
      const AiAction('ATTACK'),
      const AiAction('RETREAT'),
    ];

    double score(AiAction a) {
      switch (a.type) {
        case 'ATTACK':
          final base = (enemiesNearby > 0 ? 0.8 : 0.2) + (underAttack ? 0.2 : 0.0);
          return Utility.applyPersonality(
            base: Utility.clamp01(base),
            p: personality,
            aggressionWeight: 1.0,
            economyWeight: 0.0,
            riskWeight: 0.5,
          );
        case 'RETREAT':
          final base = (underAttack ? 0.9 : 0.1) + (enemiesNearby > 2 ? 0.1 : 0.0);
          return Utility.applyPersonality(
            base: Utility.clamp01(base),
            p: personality,
            aggressionWeight: 0.0,
            economyWeight: 0.0,
            riskWeight: 1.0,
          );
        case 'GATHER':
          final base = (resources < 50 ? 0.8 : 0.3);
          return Utility.applyPersonality(
            base: Utility.clamp01(base),
            p: personality,
            aggressionWeight: 0.0,
            economyWeight: 1.0,
            riskWeight: 0.0,
          );
        case 'SCOUT':
          final base = (enemiesNearby == 0 ? 0.6 : 0.2);
          return Utility.applyPersonality(
            base: Utility.clamp01(base),
            p: personality,
            aggressionWeight: 0.2,
            economyWeight: 0.2,
            riskWeight: 0.2,
          );
        case 'IDLE':
        default:
          return 0.1;
      }
    }

    // Determine best utility (deterministic)
    double best = -1;
    final scored = <AiAction, double>{};
    for (final c in candidates) {
      final s = score(c);
      scored[c] = s;
      if (s > best) best = s;
    }

    // Filter best actions
    final bestActions = scored.entries
        .where((e) => (e.value == best))
        .map((e) => e.key)
        .toList();

    // Tiebreak deterministically with RNG (difficulty randomness)
    final pick = bestActions.length == 1
        ? bestActions.first
        : bestActions[rng.nextInt(bestActions.length)];

    // Optional stochastic perturbation (still deterministic due to AiRng)
    if (difficulty.randomness > 0) {
      final roll = rng.nextDouble();
      if (roll < difficulty.randomness) {
        // pick any candidate (exploration)
        final explore = candidates[rng.nextInt(candidates.length)];
        return AiDecision(
          tick: tick,
          agentId: agentId,
          action: explore,
          meta: {
            'policy': name,
            'mode': 'explore',
            'roll': roll,
          },
        );
      }
    }

    return AiDecision(
      tick: tick,
      agentId: agentId,
      action: pick,
      meta: {
        'policy': name,
        'mode': 'greedy',
      },
    );
  }
}
