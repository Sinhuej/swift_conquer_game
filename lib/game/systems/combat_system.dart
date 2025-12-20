import '../core/world_state.dart';
import 'game_system.dart';

class CombatSystem implements GameSystem {
  @override
  void update(double dt, WorldState world) {
    // Placeholder: Phase 40+ real combat
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
