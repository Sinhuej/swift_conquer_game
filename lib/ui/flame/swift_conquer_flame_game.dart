import 'package:flame/game.dart';
import 'package:flame/input.dart';

import '../bridge/simulation_bridge.dart';
import '../render_models/render_world.dart';
import 'camera_controller.dart';
import 'unit_component.dart';

/// Flame game rendering real simulation snapshots.
/// Input (pan/zoom) handled directly by the Game (Flame-correct).
class SwiftConquerFlameGame extends FlameGame
    with PanDetector, ScaleDetector {

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

    // Step simulation
    sim.tick(dt);

    // Pull snapshot
    _updateRenderWorld(sim.snapshot());
  }

  // ------------------------
  // Input handling (Flame 1.34 correct)
  // ------------------------

  @override
  void onPanUpdate(DragUpdateInfo info) {
    camera.viewfinder.position -= info.delta.global;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    if (info.scale == 1.0) return;
    camera.viewfinder.zoom =
        (camera.viewfinder.zoom * info.scale).clamp(0.5, 3.0);
  }

  // ------------------------
  // Rendering
  // ------------------------

  void _updateRenderWorld(RenderWorld world) {
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
