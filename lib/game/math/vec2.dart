import 'dart:math';

class Vec2 {
  final double x;
  final double y;

  const Vec2(this.x, this.y);

  Vec2 operator +(Vec2 o) => Vec2(x + o.x, y + o.y);
  Vec2 operator -(Vec2 o) => Vec2(x - o.x, y - o.y);
  Vec2 operator *(double s) => Vec2(x * s, y * s);

  double get length => sqrt(x * x + y * y);

  Vec2 normalized() {
    final l = length;
    if (l == 0) return this;
    return Vec2(x / l, y / l);
  }
}
