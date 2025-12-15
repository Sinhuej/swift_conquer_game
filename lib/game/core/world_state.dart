import '../components/position.dart';
import '../components/health.dart';
import '../components/target_order.dart';
import '../models/entity_id.dart';
import '../math/vec2.dart';

class WorldState {
  int _nextId = 0;

  final Map<EntityId, Position> positions = {};
  final Map<EntityId, Health> healths = {};
  final Map<EntityId, TargetOrder> targetOrders = {};

  EntityId spawnUnit(Vec2 at) {
    final id = EntityId(_nextId++);
    positions[id] = Position(at.x, at.y);
    healths[id] = Health(100);
    return id;
  }

  bool exists(EntityId id) {
    return positions.containsKey(id);
  }

  void remove(EntityId id) {
    positions.remove(id);
    healths.remove(id);
    targetOrders.remove(id);
  }
}
