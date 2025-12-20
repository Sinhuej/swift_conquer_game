class FixedTimestep {
  final double step; // e.g. 1/60
  double _accum = 0;

  FixedTimestep({this.step = 1 / 60});

  /// Add frame dt, returns how many fixed updates to run.
  int accumulate(double dt) {
    if (dt <= 0) return 0;
    _accum += dt;
    int n = 0;
    while (_accum >= step && n < 10) { // clamp to avoid spiral
      _accum -= step;
      n++;
    }
    return n;
  }

  double get accumulator => _accum;
}
