import 'package:flame/camera.dart';

/// Camera configuration only (no input).
class CameraController {
  final CameraComponent camera;

  CameraController(this.camera);

  void configure() {
    camera.viewfinder.zoom = 1.0;
    camera.viewfinder.anchor = Anchor.center;
  }
}
