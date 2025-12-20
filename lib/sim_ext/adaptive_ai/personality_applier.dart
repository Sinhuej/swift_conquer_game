import '../ai/ai_personality.dart';
import 'personality_delta.dart';

double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

/// Phase 168: Applies deltas with smoothing.
///
/// This prevents oscillation by blending new personality with old.
class PersonalityApplier {
  final double smoothing; // 0..1, higher = faster adaptation

  const PersonalityApplier({this.smoothing = 0.25});

  AiPersonality apply({
    required AiPersonality current,
    required PersonalityDelta delta,
  }) {
    final target = delta.applyTo(current);

    double blend(double a, double b) => a + (b - a) * smoothing;

    return AiPersonality(
      aggression: _clamp01(blend(current.aggression, target.aggression)),
      economyBias: _clamp01(blend(current.economyBias, target.economyBias)),
      riskTolerance: _clamp01(blend(current.riskTolerance, target.riskTolerance)),
    );
  }
}
