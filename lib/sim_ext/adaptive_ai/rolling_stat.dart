/// Phase 161–162: deterministic rolling statistic (EMA).
///
/// Uses fixed alpha and clamps to keep results stable and bounded.
class RollingStat {
  final double alpha; // 0..1
  double _value;

  RollingStat({required this.alpha, double initial = 0.0})
      : _value = initial;

  double get value => _value;

  void update(double sample) {
    _value = _value + alpha * (sample - _value);
  }

  Map<String, Object?> toJson() => {
        'alpha': alpha,
        'value': _value,
      };
}
