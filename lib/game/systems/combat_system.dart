import '../core/world_state.dart';
import 'game_system.dart';

class CombatSystem implements GameSystem {
  @override
  void update(double dt, WorldState world) {
    // placeholder: later we’ll consume AttackEvents etc.
    // For now: delete dead entities
    final dead = <dynamic>[];
    for (final id in world.entities) {
      final hp = world.health[id];
      if (hp != null && hp.current <= 0) dead.add(id);
    }
    for (final id in dead) {
      world.destroy(id);
    }
  }
}
