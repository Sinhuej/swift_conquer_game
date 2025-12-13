import '../core/world_state.dart';
import '../components/position.dart';

class MovementSystem {
  // units per second
  final double speed = 80.0;

  void update(WorldState world, double dt) {
    for (final id in world.entities) {
      final order = world.moveOrders[id];
      final pos = world.positions[id];
      if (order == null || pos == null) continue;

      final target = order.target;
      if (target == null) continue;

      final dx = target.x - pos.x;
      final dy = target.y - pos.y;
      final distSq = dx * dx + dy * dy;
      if (distSq < 4) {
        // arrived
        order.target = null;
        continue;
      }

      final dist = _sqrt(distSq);
      final step = speed * dt;
      final nx = dx / dist;
      final ny = dy / dist;
      final move = step < dist ? step : dist;

      pos.x += nx * move;
      pos.y += ny * move;
    }
  }

  double _sqrt(double v) {
    var x = v;
    for (int i = 0; i < 10; i++) {
      if (x == 0) return 0;
      x = 0.5 * (x + v / x);
    }
    return x;
  }
}
