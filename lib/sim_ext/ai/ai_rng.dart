/// Phase 103: deterministic AI RNG (xorshift32).
///
/// We intentionally do NOT use dart:math Random to avoid any platform nuance.
class AiRng {
  int _state;

  AiRng({required int seed}) : _state = (seed == 0 ? 1 : seed);

  int nextU32() {
    // xorshift32
    int x = _state;
    x ^= (x << 13) & 0xFFFFFFFF;
    x ^= (x >> 17) & 0xFFFFFFFF;
    x ^= (x << 5) & 0xFFFFFFFF;
    _state = x & 0xFFFFFFFF;
    return _state;
  }

  /// [0, 1)
  double nextDouble() {
    // 24-bit mantissa for stable behavior
    final v = nextU32() & 0x00FFFFFF;
    return v / 0x01000000;
  }

  int nextInt(int maxExclusive) {
    if (maxExclusive <= 0) {
      throw ArgumentError('maxExclusive must be > 0');
    }
    return (nextU32().abs() % maxExclusive);
  }
}
