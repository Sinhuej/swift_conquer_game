import 'dart:ui';
import 'package:flame/components.dart';

/// Simple soft shadow drawn beneath an entity.
/// PURE visual — no collision, no logic.
class ShadowComponent extends PositionComponent {
  final double radius;
  final Paint _paint;

  ShadowComponent({
    required this.radius,
    double opacity = 0.25,
  }) : _paint = Paint()
          ..color = Color.fromRGBO(0, 0, 0, opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

  @override
  void render(Canvas canvas) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 2,
        height: radius,
      ),
      _paint,
    );
  }
}
