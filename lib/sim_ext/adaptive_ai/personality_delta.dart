import '../ai/ai_personality.dart';

double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

/// Phase 166: delta to apply to AiPersonality (clamped).
class PersonalityDelta {
  final double aggressionDelta;
  final double economyDelta;
  final double riskDelta;

  const PersonalityDelta({
    required this.aggressionDelta,
    required this.economyDelta,
    required this.riskDelta,
  });

  AiPersonality applyTo(AiPersonality base) {
    return AiPersonality(
      aggression: _clamp01(base.aggression + aggressionDelta),
      economyBias: _clamp01(base.economyBias + economyDelta),
      riskTolerance: _clamp01(base.riskTolerance + riskDelta),
    );
  }
}
