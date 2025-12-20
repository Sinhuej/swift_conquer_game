import 'world_state.dart';
import 'death_cleanup.dart';
import 'victory_system.dart';

class SimulationStepResult {
  final int? winningTeam;
  const SimulationStepResult(this.winningTeam);
}

class SimulationStep {
  static SimulationStepResult run(WorldState world) {
    DeathCleanup.run(world);
    final winner = VictorySystem.check(world);
    return SimulationStepResult(winner);
  }
}
