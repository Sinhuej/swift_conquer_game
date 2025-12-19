import '../core/world_state.dart';
import '../math/vec2.dart';
import 'game_system.dart';

class MovementSystem implements GameSystem {
  @override
  void update(double dt, WorldState world) {
    for (final id in world.entities) {
      final pos = world.positions[id];
      final order = world.moveOrders[id];
      if (pos == null || order?.target == null) continue;

      final Vec2 p = pos.value;
      final Vec2 t = order!.target!;
      final Vec2 to = t - p;

      final dist = to.length;
      if (dist < 1) {
        order.target = null;
        continue;
      }

      const speed = 100.0;
      final step = speed * dt;
      final next = (step >= dist)
          ? t
          : p + to.normalized() * step;

      pos.value = next;
    }
  }
}
