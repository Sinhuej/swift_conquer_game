class DamageModel {
  static int calculate({
    required int attack,
    required int defense,
  }) {
    // Deterministic RTS-style math
    final raw = attack - defense;
    return raw < 1 ? 1 : raw;
  }
}
