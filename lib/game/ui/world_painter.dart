import 'dart:ui';
import '../core/world_state.dart';

class WorldPainter {
  final WorldState world;

  WorldPainter(this.world);

  void render(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawUnits(canvas);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0E1116);
    canvas.drawRect(Offset.zero & size, paint);
  }

  void _drawUnits(Canvas canvas) {
    for (final id in world.entities) {
      final pos = world.positions[id];
      final hp = world.health[id];
      if (pos == null || hp == null) continue;

      // Unit body
      final bodyPaint = Paint()..color = const Color(0xFF3B82F6);
      canvas.drawCircle(
        Offset(pos.value.x, pos.value.y),
        10,
        bodyPaint,
      );

      // Health bar
      _drawHealthBar(canvas, pos.value.x, pos.value.y - 18, hp.current, hp.max);
    }
  }

  void _drawHealthBar(Canvas canvas, double x, double y, int current, int max) {
    const double barW = 24;
    const double barH = 4;

    final frac = (max <= 0) ? 0.0 : (current / max).clamp(0.0, 1.0);
    final topLeft = Offset(x - barW / 2, y);

    // Background (NO const Size!)
    canvas.drawRect(
      topLeft & Size(barW, barH),
      Paint()..color = const Color(0xFF2A3440),
    );

    // Foreground
    canvas.drawRect(
      topLeft & Size(barW * frac, barH),
      Paint()..color = const Color(0xFF42D392),
    );
  }
}
