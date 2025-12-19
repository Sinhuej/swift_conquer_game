import 'package:flutter/material.dart';
import '../camera/camera_state.dart';
import '../core/entity_id.dart';
import '../core/world_state.dart';

class WorldPainter extends CustomPainter {
  final WorldState world;
  final CameraState cam;
  final EntityId? selected;

  WorldPainter({
    required this.world,
    required this.cam,
    required this.selected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bg = Paint()..color = const Color(0xFF0B0F14);
    canvas.drawRect(Offset.zero & size, bg);

    // Grid (light)
    final grid = Paint()
      ..color = const Color(0xFF1B2430)
      ..strokeWidth = 1;
    const step = 80.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // Units
    for (final id in world.entities) {
      final p = world.positions[id]?.value;
      final hp = world.health[id];
      final team = world.teams[id]?.id ?? 0;
      if (p == null || hp == null) continue;

      final sp = cam.worldToScreen(p);
      final center = Offset(sp.x, sp.y);

      final isSel = (selected != null && selected == id);

      final paint = Paint()
        ..color = team == 1 ? const Color(0xFF4AA3FF) : const Color(0xFFFF5A5A);

      canvas.drawCircle(center, isSel ? 14 : 12, paint);

      // HP bar
      final max = hp.max <= 0 ? 1 : hp.max;
      final frac = (hp.current / max).clamp(0.0, 1.0);
      final barW = 28.0;
      final barH = 4.0;
      final topLeft = Offset(center.dx - barW / 2, center.dy - 22);

      canvas.drawRect(topLeft & const Size(barW, barH), Paint()..color = const Color(0xFF2A3440));
      canvas.drawRect(topLeft & Size(barW * frac, barH), Paint()..color = const Color(0xFF42D392));
    }
  }

  @override
  bool shouldRepaint(covariant WorldPainter oldDelegate) {
    return true; // simple: always repaint while ticking
  }
}
