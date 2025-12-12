import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class UnitComponent extends PositionComponent with TapCallbacks {
  UnitComponent({
    required Vector2 start,
    this.radius = 14,
  }) : _target = start.clone() {
    position = start.clone();
    anchor = Anchor.center;
    size = Vector2.all(radius * 2);
  }

  final double radius;
  final Paint _paint = Paint()..color = const Color(0xFF6C63FF);
  Vector2 _target;

  // Units per second
  double speed = 220;

  void moveTo(Vector2 worldPoint) {
    _target = worldPoint.clone();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(radius, radius), radius, _paint);
    // little center dot for direction readability
    canvas.drawCircle(Offset(radius, radius), 3, Paint()..color = Colors.white);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final toTarget = _target - position;
    final dist = toTarget.length;
    if (dist < 1) return;

    final step = speed * dt;
    final dir = toTarget / math.max(dist, 0.0001);
    position += dir * math.min(step, dist);
  }
}
