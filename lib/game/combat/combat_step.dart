import '../simulation/simulation_step.dart';
import '../simulation/unit_intent.dart';
import '../core/world_state.dart';

class CombatStep implements SimulationStep {
  final List<UnitIntent> intents;
  CombatStep(this.intents);

  @override
  void run(WorldState world) {
    for (final intent in intents) {
      if (intent is! AttackIntent) continue;
      final hp = world.health[intent.target];
      if (hp == null) continue;
      hp.current -= 5;
    }
  }
}
