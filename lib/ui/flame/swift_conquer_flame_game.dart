import 'package:flame/game.dart';

import '../dev/dev_command_sink.dart';
import '../dev/fake_world_provider.dart';
import '../input/player_input.dart';
import '../render_models/render_world.dart';
import 'camera_controller.dart';
import 'unit_component.dart';

class SwiftConquerFlameGame extends FlameGame {
  late final CameraController cameraController;
  RenderWorld? _renderWorld;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    cameraController = CameraController(camera);
    cameraController.configure();
    cameraController.attachInput(this);

    add(PlayerInput(DevCommandSink()));

    // A) Render a fake world immediately
    updateRenderWorld(FakeWorldProvider.build());
  }

  void updateRenderWorld(RenderWorld world) {
    _renderWorld = world;
    final existing = children.whereType<UnitComponent>().toList();
    for (final c in existing) {
      c.removeFromParent();
    }
    for (final u in world.units) {
      add(UnitComponent(u));
    }
  }

  RenderWorld? get renderWorld => _renderWorld;
}
