#!/usr/bin/env bash
set -euo pipefail

echo "=== SwiftConquer Phase 32–40 (HEADLESS GREEN LOCK) ==="

mkdir -p lib/game/core lib/game/systems lib/game/components lib/game/math lib/screens

# ----------------------------
# math: Vec2
# ----------------------------
cat > lib/game/math/vec2.dart <<'DART'
class Vec2 {
  final double x;
  final double y;

  const Vec2(this.x, this.y);

  Vec2 operator +(Vec2 o) => Vec2(x + o.x, y + o.y);
  Vec2 operator -(Vec2 o) => Vec2(x - o.x, y - o.y);
  Vec2 operator *(double s) => Vec2(x * s, y * s);

  double get length => _sqrt(x * x + y * y);

  Vec2 normalized() {
    final len = length;
    if (len == 0) return const Vec2(0, 0);
    return Vec2(x / len, y / len);
  }

  static double _sqrt(double v) {
    // Newton-Raphson
    if (v <= 0) return 0;
    double x = v;
    for (int i = 0; i < 12; i++) {
      x = 0.5 * (x + v / x);
    }
    return x;
  }
}
DART

# ----------------------------
# core: EntityId
# ----------------------------
cat > lib/game/core/entity_id.dart <<'DART'
class EntityId {
  final int value;
  const EntityId(this.value);

  @override
  bool operator ==(Object other) => other is EntityId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
DART

# ----------------------------
# components
# ----------------------------
cat > lib/game/components/position.dart <<'DART'
import '../math/vec2.dart';

class Position {
  Vec2 value;
  Position(this.value);
}
DART

cat > lib/game/components/health.dart <<'DART'
class Health {
  int current;
  int max;
  Health({required this.current, required this.max});
}
DART

cat > lib/game/components/team.dart <<'DART'
class Team {
  final int id;
  const Team(this.id);
}
DART

cat > lib/game/components/move_order.dart <<'DART'
import '../math/vec2.dart';

class MoveOrder {
  Vec2? target;
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

# ----------------------------
# core: WorldState
# ----------------------------
cat > lib/game/core/world_state.dart <<'DART'
import '../components/health.dart';
import '../components/move_order.dart';
import '../components/position.dart';
import '../components/target_order.dart';
import '../components/team.dart';
import '../math/vec2.dart';
import 'entity_id.dart';

class WorldState {
  int _nextId = 1;

  final Set<EntityId> entities = <EntityId>{};

  final Map<EntityId, Position> positions = {};
  final Map<EntityId, Health> health = {};
  final Map<EntityId, Team> teams = {};
  final Map<EntityId, MoveOrder> moveOrders = {};
  final Map<EntityId, TargetOrder> targetOrders = {};

  int get entityCount => entities.length;

  bool exists(EntityId id) => entities.contains(id);

  EntityId spawnUnit(Vec2 start, {int teamId = 1, int hp = 20}) {
    final id = EntityId(_nextId++);
    entities.add(id);
    positions[id] = Position(start);
    health[id] = Health(current: hp, max: hp);
    teams[id] = Team(teamId);
    moveOrders[id] = MoveOrder();
    targetOrders[id] = TargetOrder();
    return id;
  }

  void destroy(EntityId id) {
    entities.remove(id);
    positions.remove(id);
    health.remove(id);
    teams.remove(id);
    moveOrders.remove(id);
    targetOrders.remove(id);
  }
}
DART

# ----------------------------
# systems: interface + manager
# ----------------------------
cat > lib/game/systems/game_system.dart <<'DART'
import '../core/world_state.dart';

abstract class GameSystem {
  void update(double dt, WorldState world);
}
DART

cat > lib/game/systems/selection_system.dart <<'DART'
import '../core/world_state.dart';
import 'game_system.dart';

class SelectionSystem implements GameSystem {
  // Placeholder for Phase 40+ selection state
  @override
  void update(double dt, WorldState world) {
    // no-op
  }
}
DART

cat > lib/game/systems/movement_system.dart <<'DART'
import '../core/world_state.dart';
import '../math/vec2.dart';
import 'game_system.dart';

class MovementSystem implements GameSystem {
  static const double speed = 120.0; // units/sec

