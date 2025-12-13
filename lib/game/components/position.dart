class Position {
  double x;
  double y;
  Position(this.x, this.y);

  double distanceTo(Position other) {
    final dx = other.x - x;
    final dy = other.y - y;
    return (dx * dx + dy * dy).sqrt();
  }
}

extension _Sqrt on double {
  double sqrt() => Math.sqrt(this);
}

class Math {
  static double sqrt(double v) => v <= 0 ? 0 : _sqrtNewton(v);
  static double _sqrtNewton(double v) {
    var x = v;
    for (int i = 0; i < 12; i++) {
      if (x == 0) return 0;
      x = 0.5 * (x + v / x);
    }
    return x;
  }
}
