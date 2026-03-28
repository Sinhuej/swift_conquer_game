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

  void setZoomAroundScreen({
    required double newZoom,
    required Vec2 focalScreen,
  }) {
    final before = screenToWorld(focalScreen);
    zoom = newZoom.clamp(0.5, 2.5).toDouble();

    offset = Vec2(
      before.x - (focalScreen.x / zoom),
      before.y - (focalScreen.y / zoom),
    );
  }

  void zoomByScale({
    required double scaleDelta,
    required Vec2 focalScreen,
  }) {
    if (!scaleDelta.isFinite || scaleDelta <= 0) return;
    final target = (zoom * scaleDelta).clamp(0.5, 2.5).toDouble();
    setZoomAroundScreen(
      newZoom: target,
      focalScreen: focalScreen,
    );
  }
}
