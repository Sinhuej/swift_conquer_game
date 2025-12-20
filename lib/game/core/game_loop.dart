import '../systems/system_manager.dart';
import 'simulation_controller.dart';
import 'time_controller.dart';
import 'world_state.dart';

class GameLoop {
  final WorldState world = WorldState();
  final SystemManager systems = SystemManager();

  /// External time controls (pause/speed scaling at the "frame" level)
  final TimeController time = TimeController();

  /// Deterministic simulation spine (fixed step, tick counter, events, rng)
  final SimulationController sim = SimulationController(seed: 1337);

  /// Call from UI/runner with real delta time.
  /// This will:
  /// - apply TimeController scaling
  /// - accumulate to fixed steps
  /// - run N fixed updates
  void tick(double realDt) {
    final scaledFrameDt = time.apply(realDt);
    if (scaledFrameDt <= 0) return;

    if (sim.paused) return;

    final scaled = sim.scaleDt(scaledFrameDt);
    final steps = sim.fixed.accumulate(scaled);
    if (steps <= 0) return;

    for (int i = 0; i < steps; i++) {
      systems.update(sim.fixed.step, world);
      sim.tickState.advance(sim.fixed.step);
    }
  }
}
