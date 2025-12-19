import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import '../../core/game_loop.dart';

class WorldRenderer extends Component with HasGameRef<FlameGame> {
  final GameLoop loop;

  WorldRenderer({required this.loop});

  final Paint _p1 = Paint()..style = PaintingStyle.fill;
  final Paint _p2 = Paint()..style = PaintingStyle.fill;
  final Paint _hud = Paint()..style = PaintingStyle.fill;

  @override
  void render(Canvas canvas) {
    // background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y),
      Paint()..color = const Color(0xFF101418),
    );

    // simple grid
    final grid = Paint()
      ..color = const Color(0xFF1F2A33)
      ..strokeWidth = 1;
    const step = 40.0;
    for (double x = 0; x < gameRef.size.x; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, gameRef.size.y), grid);
    }
    for (double y = 0; y < gameRef.size.y; y += step) {
      canvas.drawLine(Offset(0, y), Offset(gameRef.size.x, y), grid);
    }

    // units
    for (final id in loop.world.entities) {
      final pos = loop.world.positions[id]?.value;
      final team = loop.world.teams[id]?.id ?? 1;
      final hp = loop.world.health[id];

      if (pos == null) continue;
      final paint = (team == 1) ? (_p1..color = const Color(0xFF4CC9F0)) : (_p2..color = const Color(0xFFF72585));
      canvas.drawCircle(Offset(pos.x, pos.y), 14, paint);

      // tiny HP bar
      if (hp != null) {
        final max = hp.max <= 0 ? 1 : hp.max;
        final pct = (hp.current / max).clamp(0.0, 1.0);
        final w = 34.0;
        final h = 6.0;
        final left = pos.x - (w / 2);
        final top = pos.y - 26;
        canvas.drawRect(Rect.fromLTWH(left, top, w, h), Paint()..color = const Color(0xFF2B2B2B));
        canvas.drawRect(Rect.fromLTWH(left, top, w * pct, h), Paint()..color = const Color(0xFF6EEB83));
      }
    }

    // HUD text
    final paragraphStyle = const ParagraphStyle(fontSize: 14);
    final textStyle = const TextStyle(color: Color(0xFFE6EDF3));
    final pb = ParagraphBuilder(paragraphStyle)..pushStyle(textStyle);
    pb.addText("SwiftConquer • Entities: ${loop.world.entityCount}\nTap: move A  |  Long-press: spawn");
    final p = pb.build()..layout(const ParagraphConstraints(width: 520));
    canvas.drawParagraph(p, const Offset(12, 12));
  }
}
