import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import 'components/unit.dart';

class SwiftConquerGame extends FlameGame with TapDetector {
  late final UnitComponent unit;

  @override
  Color backgroundColor() => const Color(0xFFF6F1FF);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Center camera on a “map” area
    camera.viewfinder.anchor = Anchor.center;

    // Add a simple grid-like background using a Component paint approach
    add(_GridBackground());

    // Spawn one unit
    unit = UnitComponent(start: Vector2(180, 320));
    add(unit);

    // Start camera following the unit a bit (loose follow)
    camera.follow(unit);
  }

  @override
  void onTapDown(TapDownInfo info) {
    final world = info.eventPosition.game; // world coords
    unit.moveTo(world);
    super.onTapDown(info);
  }
}

class _GridBackground extends Component {
  final Paint _line = Paint()
    ..color = const Color(0x22000000)
    ..strokeWidth = 1;

  @override
  void render(Canvas canvas) {
    // Draw a grid in screen space (good enough for v1)
    const step = 40.0;
    final size = (findGame() as FlameGame).size;

    for (double x = 0; x <= size.x; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), _line);
    }
    for (double y = 0; y <= size.y; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), _line);
    }
  }
}
