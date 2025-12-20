import 'package:flame/camera.dart';
import 'package:flame/components.dart';

/// Camera configuration only.
class CameraController {
  final CameraComponent camera;

  CameraController(this.camera);

  void configure() {
    camera.viewfinder.zoom = 1.0;
    camera.viewfinder.anchor = Anchor.center;
  }
}
