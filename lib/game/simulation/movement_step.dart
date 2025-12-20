import 'simulation_step.dart';
import 'unit_intent.dart';
import '../core/world_state.dart';

class MovementStep implements SimulationStep {
  final List<UnitIntent> intents;
  MovementStep(this.intents);

  @override
  void run(WorldState world) {
    for (final intent in intents) {
      if (intent is! MoveIntent) continue;
      final pos = world.positions[intent.actor];
      if (pos == null) continue;
      pos.value = intent.target;
    }
  }
}
