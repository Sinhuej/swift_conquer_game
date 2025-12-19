import 'package:flutter/material.dart';
import '../core/world_state.dart';

class WorldPainter extends CustomPainter {
  final WorldState world;
  final dynamic cam;       // keep dynamic for now (Phase 80+ tighten)
  final Set<dynamic> selected;

  WorldPainter({
    required this.world,
    required this.cam,
    required this.selected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // TEMP: minimal safe render so build stays GREEN
    final paint = Paint()..color = const Color(0xFF1E1E1E);
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
