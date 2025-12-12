import '../core/world_state.dart';
import 'game_system.dart';

class CombatSystem extends GameSystem {
  @override
  void update(WorldState world, double dt) {
    for (final attack in world.pendingAttacks) {
      final target = world.entities[attack.targetId];
      if (target == null || target.health == null) continue;

      target.health!.damage(attack.damage);
    }

    world.pendingAttacks.clear();
  }
}
