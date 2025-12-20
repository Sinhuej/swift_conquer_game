import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../input/camera_input.dart';
import '../input/selection_controller.dart';

class CameraController {
  final CameraComponent camera;

  CameraController(this.camera);

  void configure() {
    camera.viewfinder.zoom = 1.0;
    camera.viewfinder.anchor = Anchor.center;
  }

  void attachInput(FlameGame game) {
    game.add(CameraInput());
    game.add(SelectionController());
  }
}
