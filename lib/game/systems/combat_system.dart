import '../core/world_state.dart';

class CombatSystem {
  final WorldState world;
  CombatSystem(this.world);

  void update(double dt) {
    // tick cooldowns
    for (final u in world.aliveUnits()) {
      if (u.attackTimer > 0) {
        u.attackTimer -= dt;
        if (u.attackTimer < 0) u.attackTimer = 0;
      }
    }

    // acquire targets (simple: nearest enemy in range)
    for (final u in world.aliveUnits()) {
      if (u.targetUnitId != null) {
        final t = world.units[u.targetUnitId!];
        if (t == null || !t.isAlive || t.team == u.team) {
          u.targetUnitId = null;
        }
      }

      if (u.targetUnitId == null) {
        int? bestId;
        double bestD2 = u.attackRange * u.attackRange;

        for (final other in world.aliveUnits()) {
          if (other.team == u.team) continue;
          final dx = other.pos.x - u.pos.x;
          final dy = other.pos.y - u.pos.y;
          final d2 = dx * dx + dy * dy;
          if (d2 <= bestD2) {
            bestD2 = d2;
            bestId = other.id;
          }
        }

        u.targetUnitId = bestId;
      }
    }

    // attack
    for (final u in world.aliveUnits()) {
      final tid = u.targetUnitId;
      if (tid == null) continue;
      final t = world.units[tid];
      if (t == null || !t.isAlive) continue;

      final dx = t.pos.x - u.pos.x;
      final dy = t.pos.y - u.pos.y;
      final d2 = dx * dx + dy * dy;
      final r2 = u.attackRange * u.attackRange;

      if (d2 <= r2 && u.attackTimer <= 0) {
        t.hp -= u.attackDamage;
        u.attackTimer = u.attackCooldown;

        // if target died, clear target
        if (!t.isAlive) {
          u.targetUnitId = null;
        }
      }
    }

    world.cullDead();
  }
}
