import '../core/world_state.dart';
import '../math/vec2.dart';
import 'game_system.dart';

class MovementSystem implements GameSystem {
  @override
  void update(double dt, WorldState world) {
    for (final id in world.entities) {
      final pos = world.positions[id];
      final order = world.moveOrders[id];
      if (pos == null || order == null) continue;

      final target = order.target;
      if (target == null) continue;

      final Vec2 p = pos.value;
      final Vec2 to = target - p;

      final dist = to.length;
      if (dist < 1.0) {
        order.target = null;
        continue;
      }

      const speed = 120.0; // units/sec
      final step = speed * dt;

      final dir = to.normalized();
      final next = (step >= dist) ? target : (p + dir * step);

      pos.value = next;
    }
  }
}
