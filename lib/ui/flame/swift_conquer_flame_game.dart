import 'package:flame/game.dart';

import '../bridge/simulation_bridge.dart';
import '../render_models/render_world.dart';
import 'camera_controller.dart';
import 'unit_component.dart';

/// Flame game rendering real simulation snapshots.
/// No engine mutation, read-only snapshots only.
class SwiftConquerFlameGame extends FlameGame {
  late final CameraController cameraController;
  late final SimulationBridge sim;

  RenderWorld? _renderWorld;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    cameraController = CameraController(camera);
    cameraController.configure();
    cameraController.attachInput(this);

    sim = SimulationBridge();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Step simulation
    sim.tick(dt);

    // Pull snapshot
    final world = sim.snapshot();
    _updateRenderWorld(world);
  }

  void _updateRenderWorld(RenderWorld world) {
    _renderWorld = world;

    // Clear existing units
    final existing = children.whereType<UnitComponent>().toList();
    for (final c in existing) {
      c.removeFromParent();
    }

    // Render new snapshot
    for (final u in world.units) {
      add(UnitComponent(u));
    }
  }

  RenderWorld? get renderWorld => _renderWorld;
}
