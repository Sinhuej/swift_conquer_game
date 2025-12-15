import '../core/entity_id.dart';
import '../components/position.dart';
import '../components/move_order.dart';
import '../components/health.dart';
import '../components/team.dart';
import '../components/target_order.dart';

/// Minimal ECS-ish world state.
/// Stores component maps keyed by EntityId.
class WorldState {
  int _nextId = 1;

  final Map<EntityId, Position> positions = {};
  final Map<EntityId, MoveOrder> moveOrders = {};
  final Map<EntityId, Health> health = {};
  final Map<EntityId, Team> teams = {};
  final Map<EntityId, TargetOrder> targets = {};

  EntityId spawnEntity() {
    final id = EntityId(_nextId++);
    return id;
  }

  void destroyEntity(EntityId id) {
    positions.remove(id);
    moveOrders.remove(id);
    health.remove(id);
    teams.remove(id);
    targets.remove(id);
  }

  Iterable<EntityId> get entities sync* {
    // union of keys (simple + fast enough for now)
    final set = <EntityId>{};
    set.addAll(positions.keys);
    set.addAll(moveOrders.keys);
    set.addAll(health.keys);
    set.addAll(teams.keys);
    set.addAll(targets.keys);
    yield* set;
  }
}
