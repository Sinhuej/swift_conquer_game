import '../core/world_state.dart';
import 'game_system.dart';

class CombatSystem extends GameSystem {
  final WorldState world;

  CombatSystem(this.world);

  void attack(int attackerId, int targetId, {int damage = 10}) {
    final target = world.units[targetId];
    if (target == null || !target.isAlive) return;

    target.hp -= damage;
    if (target.hp < 0) {
      target.hp = 0;
    }
  }

  @override
  void update(double dt) {
    // Phase 20A: attacks triggered externally
  }
}
