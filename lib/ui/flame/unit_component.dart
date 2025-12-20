import 'dart:ui';
import 'package:flame/components.dart';
import '../render_models/render_unit.dart';

class UnitComponent extends PositionComponent {
  final RenderUnit unit;
  bool selected = false;

  UnitComponent(this.unit) {
    position = Vector2(unit.x, unit.y);
    size = Vector2.all(14);
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = unit.teamId == 1
          ? const Color(0xFF00AAFF)
          : const Color(0xFFFF5555);

    canvas.drawCircle(Offset.zero, size.x / 2, paint);

    if (selected) {
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFFFFF00);
      canvas.drawCircle(Offset.zero, size.x / 2 + 3, ring);
    }
  }
}
