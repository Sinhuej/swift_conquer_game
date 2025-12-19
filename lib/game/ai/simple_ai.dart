import '../core/world_state.dart';
import '../math/vec2.dart';

class SimpleAI {
  void issueOrders(WorldState world) {
    for (final id in world.entities) {
      final team = world.teams[id];
      if (team == null || team.id != 2) continue;

      final order = world.moveOrders[id];
      if (order != null && order.target == null) {
        order.target = const Vec2(400, 300);
      }
    }
  }
}
