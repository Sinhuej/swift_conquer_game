import '../core/world_state.dart';
import '../math/vec2.dart';

class SelectionSystem {
  final WorldState world;
  SelectionSystem(this.world);

  /// Select nearest alive unit within hit radius.
  void tapSelect(Vec2 p, {double maxDist = 28}) {
    int? bestId;
    double bestD2 = maxDist * maxDist;

    for (final u in world.aliveUnits()) {
      final dx = u.pos.x - p.x;
      final dy = u.pos.y - p.y;
      final d2 = dx * dx + dy * dy;
      if (d2 <= bestD2) {
        bestD2 = d2;
        bestId = u.id;
      }
    }

    world.selectedUnitId = bestId;
  }

  /// Move selected unit by setting velocity toward point (very simple).
  void tapMove(Vec2 p, {double speed = 220}) {
    final id = world.selectedUnitId;
    if (id == null) return;
    final u = world.units[id];
    if (u == null || !u.isAlive) return;

    final dx = p.x - u.pos.x;
    final dy = p.y - u.pos.y;
    final len2 = dx * dx + dy * dy;
    if (len2 < 1) {
      u.vel = Vec2(0, 0);
      return;
    }
    final invLen = 1 / (len2).sqrtApprox();
    u.vel = Vec2(dx * invLen * speed, dy * invLen * speed);

    // clear target if you move
    u.targetUnitId = null;
  }
}

extension _SqrtApprox on double {
  double sqrtApprox() {
    // Fast-enough for now: use Dart's sqrt via exponent
    // (keeps this file dependency-free).
    return this <= 0 ? 0 : pow05(this);
  }

  double pow05(double v) => v == 0 ? 0 : v.toString() == 'NaN' ? 0 : _pow(v);
  double _pow(double v) {
    // fallback – using double exponent is fine in Dart VM/JIT
    return v == 0 ? 0 : v ** 0.5;
  }
}
