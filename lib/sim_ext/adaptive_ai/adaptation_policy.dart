import 'player_behavior_profile.dart';
import 'personality_delta.dart';

double _clamp(double v, double lo, double hi) =>
    v < lo ? lo : (v > hi ? hi : v);

/// Phase 167: Converts behavior profile into small personality deltas.
///
/// Philosophy:
/// - If player rushes, AI becomes more defensive (lower aggression, higher risk aversion)
/// - If player turtles, AI becomes more aggressive / expansion-focused
/// - If player expands a lot, AI raises aggression slightly
/// - If player retreats often, AI increases aggression
///
/// Deltas are intentionally small and clamped to avoid "rubber banding".
class AdaptationPolicy {
  /// Maximum delta magnitude per adjustment window.
  final double maxDelta;

  const AdaptationPolicy({this.maxDelta = 0.10});

  PersonalityDelta compute(PlayerBehaviorProfile p) {
    final rush = p.rushRate.value;
    final turtle = p.turtleRate.value;
    final expand = p.expansionRate.value;
    final retreat = p.retreatRate.value;
    final tech = p.techBias.value;

    // Aggression: counter turtle with aggression; counter rush with caution.
    final aggression = (turtle * 0.12) + (retreat * 0.08) - (rush * 0.12);
    // Economy: when player techs/expands, AI should also shift to economy.
    final economy = (tech * 0.10) + (expand * 0.08) - (rush * 0.06);
    // Risk: when player rushes, AI reduces risk; when player turtles, AI can risk more.
    final risk = (turtle * 0.08) - (rush * 0.12) - (retreat * 0.04);

    return PersonalityDelta(
      aggressionDelta: _clamp(aggression, -maxDelta, maxDelta),
      economyDelta: _clamp(economy, -maxDelta, maxDelta),
      riskDelta: _clamp(risk, -maxDelta, maxDelta),
    );
  }
}
