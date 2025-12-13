import '../core/world_state.dart';

class CombatSystem {
  void update(WorldState world, double dt) {
    // tick cooldowns
    for (final id in world.entities) {
      world.attacks[id]?.tick(dt);
    }

    for (final attacker in world.entities) {
      final atk = world.attacks[attacker];
      final atkPos = world.positions[attacker];
      final atkTeam = world.teams[attacker];
      final atkOrder = world.targetOrders[attacker];

      if (atk == null || atkPos == null || atkTeam == null || atkOrder == null) continue;
      if (!atk.ready) continue;

      final targetId = atkOrder.targetId;
      if (targetId == null) continue;
      if (!world.exists(targetId)) {
        atkOrder.targetId = null;
        continue;
      }

      final tgtPos = world.positions[targetId];
      final tgtTeam = world.teams[targetId];
      final tgtHp = world.health[targetId];

      if (tgtPos == null || tgtTeam == null || tgtHp == null) continue;

      // no friendly fire (for now)
      if (tgtTeam.id == atkTeam.id) {
        atkOrder.targetId = null;
        continue;
      }

      final dx = tgtPos.x - atkPos.x;
      final dy = tgtPos.y - atkPos.y;
      final distSq = dx * dx + dy * dy;

      if (distSq <= atk.range * atk.range) {
        tgtHp.damage(atk.damage);
        atk.trigger();
      }
    }
  }
}
