#!/bin/bash
set -e

echo "=== SwiftConquer Phase 16: Game Core Injection ==="

mkdir -p lib/game/core
mkdir -p lib/game/map
mkdir -p lib/game/units

# --- Game Tick Engine ---
cat <<'DART' > lib/game/core/game_engine.dart
class GameEngine {
  int tick = 0;
  bool running = false;

  void start() {
    running = true;
  }

  void stop() {
    running = false;
  }

  void update() {
    if (!running) return;
    tick++;
  }
}
DART

# --- Map Model ---
cat <<'DART' > lib/game/map/game_map.dart
class GameMap {
  final int width;
  final int height;

  GameMap({required this.width, required this.height});
}
DART

# --- Unit Model ---
cat <<'DART' > lib/game/units/unit.dart
class Unit {
  final String id;
  int x;
  int y;

  Unit(this.id, this.x, this.y);
}
DART

echo "✔ Game core files created"
echo "Next steps:"
echo "  git add lib/game"
echo "  git commit -m 'Phase 16: Add game core scaffolding'"
echo "  git push"
