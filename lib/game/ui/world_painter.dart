import 'dart:ui';
import 'package:flutter/material.dart';

import '../core/world_state.dart';
import '../core/entity_id.dart';
import '../math/vec2.dart';
import 'camera.dart';

class WorldPainter extends CustomPainter {
  final WorldState world;
  final Camera cam;
  final Set<EntityId> selected;

  WorldPainter({required this.world, required this.cam, required this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0B1220));

    _drawGrid(canvas, size);
    _drawUnits(canvas);
    _drawHud(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF1B2433)
      ..strokeWidth = 1;

    const step = 40.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  void _drawUnits(Canvas canvas) {
    for (final id in world.entities) {
      final pos = world.positions[id]?.value;
      final hp = world.health[id];
      final team = world.teams[id]?.id ?? 0;
      if (pos == null || hp == null) continue;

      final s = cam.worldToScreen(pos);
      final center = Offset(s.x, s.y);

      final radius = 14.0;

      // team color
      final fill = Paint()
        ..color = (team == 1) ? const Color(0xFF42D392) : const Color(0xFFE35D6A);

      // outline
      final outline = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected.contains(id) ? 4 : 2
        ..color = selected.contains(id) ? const Color(0xFFFFD166) : const Color(0xFF94A3B8);

      canvas.drawCircle(center, radius, fill);
      canvas.drawCircle(center, radius, outline);

      // HP bar (FIX: no invalid const Size(barW, barH))
      final barW = 40.0;
      final barH = 6.0;
      final topLeft = Offset(center.dx - barW / 2, center.dy - radius - 14);

      final frac = (hp.max == 0) ? 0.0 : (hp.current / hp.max).clamp(0.0, 1.0);

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

  void _drawHud(Canvas canvas, Size size) {
    final text = "Entities: ${world.entityCount}  |  Selected: ${selected.length}  |  Zoom: ${cam.zoom.toStringAsFixed(2)}";
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 14, color: Color(0xFFE6EDF3)),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 24);

    tp.paint(canvas, const Offset(12, 12));
  }

  @override
  bool shouldRepaint(covariant WorldPainter oldDelegate) {
    return true; // simplest for now
  }
}

extension _Clamp on double {
  double clamp(double lo, double hi) => this < lo ? lo : (this > hi ? hi : this);
}
