import 'dart:ui';
import '../core/world_state.dart';

class WorldPainter extends CustomPainter {
  final WorldState world;
  final dynamic cam;
  final Set<int> selected;

  WorldPainter({
    required this.world,
    this.cam,
    this.selected = const {},
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Minimal safe render for GREEN build
    final paint = Paint()..color = const Color(0xFF1E1E1E);
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
