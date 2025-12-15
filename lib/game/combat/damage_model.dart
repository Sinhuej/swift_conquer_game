import 'unit_stats.dart';

class DamageModel {
  static double calculate(attacker, defender) {
    final atk = attacker.stats.attack;
    final def = defender.stats.armor;

    // Sparkles-killer math: diminishing returns, deterministic
    final raw = atk * 1.25;
    final mitigated = raw * (100 / (100 + def));
    return mitigated.clamp(1, 9999);
  }
}
