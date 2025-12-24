import 'package:flame/game.dart';
import 'package:flame/extensions.dart';

import 'camera/camera_smoother.dart';

class SwiftConquerFlameGame extends FlameGame {
  /// Pure-visual camera smoother (NO sim authority)
  final CameraSmoother _cam = CameraSmoother(
    initialPosition: Vector2.zero(),
    initialZoom: 1.0,
    positionSharpness: 12.0,
    zoomSharpness: 10.0,
  );

  @override
  void update(double dt) {
    super.update(dt);

    // ---- READ-ONLY SNAPSHOT DERIVATION ----
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
  // Snapshot-derived targets (VISUAL ONLY)
  // ---------------------------------------------------------------------------

  Vector2 _getCameraTargetWorldPosFromSnapshot() {
    // TODO: replace with real snapshot read
    // Safe v1 default: center of the world / map
    return Vector2.zero();
  }

  double _getTargetZoomFromSnapshotOrDefault() {
    // TODO: derive later (combat zoom, selection, etc.)
    return 1.0;
  }

  // ---------------------------------------------------------------------------
  // Camera adapter (Flame-version isolated)
  // ---------------------------------------------------------------------------

  void _applyCamera(Vector2 worldPos, double zoom) {
    // Most common Flame camera API
    cameraComponent.viewfinder.position = worldPos;
    cameraComponent.viewfinder.zoom = zoom;
  }
}
