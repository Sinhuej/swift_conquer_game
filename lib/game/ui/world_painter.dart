import 'package:flutter/material.dart';
import '../core/entity_id.dart';
import '../core/world_state.dart';
import '../math/vec2.dart';
import 'camera_view.dart';

class WorldPainter extends CustomPainter {
  final WorldState world;
  final CameraView cam;
  final Set<EntityId> selected;

  WorldPainter({
    required this.world,
    required this.cam,
    required this.selected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bg = Paint()..color = const Color(0xFF0B1220);
    canvas.drawRect(Offset.zero & size, bg);

    _drawGrid(canvas, size);
    _drawUnits(canvas);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF182233)
      ..strokeWidth = 1;

    const spacing = 64.0;

    // Screen-space grid (simple + fast)
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawUnits(Canvas canvas) {
    for (final id in world.entities) {
      final pos = world.positions[id];
      if (pos == null) continue;

      final hp = world.health[id];
      final team = world.teams[id];

      final Vec2 screen = cam.worldToScreen(pos.value);
      final center = Offset(screen.x, screen.y);

      // unit body
      final body = Paint()
        ..color = (team?.id == 2)
            ? const Color(0xFFEF4444)
            : const Color(0xFF60A5FA);

      canvas.drawCircle(center, 14, body);

      // selection ring
      if (selected.contains(id)) {
        final ring = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFFEAB308);
        canvas.drawCircle(center, 18, ring);
      }

      // HP bar
      if (hp != null && hp.max > 0) {
        final frac = (hp.current / hp.max).clamp(0.0, 1.0);
        const barW = 40.0;
        const barH = 6.0;

        final topLeft = Offset(center.dx - barW / 2, center.dy - 26);

        canvas.drawRect(
          topLeft & const Size(barW, barH),
          Paint()..color = const Color(0xFF2A3440),
        );

        canvas.drawRect(
          topLeft & Size(barW * frac, barH),
          Paint()..color = const Color(0xFF42D392),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant WorldPainter oldDelegate) {
    return true; // Phase 32-40: simple always repaint
  }
}
