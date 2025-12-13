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
