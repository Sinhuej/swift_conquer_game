import 'package:flutter/material.dart';
import '../../integration/engine_bridge.dart';

class DebugOverlay {
  final EngineBridge engine;
  DebugOverlay(this.engine);
  bool enabled = true;

  void render(Canvas canvas) {
    final tp = TextPainter(
      text: const TextSpan(
        text: "Debug",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, const Offset(10, 10));
  }
}
