import 'package:flame/game.dart';

import '../bridge/simulation_bridge.dart';
import '../render_models/render_world.dart';
import 'camera_controller.dart';
import 'unit_component.dart';

/// Flame game rendering real simulation snapshots.
/// NO input handling here yet (intentionally).
class SwiftConquerFlameGame extends FlameGame {

  late final CameraController cameraController;
  late final SimulationBridge sim;

  RenderWorld? _renderWorld;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    cameraController = CameraController(camera);
    cameraController.configure();
    sim = SimulationBridge();
  }

  @override
  void update(double dt) {
    super.update(dt);
    sim.tick(dt);
    _applySnapshot(sim.snapshot());
  }

  void _applySnapshot(RenderWorld world) {
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
