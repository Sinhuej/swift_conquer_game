class Vec2 {
  double x;
  double y;
  Vec2(this.x, this.y);

  Vec2 copy() => Vec2(x, y);

  Vec2 operator +(Vec2 other) => Vec2(x + other.x, y + other.y);
  Vec2 operator -(Vec2 other) => Vec2(x - other.x, y - other.y);
  Vec2 operator *(double s) => Vec2(x * s, y * s);

  double get length2 => x * x + y * y;
}
