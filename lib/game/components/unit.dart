import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

class UnitComponent extends PositionComponent {
  UnitComponent({required Vector2 start}) {
    position = start.clone();
    anchor = Anchor.center;
    size = Vector2.all(28);
  }

  Vector2? _target;
  final double speed = 220; // px/sec

  void moveTo(Vector2 worldPoint) {
    _target = worldPoint.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);
    final t = _target;
    if (t == null) return;

    final toTarget = t - position;
    final dist = toTarget.length;
    if (dist < 2) {
      _target = null;
      return;
    }

    final dir = toTarget / dist;
    final step = speed * dt;
    position += dir * math.min(step, dist);
  }

  @override
  void render(Canvas canvas) {
    // simple “unit” circle
    final paint = Paint()..color = const Color(0xFF3F51B5);
    canvas.drawCircle(Offset.zero, 14, paint);
  }
}
