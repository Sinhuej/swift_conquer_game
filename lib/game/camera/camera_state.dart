import '../math/vec2.dart';

class CameraState {
  Vec2 offset = const Vec2(0, 0);
  double zoom = 1.0;

  Vec2 screenToWorld(Vec2 screen) => Vec2(
        (screen.x / zoom) + offset.x,
        (screen.y / zoom) + offset.y,
      );

  Vec2 worldToScreen(Vec2 world) => Vec2(
        (world.x - offset.x) * zoom,
        (world.y - offset.y) * zoom,
      );
}
