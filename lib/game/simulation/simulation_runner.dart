import '../core/world_state.dart';
import 'intent_queue.dart';
import 'movement_step.dart';
import '../combat/combat_step.dart';
import '../combat/death_cleanup_step.dart';
import '../victory/victory_system.dart';

import '../../sim_ext/observability/sim_inspector.dart';

class SimulationRunner {
  final IntentQueue intents = IntentQueue();

  int? step(
    WorldState world, {
    required int tick,
    SimInspector? inspector,
  }) {
    final currentTick = tick;

    inspector?.log(
      currentTick,
      'SIM',
      'STEP_START',
    );

    final drained = intents.drain();

    MovementStep(drained).run(world);
    CombatStep(drained).run(world);
    DeathCleanupStep().run(world);

    final victory = VictorySystem.check(world);

    inspector?.log(
      currentTick,
      'SIM',
      'STEP_END',
      payload: {
        'victory': victory,
      },
    );

    return victory;
  }
}
