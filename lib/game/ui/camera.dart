import '../math/vec2.dart';

class Camera {
  Vec2 position = const Vec2(0, 0);
  double zoom = 1.0;

  void pan(Vec2 delta) {
    position = position + delta;
  }

  void setZoom(double z) {
    zoom = z.clamp(0.25, 4.0);
  }
}
