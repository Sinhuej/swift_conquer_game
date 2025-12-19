import 'dart:ui';
import 'package:flutter/material.dart' show Colors;
import '../core/world_state.dart';
import '../core/entity_id.dart';

/// Minimal camera placeholder so we compile even if cam is a simple object.
/// If you already have a real Camera class elsewhere, delete this and import yours.
class CameraView {
  final double ox;
  final double oy;
  final double zoom;
  const CameraView({this.ox = 0, this.oy = 0, this.zoom = 1});
}

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

    // Draw units as simple circles + HP bars
    for (final id in world.entities) {
      final posComp = world.positions[id];
      final hp = world.health[id];
      if (posComp == null || hp == null) continue;

      final pos = posComp.value;
      final isSel = selected.contains(id);

      final x = (pos.x + cam.ox) * cam.zoom;
      final y = (pos.y + cam.oy) * cam.zoom;

      // Unit body
      final body = Paint()..color = isSel ? const Color(0xFF42D392) : const Color(0xFF93C5FD);
      canvas.drawCircle(Offset(x, y), 10 * cam.zoom, body);

      // HP bar
      final barW = 38.0 * cam.zoom;
      final barH = 6.0 * cam.zoom;
      final topLeft = Offset(x - barW / 2, y - 18 * cam.zoom);

      final back = Paint()..color = const Color(0xFF2A3440);
      final fill = Paint()..color = const Color(0xFF42D392);

      // IMPORTANT: Size(...) must NOT be const because barW/barH are variables
      canvas.drawRect(topLeft & Size(barW, barH), back);

      final frac = (hp.max <= 0) ? 0.0 : (hp.current / hp.max).clamp(0.0, 1.0);
      canvas.drawRect(topLeft & Size(barW * frac, barH), fill);
    }

    // HUD text (simple)
    final paragraphStyle = ParagraphStyle(fontSize: 14);
    final textStyle = TextStyle(color: const Color(0xFFE6EDF3));
    final pb = ParagraphBuilder(paragraphStyle)..pushStyle(textStyle)..addText("Units: ${world.entityCount}");
    final p = pb.build()..layout(const ParagraphConstraints(width: 300));
    canvas.drawParagraph(p, const Offset(12, 10));
  }

  @override
  bool shouldRepaint(covariant WorldPainter oldDelegate) {
    return true;
  }
}
