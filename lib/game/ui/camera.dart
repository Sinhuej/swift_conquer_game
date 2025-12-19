import '../math/vec2.dart';

class Camera {
  Vec2 pos;
  double zoom;

  Camera({this.pos = const Vec2(0, 0), this.zoom = 1.0});

  Vec2 worldToScreen(Vec2 w) => Vec2((w.x - pos.x) * zoom, (w.y - pos.y) * zoom);
  Vec2 screenToWorld(Vec2 s) => Vec2(s.x / zoom + pos.x, s.y / zoom + pos.y);

  void pan(Vec2 deltaScreen) {
    // screen delta -> world delta
    pos = Vec2(pos.x - deltaScreen.x / zoom, pos.y - deltaScreen.y / zoom);
  }

  void zoomBy(double factor, Vec2 anchorWorld) {
    final oldZoom = zoom;
    zoom = (zoom * factor).clamp(0.4, 3.0);

    // keep anchor stable
    final dx = anchorWorld.x - pos.x;
    final dy = anchorWorld.y - pos.y;
    final scale = oldZoom / zoom;
    pos = Vec2(anchorWorld.x - dx * scale, anchorWorld.y - dy * scale);
  }
}

extension _Clamp on double {
  double clamp(double lo, double hi) => this < lo ? lo : (this > hi ? hi : this);
}
