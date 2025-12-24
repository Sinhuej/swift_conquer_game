import 'dart:ui'; // <-- REQUIRED for Paint & Color

import 'package:flame/game.dart';
import 'package:flame/extensions.dart';
import 'package:flame/components.dart';

import 'camera/camera_smoother.dart';
import 'render/parallax_layer.dart';

class SwiftConquerFlameGame extends FlameGame {
  final CameraSmoother _cam = CameraSmoother(
    initialPosition: Vector2.zero(),
    initialZoom: 1.0,
    positionSharpness: 12.0,
    zoomSharpness: 10.0,
  );

  late final ParallaxLayer _bgFar;
  late final ParallaxLayer _bgMid;
  late final ParallaxLayer _bgNear;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _bgFar = ParallaxLayer(
      parallaxFactor: 0.2,
      size: canvasSize,
      child: RectangleComponent(
        size: canvasSize,
        paint: Paint()..color = const Color(0xFF101820),
      ),
    );

    _bgMid = ParallaxLayer(
      parallaxFactor: 0.4,
      size: canvasSize,
      child: RectangleComponent(
        size: canvasSize,
        paint: Paint()..color = const Color(0xFF182430),
      ),
    );

    _bgNear = ParallaxLayer(
      parallaxFactor: 0.6,
      size: canvasSize,
      child: RectangleComponent(
        size: canvasSize,
        paint: Paint()..color = const Color(0xFF202E3A),
      ),
    );

    addAll([_bgFar, _bgMid, _bgNear]);
  }

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

    _bgFar.updateFromCamera(_cam.position);
    _bgMid.updateFromCamera(_cam.position);
    _bgNear.updateFromCamera(_cam.position);
  }

  Vector2 _getCameraTargetWorldPosFromSnapshot() {
    return Vector2.zero();
  }

  double _getTargetZoomFromSnapshotOrDefault() {
    return 1.0;
  }

  void _applyCamera(Vector2 worldPos, double zoom) {
    camera.viewfinder.position = worldPos;
    camera.viewfinder.zoom = zoom;
  }
}
