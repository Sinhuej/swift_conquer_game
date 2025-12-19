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

    for (final id in world.entities) {
      final pos = world.positions[id];
      if (pos == null) continue;

      final isSelected = selected.contains(id);
      paint.color = isSelected
          ? const Color(0xFF42D392)
          : const Color(0xFF6B7280);

      canvas.drawCircle(
        Offset(pos.value.x, pos.value.y),
        10,
        paint,
      );
    }

    // Health bars (NON-CONST Size)
    for (final id in world.entities) {
      final pos = world.positions[id];
      final hp = world.health[id];
      if (pos == null || hp == null) continue;

      final barW = 20.0;
      final barH = 4.0;
      final frac = hp.current / hp.max;

      final topLeft = Offset(pos.value.x - barW / 2, pos.value.y - 18);

      canvas.drawRect(
        topLeft & Size(barW, barH),
        Paint()..color = const Color(0xFF2A3440),
      );

      canvas.drawRect(
        topLeft & Size(barW * frac, barH),
        Paint()..color = const Color(0xFF42D392),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
