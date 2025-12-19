import 'package:flutter/material.dart';
import '../core/world_state.dart';
import '../core/entity_id.dart';

class WorldPainter extends CustomPainter {
  final WorldState world;
  final Set<EntityId> selected;

  WorldPainter({
    required this.world,
    required this.selected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF2A3440);

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );

    // Draw units
    for (final id in world.entities) {
      final pos = world.positions[id]?.value;
      if (pos == null) continue;

      final isSelected = selected.contains(id);

      final unitPaint = Paint()
        ..color = isSelected
            ? const Color(0xFF42D392)
            : const Color(0xFFE6EDF3);

      canvas.drawCircle(
        Offset(pos.x, pos.y),
        8,
        unitPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WorldPainter oldDelegate) {
    return true;
  }
}
