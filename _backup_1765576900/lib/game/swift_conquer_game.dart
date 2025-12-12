import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';

import 'components/unit.dart';

class SwiftConquerGame extends FlameGame with TapCallbacks {
  late UnitComponent unit;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewfinder.anchor = Anchor.center;

    add(_GridBackground());
    unit = UnitComponent(start: Vector2(180, 320));
    add(unit);
    camera.follow(unit);
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Move the unit to where the player tapped (world coords).
    final world = event.canvasPosition;
    unit.moveTo(world);
  }
}

class _GridBackground extends Component with HasGameRef<FlameGame> {
  @override
  void render(Canvas canvas) {
    final s = gameRef.size;

    final paint = Paint()
      ..color = const Color(0x22000000)
      ..strokeWidth = 1;

    const step = 32.0;

    for (double x = 0; x < s.x; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, s.y), paint);
    }
    for (double y = 0; y < s.y; y += step) {
      canvas.drawLine(Offset(0, y), Offset(s.x, y), paint);
    }
  }
}
