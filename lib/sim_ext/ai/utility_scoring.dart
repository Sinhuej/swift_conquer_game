import 'ai_personality.dart';

/// Phase 105: utility scoring helpers.
///
/// Utility is double where higher = better. These helpers keep math stable.
class Utility {
  static double clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

  static double lerp(double a, double b, double t) => a + (b - a) * t;

  /// Mixes base utility with personality weighting.
  static double applyPersonality({
    required double base,
    required AiPersonality p,
    required double aggressionWeight,
    required double economyWeight,
    required double riskWeight,
  }) {
    final w =
        (p.aggression * aggressionWeight) +
        (p.economyBias * economyWeight) +
        (p.riskTolerance * riskWeight);

    // compress weights to [0.5, 1.5] band to avoid runaway scaling
    final scale = 0.5 + clamp01(w) * 1.0;
    return base * scale;
  }
}
