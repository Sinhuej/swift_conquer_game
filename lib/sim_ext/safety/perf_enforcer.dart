import 'perf_limits.dart';

class PerfEnforcer {
  final PerfLimits limits;
  late final int _startMillis;

  PerfEnforcer(this.limits);

  void start(int nowMillis) {
    _startMillis = nowMillis;
  }

  void check({
    required int tick,
    required int nowMillis,
  }) {
    if (tick > limits.maxTicks) {
      throw StateError(
        'Perf limit exceeded: tick $tick > ${limits.maxTicks}',
      );
    }
    if ((nowMillis - _startMillis) > limits.maxMillis) {
      throw StateError(
        'Perf limit exceeded: runtime > ${limits.maxMillis}ms',
      );
    }
  }
}
