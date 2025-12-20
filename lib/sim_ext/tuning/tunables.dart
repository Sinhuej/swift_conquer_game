class Tunables {
  final Map<String, num> _values;

  Tunables([Map<String, num>? initial]) : _values = Map.of(initial ?? const {});

  num getNum(String key, {required num fallback}) => _values[key] ?? fallback;

  int getInt(String key, {required int fallback}) {
    final v = _values[key];
    if (v == null) return fallback;
    return v.round();
  }

  double getDouble(String key, {required double fallback}) {
    final v = _values[key];
    if (v == null) return fallback;
    return v.toDouble();
  }

  bool has(String key) => _values.containsKey(key);

  void set(String key, num value) {
    _values[key] = value;
  }

  Map<String, Object?> toJson() => _values.map((k, v) => MapEntry(k, v));

  static Tunables fromJson(Map<String, Object?> json) {
    final out = <String, num>{};
    for (final e in json.entries) {
      final v = e.value;
      if (v is num) out[e.key] = v;
    }
    return Tunables(out);
  }
}
