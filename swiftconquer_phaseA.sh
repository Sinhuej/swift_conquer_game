#!/bin/bash
echo "=== SwiftConquer • PHASE A — Safe Core Setup ==="

mkdir -p lib/core
mkdir -p lib/core/engine
mkdir -p lib/core/systems
mkdir -p lib/core/data
mkdir -p lib/features/home
mkdir -p lib/features/battle
mkdir -p lib/features/testmap

# --- ENGINE PLACEHOLDERS ---
cat > lib/core/engine/engine.dart <<'EOF'
class Engine {
  void update(double dt) {}
}
EOF

cat > lib/core/engine/game_state.dart <<'EOF'
class GameState {
  Map<String, dynamic> toJson() => {};
}
EOF

# --- SYSTEM PLACEHOLDERS ---
cat > lib/core/systems/pathfinding.dart <<'EOF'
class PathfindingSystem {}
EOF

cat > lib/core/systems/combat.dart <<'EOF'
class CombatSystem {}
EOF

# --- FEATURES ---
cat > lib/features/home/home_screen.dart <<'EOF'
import 'package:flutter/material.dart';
import '../testmap/test_map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SwiftConquer")),
      body: Center(
        child: ElevatedButton(
          child: const Text("Launch Test Map"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TestMapScreen()),
            );
          },
        ),
      ),
    );
  }
}
EOF

cat > lib/features/testmap/test_map_screen.dart <<'EOF'
import 'package:flutter/material.dart';

class TestMapScreen extends StatelessWidget {
  const TestMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test Map")),
      body: const Center(
        child: Text("Test Map Loaded — Engine placeholder OK"),
      ),
    );
  }
}
EOF

# --- MAIN FILE PATCH ---
cat > lib/main.dart <<'EOF'
import 'package:flutter/material.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(const SwiftConquerApp());
}

class SwiftConquerApp extends StatelessWidget {
  const SwiftConquerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwiftConquer',
      home: const HomeScreen(),
    );
  }
}
EOF

echo "=== PHASE A complete. Commit and push: ==="
echo "git add ."
echo "git commit -m 'SwiftConquer Phase A: core placeholders + stable screens'"
echo "git push"

