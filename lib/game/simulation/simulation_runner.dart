import '../core/world_state.dart';
import 'intent_queue.dart';
import 'movement_step.dart';
import '../combat/combat_step.dart';
import '../combat/death_cleanup_step.dart';
import '../victory/victory_system.dart';

class SimulationRunner {
  final IntentQueue intents = IntentQueue();

  int? step(WorldState world) {
    final drained = intents.drain();

    MovementStep(drained).run(world);
    CombatStep(drained).run(world);
    DeathCleanupStep().run(world);

    return VictorySystem.check(world);
  }
}
