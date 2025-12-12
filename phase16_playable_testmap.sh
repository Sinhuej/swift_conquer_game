#!/usr/bin/env bash
set -euo pipefail

echo "=== SwiftConquer • Phase 16: Playable Test Map (Flame) ==="

# 1) Create folders
mkdir -p lib/game/components
mkdir -p lib/screens

# 2) Ensure pubspec has Flame + lints (safe append/patch style)
# NOTE: This avoids breaking your current working build.
if ! grep -q "^dependencies:" pubspec.yaml; then
  echo "ERROR: pubspec.yaml missing 'dependencies:'"
  exit 1
fi

# Add flame if missing
if ! grep -q "^[[:space:]]*flame:" pubspec.yaml; then
  echo "Adding flame dependency..."
  awk '
    BEGIN{added=0}
    {print}
    /^dependencies:/{dep=1}
    dep && !added && /^  flutter:/{print "  flame: ^1.34.0"; added=1}
  ' pubspec.yaml > pubspec.yaml.tmp && mv pubspec.yaml.tmp pubspec.yaml
fi

# Add flutter_lints if missing
if ! grep -q "^dev_dependencies:" pubspec.yaml; then
  echo -e "\ndev_dependencies:\n  flutter_test:\n    sdk: flutter\n  flutter_lints: ^5.0.0" >> pubspec.yaml
else
  if ! grep -q "^[[:space:]]*flutter_lints:" pubspec.yaml; then
    awk '
      BEGIN{done=0}
      {print}
      /^dev_dependencies:/{dev=1}
      dev && !done && /^  flutter_test:/{print "  flutter_lints: ^5.0.0"; done=1}
    ' pubspec.yaml > pubspec.yaml.tmp && mv pubspec.yaml.tmp pubspec.yaml
  fi
fi

# 3) analysis_options.yaml (simple + stable)
cat > analysis_options.yaml <<'YAML'
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    avoid_print: false
YAML

# 4) Flame unit component (a simple circle unit that can move)
cat > lib/game/components/unit.dart <<'DART'
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class UnitComponent extends PositionComponent with TapCallbacks {
  UnitComponent({
    required Vector2 start,
    this.radius = 14,
  }) : _target = start.clone() {
    position = start.clone();
    anchor = Anchor.center;
    size = Vector2.all(radius * 2);
  }

  final double radius;
  final Paint _paint = Paint()..color = const Color(0xFF6C63FF);
  Vector2 _target;

  // Units per second
  double speed = 220;

  void moveTo(Vector2 worldPoint) {
    _target = worldPoint.clone();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(radius, radius), radius, _paint);
    // little center dot for direction readability
    canvas.drawCircle(Offset(radius, radius), 3, Paint()..color = Colors.white);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final toTarget = _target - position;
    final dist = toTarget.length;
    if (dist < 1) return;

    final step = speed * dt;
    final dir = toTarget / math.max(dist, 0.0001);
    position += dir * math.min(step, dist);
  }
}
DART

# 5) The actual Flame game (camera + background + tap-to-move)
cat > lib/game/swift_conquer_game.dart <<'DART'
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
DART

# 6) Replace your placeholder Test Map screen with a GameWidget screen
cat > lib/screens/test_screen.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import '../game/swift_conquer_game.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test Map")),
      body: GameWidget(game: SwiftConquerGame()),
    );
  }
}
DART

# 7) Ensure main.dart routes point to TestScreen (keep your Home UI)
# If your main.dart already exists, we will minimally patch it by replacing the TestScreen import + route name.
if [ ! -f lib/main.dart ]; then
  echo "ERROR: lib/main.dart not found. Your Phase 15A main.dart should exist."
  exit 1
fi

# Make sure main.dart imports TestScreen from lib/screens/test_screen.dart
if ! grep -q "screens/test_screen.dart" lib/main.dart; then
  # remove any old test_screen import lines then add correct one
  sed -i '/test_screen\.dart/d' lib/main.dart || true
  sed -i '1i import '\''screens/test_screen.dart'\'';' lib/main.dart
fi

echo "✅ Phase 16 files written."
echo "Next:"
echo "  git status"
echo "  git add pubspec.yaml analysis_options.yaml lib"
echo "  git commit -m \"Phase 16: playable Flame test map (tap-to-move)\""
echo "  git push"
