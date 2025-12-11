#!/bin/bash
echo "=== Swift Conquer • Full Echo-Based Rebuild ==="

# ---------- DIRECTORY TREE ----------
echo "Creating directory tree…"

mkdir -p lib
mkdir -p lib/screens
mkdir -p lib/game
mkdir -p lib/game/debug
mkdir -p lib/game/input
mkdir -p lib/game/render
mkdir -p lib/game/test_maps
mkdir -p lib/integration
mkdir -p assets/images
mkdir -p assets/sfx
mkdir -p assets/fonts

# ---------- PUBSPEC ----------
echo "Writing pubspec.yaml…"

cat > pubspec.yaml <<'EOF'
name: swift_conquer_game
description: RTS prototype powered by Swift Conquer Engine
version: 0.0.1

environment:
  sdk: '>=2.17.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flame: ^1.14.0
  swift_conquer_engine:
    git:
      url: https://github.com/Sinhuej/swift_conquer_engine.git

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/sfx/
    - assets/fonts/
EOF

# ---------- ANALYSIS OPTIONS ----------
echo "Writing analysis_options.yaml…"

cat > analysis_options.yaml <<'EOF'
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: false
EOF

# ---------- MAIN APP ----------
echo "Writing lib/main.dart…"

cat > lib/main.dart <<'EOF'
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const SwiftConquerApp());

class SwiftConquerApp extends StatelessWidget {
  const SwiftConquerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Swift Conquer",
      home: const HomeScreen(),
    );
  }
}
EOF

# ---------- HOME SCREEN ----------
echo "Writing HomeScreen…"

cat > lib/screens/home_screen.dart <<'EOF'
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Swift Conquer")),
      body: const Center(
        child: Text("Welcome to Swift Conquer Prototype"),
      ),
    );
  }
}
EOF

# ---------- ENGINE BRIDGE STUB ----------
echo "Writing EngineBridge stub…"

cat > lib/integration/engine_bridge.dart <<'EOF'
class EngineBridge {
  Future<void> initialize() async {}
  void update(double dt) {}
  List<UnitStub> getUnits() => [];
  void selectAt(double x, double y) {}
  void issueMove(double x, double y) {}
}

class UnitStub {
  UnitStub(this.position);
  final PositionStub position;
}

class PositionStub {
  PositionStub(this.x, this.y);
  final double x;
  final double y;
}
EOF

# ---------- FLAME ROOT ----------
echo "Writing flame_game_root.dart…"

cat > lib/game/flame_game_root.dart <<'EOF'
import 'package:flame/game.dart';
import '../integration/engine_bridge.dart';

class SwiftConquerFlameGame extends FlameGame {
  final engine = EngineBridge();

  @override
  Future<void> onLoad() async {
    await engine.initialize();
  }

  @override
  void update(double dt) {
    engine.update(dt);
  }
}
EOF

# ---------- DEBUG OVERLAY ----------
echo "Writing DebugOverlay (stub)…"

cat > lib/game/debug/debug_overlay.dart <<'EOF'
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
EOF

# ---------- TEST MAP ----------
echo "Writing testmap20.dart…"

cat > lib/game/test_maps/testmap20.dart <<'EOF'
import '../../integration/engine_bridge.dart';

class TestMap20 {
  void load(EngineBridge engine) {
    // minimal stub
  }
}
EOF

echo "DONE! 🎉  Project structure rebuilt using echo-only"
echo "Next steps:"
echo "1. git add ."
echo "2. git commit -m 'Rebuilt project using echo system'"
echo "3. git push"

