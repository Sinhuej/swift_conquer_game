import '../math/vec2.dart';

class CameraView {
  Vec2 offset;
  double zoom;

  CameraView({
    required this.offset,
    required this.zoom,
  });

  Vec2 worldToScreen(Vec2 world) {
    return Vec2(
      (world.x - offset.x) * zoom,
      (world.y - offset.y) * zoom,
    );
  }

  Vec2 screenToWorld(Vec2 screen) {
    return Vec2(
      offset.x + (screen.x / zoom),
      offset.y + (screen.y / zoom),
    );
  }

  void panByScreenDelta(Vec2 deltaScreen) {
    offset = Vec2(
      offset.x - (deltaScreen.x / zoom),
      offset.y - (deltaScreen.y / zoom),
    );
  }
}
