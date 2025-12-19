import '../core/world_state.dart';
import '../core/entity_id.dart';

class CombatResolver {
  static void attack(WorldState world, EntityId a, EntityId b) {
    if (!world.exists(a) || !world.exists(b)) return;
    final hp = world.health[b];
    if (hp == null) return;
    hp.current -= 5;
    if (hp.current <= 0) {
      world.destroy(b);
    }
  }
}
