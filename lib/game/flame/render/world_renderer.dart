import 'dart:ui';

class WorldRenderer {
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF1E1E1E);

    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 5000, 5000),
      paint,
    );

    final paragraphStyle = ParagraphStyle(fontSize: 14);
    final textStyle = TextStyle(color: const Color(0xFFE6EDF3));

    final builder = ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText('SwiftConquer World');

    final paragraph = builder.build()
      ..layout(const ParagraphConstraints(width: 300));

    canvas.drawParagraph(paragraph, const Offset(20, 20));
  }
}
