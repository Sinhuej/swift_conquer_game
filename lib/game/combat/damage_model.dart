class DamageModel {
  static int compute({
    required int base,
    double multiplier = 1.0,
  }) {
    final dmg = (base * multiplier).round();
    return dmg < 0 ? 0 : dmg;
  }
}
