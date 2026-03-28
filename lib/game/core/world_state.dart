import '../buildings/building_type.dart';
import '../components/health.dart';
import '../components/move_order.dart';
import '../components/position.dart';
import '../components/target_order.dart';
import '../components/team.dart';
import '../math/vec2.dart';
import 'entity_id.dart';

class WorldState {
  int _nextId = 1;

  int get nextIdForSave => _nextId;
  void setNextIdForSave(int value) {
    if (value < 1) {
      throw ArgumentError('nextId must be >= 1');
    }
    _nextId = value;
  }

  final Set<EntityId> entities = <EntityId>{};

  final Map<EntityId, Position> positions = {};
  final Map<EntityId, Health> health = {};
  final Map<EntityId, Team> teams = {};
  final Map<EntityId, MoveOrder> moveOrders = {};
  final Map<EntityId, TargetOrder> targetOrders = {};
  final Map<EntityId, String> unitKinds = {};

  final Set<EntityId> buildingIds = <EntityId>{};
  final Map<EntityId, BuildingType> buildingTypes = {};
  final Map<EntityId, Vec2> buildingPositions = {};
  final Map<EntityId, Team> buildingTeams = {};

  int get entityCount => entities.length + buildingIds.length;

  bool exists(EntityId id) => entities.contains(id) || buildingIds.contains(id);

  EntityId spawnUnit(
    Vec2 start, {
    int teamId = 1,
    int hp = 20,
    String kind = 'tank',
  }) {
    final id = EntityId(_nextId++);
    entities.add(id);
    positions[id] = Position(start);
    health[id] = Health(current: hp, max: hp);
    teams[id] = Team(teamId);
    moveOrders[id] = MoveOrder();
    targetOrders[id] = TargetOrder();
    unitKinds[id] = kind;
    return id;
  }

  EntityId spawnMobileHqCenter(
    Vec2 start, {
    int teamId = 1,
    int hp = 35,
  }) {
    return spawnUnit(
      start,
      teamId: teamId,
      hp: hp,
      kind: 'mobile_hq_center',
    );
  }

  bool isMobileHqCenter(EntityId id) => unitKinds[id] == 'mobile_hq_center';

  EntityId spawnBuilding(
    BuildingType type,
    Vec2 center, {
    int teamId = 1,
  }) {
    final id = EntityId(_nextId++);
    buildingIds.add(id);
    buildingTypes[id] = type;
    buildingPositions[id] = center;
    buildingTeams[id] = Team(teamId);
    return id;
  }

  void destroy(EntityId id) {
    entities.remove(id);
    positions.remove(id);
    health.remove(id);
    teams.remove(id);
    moveOrders.remove(id);
    targetOrders.remove(id);
    unitKinds.remove(id);

    buildingIds.remove(id);
    buildingTypes.remove(id);
    buildingPositions.remove(id);
    buildingTeams.remove(id);
  }
}
