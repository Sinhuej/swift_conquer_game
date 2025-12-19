import '../core/entity_id.dart';
import '../core/world_state.dart';
import '../math/vec2.dart';
import 'game_system.dart';

class CombatSystem implements GameSystem {
  static const double range = 70.0;
  static const double dps = 8.0; // damage per second

  @override
  void update(double dt, WorldState world) {
    final toKill = <EntityId>[];

    for (final id in world.entities) {
      final targetId = world.targetOrders[id]?.targetId;
      if (targetId == null) continue;
      if (!world.exists(targetId)) {
        world.targetOrders[id]?.targetId = null;
        continue;
      }

      final a = world.positions[id]?.value;
      final b = world.positions[targetId]?.value;
      if (a == null || b == null) continue;

      final dist = (b - a).length;
      if (dist > range) continue;

      final hp = world.health[targetId];
      if (hp == null) continue;

      hp.current -= (dps * dt).round();
      if (hp.current <= 0) {
        toKill.add(targetId);
      }
    }

    for (final id in toKill) {
      if (world.exists(id)) {
        world.destroy(id);
      }
    }
  }
}
