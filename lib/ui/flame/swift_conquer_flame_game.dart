import 'package:flame/game.dart';
import 'package:flame/extensions.dart';

import 'camera/camera_smoother.dart';

class SwiftConquerFlameGame extends FlameGame {
  final CameraSmoother _cam = CameraSmoother(
    initialPosition: Vector2.zero(),
    initialZoom: 1.0,
    positionSharpness: 12.0,
    zoomSharpness: 10.0,
  );

  @override
  void update(double dt) {
    super.update(dt);

    final Vector2 targetWorldPos = _getCameraTargetWorldPosFromSnapshot();
    final double targetZoom = _getTargetZoomFromSnapshotOrDefault();

    _cam.update(
      dt: dt,
      targetPosition: targetWorldPos,
      targetZoom: targetZoom,
    );

    _applyCamera(_cam.position, _cam.zoom);
  }

  // ---------------------------------------------------------------------------
  // Snapshot-derived (read-only)
  // ---------------------------------------------------------------------------

  Vector2 _getCameraTargetWorldPosFromSnapshot() {
    return Vector2.zero(); // v1 safe default
  }

  double _getTargetZoomFromSnapshotOrDefault() {
    return 1.0;
  }

  // ---------------------------------------------------------------------------
  // FlameGame camera adapter (CORRECT)
  // ---------------------------------------------------------------------------

  void _applyCamera(Vector2 worldPos, double zoom) {
    camera.viewfinder.position = worldPos;
    camera.viewfinder.zoom = zoom;
  }
}
