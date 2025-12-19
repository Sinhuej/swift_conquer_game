import 'dart:ui';
import '../../core/world_state.dart';

class WorldRenderer {
  final WorldState world;

  WorldRenderer(this.world);

  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF4CAF50);

    for (final id in world.entities) {
      final pos = world.positions[id];
      if (pos == null) continue;

      canvas.drawCircle(
        Offset(pos.value.x, pos.value.y),
        8,
        paint,
      );
    }

    final paragraphStyle = ParagraphStyle(fontSize: 14);
    final textStyle = TextStyle(color: const Color(0xFFE6EDF3));

    final pb = ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText('Units: ${world.entityCount}');

    final paragraph = pb.build()
      ..layout(const ParagraphConstraints(width: 200));

    canvas.drawParagraph(paragraph, const Offset(10, 10));
  }
}
