#!/usr/bin/env bash
set -euo pipefail

echo "=== Phase 20B: orders + selection helpers ==="

mkdir -p lib/game/systems
mkdir -p lib/game/core

cat > lib/game/core/commands.dart <<'DART'
import 'entity_id.dart';
import 'world_state.dart';
import '../components/position.dart';

class Commands {
  final WorldState world;
  Commands(this.world);

  void issueMove(EntityId id, Position target) {
    final o = world.moveOrders[id];
    if (o == null) return;
    o.target = target;
    // moving clears target for now
    world.targetOrders[id]?.targetId = null;
  }

  void issueAttack(EntityId id, EntityId targetId) {
    if (!world.exists(id) || !world.exists(targetId)) return;
    world.targetOrders[id]?.targetId = targetId;
    // attacking clears move target for now
    world.moveOrders[id]?.target = null;
  }
}
DART

cat > lib/game/systems/selection_system.dart <<'DART'
import '../core/entity_id.dart';
import '../core/world_state.dart';

class SelectionSystem {
  EntityId? selected;

  void select(WorldState world, EntityId? id) {
    if (id == null) {
      selected = null;
      return;
    }
    if (!world.exists(id)) return;
    selected = id;
  }
}
DART

echo "=== Phase 20B complete ==="
