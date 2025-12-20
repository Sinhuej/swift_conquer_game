class DeterministicRng {
  int _state;

  DeterministicRng(int seed) : _state = seed == 0 ? 1 : seed;

  /// Simple LCG: deterministic across platforms.
  int nextInt() {
    _state = (1103515245 * _state + 12345) & 0x7fffffff;
    return _state;
  }

  /// 0.0 <= value < 1.0
  double nextDouble() => nextInt() / 2147483648.0;

  int rangeInt(int min, int maxExclusive) {
    if (maxExclusive <= min) return min;
    final span = maxExclusive - min;
    return min + (nextInt() % span);
  }
}
