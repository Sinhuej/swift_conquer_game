class BalanceMath {
  /// DPS = damage * attacks per second
  static double dps(int damage, double attackSpeed) {
    return damage * attackSpeed;
  }

  /// Time-to-kill (seconds)
  static double ttk({
    required int targetHp,
    required double dps,
  }) {
    if (dps <= 0) return double.infinity;
    return targetHp / dps;
  }
}
