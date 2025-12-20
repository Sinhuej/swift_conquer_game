import '../systems/system_manager.dart';
import 'simulation_controller.dart';
import 'time_controller.dart';
import 'world_state.dart';

class GameLoop {
  final WorldState world = WorldState();
  final SystemManager systems = SystemManager();
  final TimeController time = TimeController();

  late final SimulationController sim = SimulationController(
    world: world,
    systems: systems,
    seed: 1,
    fixedStep: 1 / 60,
  );

  /// Called by UI/driver. Internally advances deterministic fixed ticks.
  void tick(double dt) {
    final scaledDt = time.apply(dt);
    if (scaledDt <= 0) return;
    sim.step(scaledDt);
  }
}
