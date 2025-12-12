import '../entities/unit.dart';

class MovementSystem {
  void update(double dt, Iterable<Unit> units) {
    for (final unit in units) {
      if (unit.targetX == null || unit.targetY == null) continue;

      final dx = unit.targetX! - unit.x;
      final dy = unit.targetY! - unit.y;
      final dist = (dx * dx + dy * dy).sqrt();

      if (dist < 1) {
        unit.x = unit.targetX!;
        unit.y = unit.targetY!;
        unit.targetX = null;
        unit.targetY = null;
        continue;
      }

      final step = unit.speed * dt;
      unit.x += (dx / dist) * step;
      unit.y += (dy / dist) * step;
    }
  }
}
