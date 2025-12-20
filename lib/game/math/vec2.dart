class Vec2 {
  final double x;
  final double y;

  const Vec2(this.x, this.y);

  Vec2 operator +(Vec2 o) => Vec2(x + o.x, y + o.y);
  Vec2 operator -(Vec2 o) => Vec2(x - o.x, y - o.y);
  Vec2 operator *(double s) => Vec2(x * s, y * s);

  double get length => _sqrt(x * x + y * y);

  Vec2 normalized() {
    final len = length;
    if (len == 0) return const Vec2(0, 0);
    return Vec2(x / len, y / len);
  }

  static double _sqrt(double v) {
    // Newton-Raphson
    if (v <= 0) return 0;
    double x = v;
    for (int i = 0; i < 12; i++) {
      x = 0.5 * (x + v / x);
    }
    return x;
  }
}
