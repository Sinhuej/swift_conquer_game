import '../math/vec2.dart';

class Position {
  double x;
  double y;

  Position(this.x, this.y);

  Vec2 get vec => Vec2(x, y);
}
