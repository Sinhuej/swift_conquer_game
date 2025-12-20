import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

/// Camera input using Flame 1.34-safe detectors.
/// - PanDetector: drag to pan
/// - ScaleDetector: pinch / wheel to zoom
class CameraInput extends Component
    with PanDetector, ScaleDetector, HasGameRef<FlameGame> {

  @override
  void onPanUpdate(DragUpdateInfo info) {
    // Pan camera opposite drag direction
    gameRef.camera.viewfinder.position -= info.delta.global;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    if (info.scale == 1.0) return;

    final current = gameRef.camera.viewfinder.zoom;
    final next = (current * info.scale).clamp(0.5, 3.0);
    gameRef.camera.viewfinder.zoom = next;
  }
}
