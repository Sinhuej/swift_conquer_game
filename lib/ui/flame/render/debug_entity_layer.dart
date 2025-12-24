import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'interpolation_buffer.dart';

/// Debug-only render layer that draws interpolated entities as circles.
/// Purely visual. Keep for dev; remove or flag later.
class DebugEntityLayer extends PositionComponent {
  final InterpolationBuffer buffer;
  final Paint _paint = Paint()..color = const Color(0xFFEFEFEF);

  DebugEntityLayer({required this.buffer});

  @override
  void render(Canvas canvas) {
    // Render in world space (camera already handles transform)
    for (final id in buffer.currentIds) {
      final pose = buffer.pose(id);
      if (pose == null) continue;
      final p = pose.pos;
      canvas.drawCircle(Offset(p.x, p.y), 4.0, _paint);
    }
  }
}
