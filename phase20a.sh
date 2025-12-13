#!/usr/bin/env bash
set -euo pipefail

echo "=== Phase 20A: Combat ECS + WorldState expansion ==="

mkdir -p lib/game/core lib/game/systems lib/game/components lib/game/math

# ---------- math helpers ----------
cat > lib/game/math/vec2.dart <<'DART'
class Vec2 {
  double x;
  double y;
  Vec2(this.x, this.y);

  Vec2 copy() => Vec2(x, y);

  Vec2 operator +(Vec2 other) => Vec2(x + other.x, y + other.y);
  Vec2 operator -(Vec2 other) => Vec2(x - other.x, y - other.y);
  Vec2 operator *(double s) => Vec2(x * s, y * s);

  double get length2 => x * x + y * y;
}
DART

# ---------- core: world state ----------
cat > lib/game/core/world_state.dart <<'DART'
import '../math/vec2.dart';

class UnitState {
  final int id;
  int team; // 0=player, 1=enemy (for now)
  Vec2 pos;
  Vec2 vel;

  double radius;
  double hp;
  double maxHp;

  double attackDamage;
  double attackRange;
  double attackCooldown; // seconds
  double attackTimer;    // time until can attack again

  int? targetUnitId;

  UnitState({
    required this.id,
    required this.team,
    required this.pos,
    Vec2? vel,
    this.radius = 14,
    this.hp = 100,
    this.maxHp = 100,
    this.attackDamage = 10,
    this.attackRange = 90,
    this.attackCooldown = 0.8,
    this.attackTimer = 0,
    this.targetUnitId,
  }) : vel = vel ?? Vec2(0, 0);

  bool get isAlive => hp > 0;
}

class WorldState {
  int _nextId = 1;

  final Map<int, UnitState> units = {};
  int? selectedUnitId;

  // Simple bounds for now (world coords)
  double worldW = 1200;
  double worldH = 800;

  int spawnUnit({
    required int team,
    required Vec2 pos,
    double hp = 100,
    double dmg = 10,
    double range = 90,
    double cd = 0.8,
  }) {
    final id = _nextId++;
    units[id] = UnitState(
      id: id,
      team: team,
      pos: pos,
      hp: hp,
      maxHp: hp,
      attackDamage: dmg,
      attackRange: range,
      attackCooldown: cd,
    );
    return id;
  }

  Iterable<UnitState> aliveUnits() => units.values.where((u) => u.isAlive);

  void cullDead() {
    units.removeWhere((_, u) => !u.isAlive);
    if (selectedUnitId != null && !units.containsKey(selectedUnitId)) {
      selectedUnitId = null;
    }
  }
}
DART

# ---------- systems: selection ----------
cat > lib/game/systems/selection_system.dart <<'DART'
import '../core/world_state.dart';
import '../math/vec2.dart';

class SelectionSystem {
  final WorldState world;
  SelectionSystem(this.world);

  /// Select nearest alive unit within hit radius.
  void tapSelect(Vec2 p, {double maxDist = 28}) {
    int? bestId;
    double bestD2 = maxDist * maxDist;

    for (final u in world.aliveUnits()) {
      final dx = u.pos.x - p.x;
      final dy = u.pos.y - p.y;
      final d2 = dx * dx + dy * dy;
      if (d2 <= bestD2) {
        bestD2 = d2;
        bestId = u.id;
      }
    }

    world.selectedUnitId = bestId;
  }

  /// Move selected unit by setting velocity toward point (very simple).
  void tapMove(Vec2 p, {double speed = 220}) {
    final id = world.selectedUnitId;
    if (id == null) return;
    final u = world.units[id];
    if (u == null || !u.isAlive) return;

    final dx = p.x - u.pos.x;
    final dy = p.y - u.pos.y;
    final len2 = dx * dx + dy * dy;
    if (len2 < 1) {
      u.vel = Vec2(0, 0);
      return;
    }
    final invLen = 1 / (len2).sqrtApprox();
    u.vel = Vec2(dx * invLen * speed, dy * invLen * speed);

    // clear target if you move
    u.targetUnitId = null;
  }
}

extension _SqrtApprox on double {
  double sqrtApprox() {
    // Fast-enough for now: use Dart's sqrt via exponent
    // (keeps this file dependency-free).
    return this <= 0 ? 0 : pow05(this);
  }

  double pow05(double v) => v == 0 ? 0 : v.toString() == 'NaN' ? 0 : _pow(v);
  double _pow(double v) {
    // fallback – using double exponent is fine in Dart VM/JIT
    return v == 0 ? 0 : v ** 0.5;
  }
}
DART

# ---------- systems: movement ----------
cat > lib/game/systems/movement_system.dart <<'DART'
import '../core/world_state.dart';

class MovementSystem {
  final WorldState world;
  MovementSystem(this.world);

  void update(double dt) {
    for (final u in world.aliveUnits()) {
      u.pos.x += u.vel.x * dt;
      u.pos.y += u.vel.y * dt;

      // clamp to world bounds
      if (u.pos.x < 0) u.pos.x = 0;
      if (u.pos.y < 0) u.pos.y = 0;
      if (u.pos.x > world.worldW) u.pos.x = world.worldW;
      if (u.pos.y > world.worldH) u.pos.y = world.worldH;
    }
  }
}
DART

# ---------- systems: combat ----------
cat > lib/game/systems/combat_system.dart <<'DART'
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
DART

# ---------- systems: system manager ----------
cat > lib/game/systems/system_manager.dart <<'DART'
import '../core/world_state.dart';
import 'movement_system.dart';
import 'combat_system.dart';

class SystemManager {
  final WorldState world;

  late final MovementSystem movement;
  late final CombatSystem combat;

  SystemManager(this.world) {
    movement = MovementSystem(world);
    combat = CombatSystem(world);
  }

  void update(double dt) {
    movement.update(dt);
    combat.update(dt);
  }
}
DART

# ---------- core: game loop ----------
cat > lib/game/core/game_loop.dart <<'DART'
import 'world_state.dart';
import '../systems/system_manager.dart';

class GameLoop {
  final WorldState world;
  late final SystemManager systems;

  GameLoop(this.world) {
    systems = SystemManager(world);
  }

  void update(double dt) {
    systems.update(dt);
  }
}
DART

echo "✅ Phase 20A files written."
echo "Next:"
echo "  git add lib/game phase20a.sh"
echo "  git commit -m \"Phase 20A: ECS combat + world state\""
echo "  git push"
