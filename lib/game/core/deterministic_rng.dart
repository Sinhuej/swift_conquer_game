class DeterministicRng {
  int _state;

  DeterministicRng({int seed = 1}) : _state = (seed == 0 ? 1 : seed);

  /// xorshift32
  int nextUint32() {
    int x = _state;
    x ^= (x << 13);
    x ^= (x >> 17);
    x ^= (x << 5);
    _state = x;
    return x & 0xFFFFFFFF;
  }

  double nextDouble() => nextUint32() / 0xFFFFFFFF;

  int nextInt(int maxExclusive) {
    if (maxExclusive <= 0) return 0;
    return nextUint32() % maxExclusive;
  }

  int get seed => _state;
}
