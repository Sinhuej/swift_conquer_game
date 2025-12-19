class Telemetry {
  final Map<String, int> counters = {};

  void inc(String key, [int by = 1]) {
    counters[key] = (counters[key] ?? 0) + by;
  }
}
