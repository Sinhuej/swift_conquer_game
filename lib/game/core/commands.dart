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
