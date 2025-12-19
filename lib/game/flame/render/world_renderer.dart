import 'dart:ui';
import 'package:flame/components.dart';
import '../../core/game_loop.dart';
import '../../math/vec2.dart';

class WorldRenderer extends Component {
  final GameLoop loop;

  WorldRenderer(this.loop);

  @override
  void render(Canvas canvas) {
    final size = (findGame() as FlameGame).size;

    // grid
    const grid = 40.0;
    final paintGrid = Paint()
      ..color = const Color(0x22FFFFFF)
      ..strokeWidth = 1;

    for (double x = 0; x < size.x; x += grid) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), paintGrid);
    }
    for (double y = 0; y < size.y; y += grid) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), paintGrid);
    }

    // units
    final selected = loop.systems.selection.selected;
    for (final id in loop.world.entities) {
      final p = loop.world.positions[id]?.value ?? const Vec2(0, 0);
      final team = loop.world.teams[id]?.id ?? 0;
      final hp = loop.world.health[id];

      final isSel = (selected != null && selected == id);

      final body = Paint()
        ..color = (team == 1)
            ? const Color(0xFF4FC3F7)
            : const Color(0xFFFF8A80);

      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = isSel ? const Color(0xFFFFFF00) : const Color(0x66FFFFFF);

      canvas.drawCircle(Offset(p.x, p.y), 16, body);
      canvas.drawCircle(Offset(p.x, p.y), 20, ring);

      if (hp != null) {
        final pct = hp.max <= 0 ? 0.0 : (hp.current / hp.max).clamp(0.0, 1.0);
        final barW = 34.0;
        final barH = 5.0;
        final bg = Rect.fromLTWH(p.x - barW / 2, p.y - 30, barW, barH);
        final fg = Rect.fromLTWH(p.x - barW / 2, p.y - 30, barW * pct, barH);
        canvas.drawRect(bg, Paint()..color = const Color(0x66000000));
        canvas.drawRect(fg, Paint()..color = const Color(0xFF00E676));
      }
    }
  }
}
