class PerfGuards {
  final int maxTicks;
  final int maxWallClockMs;

  int _startMs = 0;

  PerfGuards({
    required this.maxTicks,
    required this.maxWallClockMs,
  });

  void start(int nowMs) {
    _startMs = nowMs;
  }

  void check({
    required int tick,
    required int nowMs,
  }) {
    if (tick > maxTicks) {
      throw StateError('PerfGuard: maxTicks exceeded (tick=$tick max=$maxTicks)');
    }
    final elapsed = nowMs - _startMs;
    if (elapsed > maxWallClockMs) {
      throw StateError(
        'PerfGuard: maxWallClockMs exceeded (elapsed=${elapsed}ms max=${maxWallClockMs}ms)',
      );
    }
  }
}
