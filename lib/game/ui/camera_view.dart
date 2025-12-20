import '../math/vec2.dart';

class CameraView {
  Vec2 offset;
  double zoom;

  CameraView({this.offset = const Vec2(0, 0), this.zoom = 1.0});

  Vec2 screenToWorld(Vec2 screen) {
    // world = (screen / zoom) + offset
    return Vec2(screen.x / zoom + offset.x, screen.y / zoom + offset.y);
  }

  Vec2 worldToScreen(Vec2 world) {
    // screen = (world - offset) * zoom
    return Vec2((world.x - offset.x) * zoom, (world.y - offset.y) * zoom);
  }
}