  @override
  void update(double dt, WorldState world) {
    for (final id in world.entities) {
      final pos = world.positions[id];
      final order = world.moveOrders[id];
      if (pos == null || order == null) continue;

      final target = order.target;
      if (target == null) continue;

      final Vec2 p = pos.value;
      final Vec2 delta = target - p;

      final dist = delta.length;
      if (dist < 1.0) {
        order.target = null;
        continue;
      }

      final step = speed * dt;
      final dir = delta.normalized();
      final next = (step >= dist) ? target : (p + dir * step);
      pos.value = next;
    }
  }
}
DART

cat > lib/game/systems/combat_system.dart <<'DART'
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
DART

cat > lib/game/systems/system_manager.dart <<'DART'
import '../core/world_state.dart';
import 'combat_system.dart';
import 'game_system.dart';
import 'movement_system.dart';
import 'selection_system.dart';

class SystemManager {
  final List<GameSystem> _systems = <GameSystem>[
    SelectionSystem(),
    MovementSystem(),
    CombatSystem(),
  ];

  void update(double dt, WorldState world) {
    for (final s in _systems) {
      s.update(dt, world);
    }
  }
}
DART

# ----------------------------
# core: GameLoop
# ----------------------------
cat > lib/game/core/game_loop.dart <<'DART'
import '../systems/system_manager.dart';
import 'world_state.dart';

class GameLoop {
  final WorldState world = WorldState();
  final SystemManager systems = SystemManager();

  void tick(double dt) {
    systems.update(dt, world);
  }
}
DART

# ----------------------------
# screen: TestScreen (pure Flutter UI, no Flame)
# ----------------------------
cat > lib/screens/test_screen.dart <<'DART'
import 'dart:async';
import 'package:flutter/material.dart';
import '../game/core/game_loop.dart';
import '../game/core/entity_id.dart';
import '../game/math/vec2.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final GameLoop loop = GameLoop();
  Timer? _timer;

  EntityId? a;
  EntityId? b;

  @override
  void initState() {
    super.initState();

    final world = loop.world;
    a = world.spawnUnit(const Vec2(120, 260), teamId: 1, hp: 25);
    b = world.spawnUnit(const Vec2(320, 260), teamId: 2, hp: 25);

    // prove movement ticks:
    world.moveOrders[a!]!.target = const Vec2(520, 260);

    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      loop.tick(1 / 60);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _unitCard(EntityId id) {
    final world = loop.world;
    final pos = world.positions[id]!.value;
    final hp = world.health[id]!;
    final team = world.teams[id]!.id;
    final tgt = world.targetOrders[id]?.targetId;

    return Card(
      child: ListTile(
        title: Text("Unit ${id.value} (Team $team)"),
        subtitle: Text(
          "HP ${hp.current}/${hp.max}  |  Pos (${pos.x.toStringAsFixed(1)}, ${pos.y.toStringAsFixed(1)})"
          "  |  Target ${tgt?.value ?? '-'}",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final world = loop.world;

    return Scaffold(
      appBar: AppBar(title: const Text("SwiftConquer • Phase 32–40")),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text("Entities alive: ${world.entityCount}"),
          const SizedBox(height: 10),
          if (a != null && world.exists(a!)) _unitCard(a!),
          if (b != null && world.exists(b!)) _unitCard(b!),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              if (a == null || !world.exists(a!)) return;
              world.moveOrders[a!]!.target = const Vec2(520, 140);
            },
            child: const Text("Move Unit A"),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              if (b == null || !world.exists(b!)) return;
              world.health[b!]!.current = 0; // prove despawn
            },
            child: const Text("Kill Unit B"),
          ),
        ],
      ),
    );
  }
}
DART

echo "✅ Phase 32–40 written."
echo "Next:"
echo "  git add lib && git commit -m \"Phase 32–40: headless core green lock\" && git push"
