import '../simulation/simulation_step.dart';
import '../core/world_state.dart';

class DeathCleanupStep implements SimulationStep {
  @override
  void run(WorldState world) {
    final dead = world.entities
        .where((id) => world.health[id]?.current <= 0)
        .toList();

    for (final id in dead) {
      world.destroy(id);
    }
  }
}
