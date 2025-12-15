import '../core/world_state.dart';
import '../math/vec2.dart';
import '../components/move_order.dart';
import '../components/position.dart';
import 'game_system.dart';

/// Phase 22: MovementSystem (very small + deterministic)
class MovementSystem implements GameSystem {
  // tiles/sec (tune later)
  final double speed = 120.0;

  @override
  void update(WorldState world, double dt) {
    for (final id in world.entities) {
      final pos = world.positions[id];
      final order = world.moveOrders[id];
      if (pos == null || order == null) continue;

      final Vec2 p = pos.value;
      final Vec2 t = order.target;

      final Vec2 to = t - p;
      final double dist = to.length;
      if (dist < 0.5) {
        // reached target
        world.moveOrders.remove(id);
        continue;
      }

      final Vec2 dir = to.normalized();
      final double step = speed * dt;
      final Vec2 next = dist <= step ? t : (p + dir * step);

      world.positions[id] = Position(next);
    }
  }
}
