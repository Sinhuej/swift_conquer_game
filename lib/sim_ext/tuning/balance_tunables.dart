class BalanceTunables {
  final Map<String, num> _values = {};

  num get(String key, num fallback) =>
      _values[key] ?? fallback;

  void set(String key, num value) {
    _values[key] = value;
  }

  Map<String, Object?> toJson() => Map.of(_values);
}
