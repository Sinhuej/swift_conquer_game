class FixedTimestep {
  final double step;
  double _accum = 0.0;

  FixedTimestep({this.step = 1.0 / 60.0});

  /// Returns how many fixed steps to run this frame.
  int accumulate(double dt) {
    if (dt <= 0) return 0;
    _accum += dt;

    int n = 0;
    while (_accum >= step && n < 8) { // safety clamp
      _accum -= step;
      n++;
    }
    return n;
  }

  void reset() => _accum = 0.0;
}
