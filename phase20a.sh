#!/usr/bin/env bash
set -euo pipefail

echo "=== Phase 20A: ECS combat + world state expansion ==="

mkdir -p lib/game/core
mkdir -p lib/game/components
mkdir -p lib/game/systems

cat > lib/game/core/entity_id.dart <<'DART'
typedef EntityId = int;
DART

cat > lib/game/components/position.dart <<'DART'
class Position {
  double x;
  double y;
  Position(this.x, this.y);

  double distanceTo(Position other) {
    final dx = other.x - x;
    final dy = other.y - y;
    return (dx * dx + dy * dy).sqrt();
  }
}

extension _Sqrt on double {
  double sqrt() => Math.sqrt(this);
}

class Math {
  static double sqrt(double v) => v <= 0 ? 0 : _sqrtNewton(v);
  static double _sqrtNewton(double v) {
    var x = v;
    for (int i = 0; i < 12; i++) {
      if (x == 0) return 0;
      x = 0.5 * (x + v / x);
    }
    return x;
  }
}
DART

cat > lib/game/components/team.dart <<'DART'
class Team {
  final int id; // 1 = player, 2 = enemy, etc.
  const Team(this.id);
}
DART

cat > lib/game/components/health.dart <<'DART'
class Health {
  int hp;
  final int maxHp;
  Health(this.hp, this.maxHp);

  bool get isDead => hp <= 0;
  void damage(int amount) {
    hp -= amount;
    if (hp < 0) hp = 0;
  }
}
DART

cat > lib/game/components/attack.dart <<'DART'
class Attack {
  final int damage;
  final double range;
  final double cooldown; // seconds per hit
  double _cdLeft = 0;

  Attack({
    required this.damage,
    required this.range,
    required this.cooldown,
  });

  bool get ready => _cdLeft <= 0;

  void tick(double dt) {
    if (_cdLeft > 0) _cdLeft -= dt;
    if (_cdLeft < 0) _cdLeft = 0;
  }

  void trigger() {
    _cdLeft = cooldown;
  }
}
DART

cat > lib/game/components/move_order.dart <<'DART'
import 'position.dart';

class MoveOrder {
  Position? target;
  MoveOrder({this.target});
}
DART

cat > lib/game/components/target_order.dart <<'DART'
import '../core/entity_id.dart';

class TargetOrder {
  EntityId? targetId;
  TargetOrder({this.targetId});
}
DART

cat > lib/game/core/world_state.dart <<'DART'
import 'entity_id.dart';
import '../components/position.dart';
import '../components/team.dart';
import '../components/health.dart';
import '../components/attack.dart';
import '../components/move_order.dart';
import '../components/target_order.dart';

class WorldState {
  int _nextId = 1;

  final Map<EntityId, Position> positions = {};
  final Map<EntityId, Team> teams = {};
  final Map<EntityId, Health> health = {};
  final Map<EntityId, Attack> attacks = {};
  final Map<EntityId, MoveOrder> moveOrders = {};
  final Map<EntityId, TargetOrder> targetOrders = {};

  EntityId spawnUnit({
    required double x,
    required double y,
    required int teamId,
    required int hp,
    required int damage,
    required double range,
    required double cooldown,
  }) {
    final id = _nextId++;
    positions[id] = Position(x, y);
    teams[id] = Team(teamId);
    health[id] = Health(hp, hp);
    attacks[id] = Attack(damage: damage, range: range, cooldown: cooldown);
    moveOrders[id] = MoveOrder();
    targetOrders[id] = TargetOrder();
    return id;
  }

  void despawn(EntityId id) {
    positions.remove(id);
    teams.remove(id);
    health.remove(id);
    attacks.remove(id);
    moveOrders.remove(id);
    targetOrders.remove(id);
  }

  bool exists(EntityId id) => positions.containsKey(id);

  Iterable<EntityId> get entities => positions.keys;

  void cleanupDead() {
    final dead = <EntityId>[];
    health.forEach((id, h) {
      if (h.isDead) dead.add(id);
    });
    for (final id in dead) {
      despawn(id);
    }
  }
}
DART

cat > lib/game/systems/game_system.dart <<'DART'
import '../core/world_state.dart';

abstract class GameSystem {
  void update(WorldState world, double dt);
}
DART

cat > lib/game/systems/system_manager.dart <<'DART'
import '../core/world_state.dart';
import 'game_system.dart';
import 'movement_system.dart';
import 'combat_system.dart';

class SystemManager {
  final List<GameSystem> _systems = [
    MovementSystem(),
    CombatSystem(),
  ];

  void update(WorldState world, double dt) {
    for (final s in _systems) {
      s.update(world, dt);
    }
    world.cleanupDead();
  }
}
DART

cat > lib/game/systems/movement_system.dart <<'DART'
import '../core/world_state.dart';
import '../components/position.dart';

class MovementSystem {
  // units per second
  final double speed = 80.0;

  void update(WorldState world, double dt) {
    for (final id in world.entities) {
      final order = world.moveOrders[id];
      final pos = world.positions[id];
      if (order == null || pos == null) continue;

      final target = order.target;
      if (target == null) continue;

      final dx = target.x - pos.x;
      final dy = target.y - pos.y;
      final distSq = dx * dx + dy * dy;
      if (distSq < 4) {
        // arrived
        order.target = null;
        continue;
      }

      final dist = _sqrt(distSq);
      final step = speed * dt;
      final nx = dx / dist;
      final ny = dy / dist;
      final move = step < dist ? step : dist;

      pos.x += nx * move;
      pos.y += ny * move;
    }
  }

  double _sqrt(double v) {
    var x = v;
    for (int i = 0; i < 10; i++) {
      if (x == 0) return 0;
      x = 0.5 * (x + v / x);
    }
    return x;
  }
}
DART

cat > lib/game/systems/combat_system.dart <<'DART'
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
DART

# Ensure game_loop exists + wired
mkdir -p lib/game/core
cat > lib/game/core/game_loop.dart <<'DART'
import 'world_state.dart';
import '../systems/system_manager.dart';

class GameLoop {
  final WorldState world = WorldState();
  final SystemManager systems = SystemManager();

  void update(double dt) {
    systems.update(world, dt);
  }
}
DART

echo "=== Phase 20A complete ==="
