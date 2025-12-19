import 'package:flutter/material.dart';
import '../core/world_state.dart';
import '../core/entity_id.dart';

class WorldPainter extends CustomPainter {
  final WorldState world;
  final dynamic cam;
  final EntityId? selected;

  WorldPainter({
    required this.world,
    this.cam,
    this.selected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF2A3440);

    // background
    canvas.drawRect(Offset.zero & size, paint);

    // draw units
    for (final id in world.entities) {
      final pos = world.positions[id]?.value;
      if (pos == null) continue;

      final isSelected = (id == selected);

      final unitPaint = Paint()
        ..color = isSelected
            ? const Color(0xFF42D392)
            : const Color(0xFF9DA5B4);

      canvas.drawCircle(
        Offset(pos.x, pos.y),
        isSelected ? 8 : 6,
        unitPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
