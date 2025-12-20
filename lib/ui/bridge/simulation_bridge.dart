import '../../game/core/game_loop.dart';
import '../adapters/world_to_render_adapter.dart';
import '../render_models/render_world.dart';

/// UI-safe bridge between Flame and the frozen simulation engine.
/// Owns the simulation loop and exposes snapshots only.
class SimulationBridge {
  final GameLoop _loop = GameLoop();

  /// Advance simulation time (dt in seconds).
  void tick(double dt) {
    _loop.tick(dt);
  }

  /// Read-only snapshot for rendering.
  RenderWorld snapshot() {
    return WorldToRenderAdapter.fromWorld(_loop.world);
  }
}
