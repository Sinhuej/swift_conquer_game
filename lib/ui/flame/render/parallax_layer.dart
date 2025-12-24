import 'package:flame/components.dart';
import 'package:flame/game.dart';

/// Pure visual parallax layer.
/// Moves slower/faster than camera to create depth illusion.
/// NO gameplay logic. NO sim access.
class ParallaxLayer extends PositionComponent {
  final double parallaxFactor;
  final Vector2 baseOffset;

  ParallaxLayer({
    required this.parallaxFactor,
    Vector2? baseOffset,
    Vector2? size,
    Component? child,
  }) : baseOffset = baseOffset ?? Vector2.zero() {
    if (size != null) {
      this.size = size;
    }
    if (child != null) {
      add(child);
    }
  }

  /// Call every frame from FlameGame.update()
  void updateFromCamera(Vector2 cameraWorldPos) {
    // Move opposite camera, scaled by parallax factor
    position = baseOffset - cameraWorldPos * parallaxFactor;
  }
}
