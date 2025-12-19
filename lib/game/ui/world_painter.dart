import 'dart:ui';
import 'package:flutter/material.dart';

import '../core/world_state.dart';
import '../core/entity_id.dart';

class WorldPainter extends CustomPainter {
  final WorldState world;
  final dynamic cam; // placeholder, not used yet
  final Set<EntityId> selected;

  WorldPainter({
    required this.world,
    required this.cam,
    required this.selected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Offset.zero & size, bg);

    for (final id in world.entities) {
      final pos = world.positions[id]?.value;
      final hp = world.health[id];
      if (pos == null || hp == null) continue;

      final isSelected = selected.contains(id);

      final unitPaint = Paint()
        ..color = isSelected
            ? const Color(0xFF42D392)
            : const Color(0xFF60A5FA);

      // unit body
      canvas.drawCircle(
        Offset(pos.x, pos.y),
        10,
        unitPaint,
      );

      // health bar (NO const Size)
      final barW = 24.0;
      final barH = 4.0;
      final frac = hp.current / hp.max;

      final topLeft = Offset(pos.x - barW / 2, pos.y - 18);

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
