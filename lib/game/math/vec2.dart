import 'dart:math' as math;

class Vec2 {
  final double x;
  final double y;

  const Vec2(this.x, this.y);

  Vec2 operator +(Vec2 o) => Vec2(x + o.x, y + o.y);
  Vec2 operator -(Vec2 o) => Vec2(x - o.x, y - o.y);
  Vec2 operator *(double s) => Vec2(x * s, y * s);

  double get length => math.sqrt(x * x + y * y);

  Vec2 normalized() {
    final len = length;
    if (len <= 0.000001) return const Vec2(0, 0);
    return Vec2(x / len, y / len);
  }

  double distanceTo(Vec2 o) => (this - o).length;
}
