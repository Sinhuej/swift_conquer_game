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

  EntityId spawnUnit(Vec2 start, {int teamId = 1, int hp = 25}) {
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
