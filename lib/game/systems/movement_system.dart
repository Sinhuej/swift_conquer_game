import 'game_system.dart';
import '../core/world_state.dart';
import '../math/vec2.dart';
import '../components/position.dart';
import '../components/target_order.dart';

class MovementSystem extends GameSystem {
  @override
  void update(double dt, WorldState world) {
    world.targetOrders.forEach((id, order) {
      final pos = world.positions[id];
      if (pos == null) return;

      final Vec2 p = pos.vec;
      final Vec2 to = order.target - p;
      final double dist = to.length;

      if (dist < 0.01) return;

      final Vec2 step = to.normalized() * (dt * 50);
      pos.x += step.x;
      pos.y += step.y;
    });
  }
}
