#!/usr/bin/env bash
set -euo pipefail

echo "=== SwiftConquer Phase 51–60 (GREEN + scaffolding) ==="

# -----------------------------
# Folders
# -----------------------------
mkdir -p lib/screens
mkdir -p lib/game/ui
mkdir -p lib/game/ui/hud
mkdir -p lib/game/ui/minimap
mkdir -p lib/game/ui/input
mkdir -p lib/game/ui/debug
mkdir -p lib/game/save
mkdir -p lib/game/audio
mkdir -p lib/game/telemetry

# -----------------------------
# STEP 1: Fix current RED build
# - Ensure FlameScreen exists
# - Ensure main.dart compiles
# -----------------------------
cat > lib/screens/flame_screen.dart <<'DART'
import 'package:flutter/material.dart';

/// Phase 51–60: Flame integration will come later.
/// For now, this keeps CI GREEN while we build systems safely.
class FlameScreen extends StatelessWidget {
  const FlameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "SwiftConquer\nPhase 51–60 scaffolding ✅\n(Flame hookup next)",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
DART

cat > lib/main.dart <<'DART'
import 'package:flutter/material.dart';
import 'screens/flame_screen.dart';

void main() {
  runApp(const SwiftConquerApp());
}

class SwiftConquerApp extends StatelessWidget {
  const SwiftConquerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FlameScreen(),
    );
  }
}
DART

# -----------------------------
# Phase 51: Input Router (no Flame)
# -----------------------------
cat > lib/game/ui/input/input_router.dart <<'DART'
typedef PointerId = int;

class InputRouter {
  double lastX = 0;
  double lastY = 0;

  void onTap(double x, double y) {
    lastX = x;
    lastY = y;
  }

  void onDrag(PointerId id, double x, double y) {
    lastX = x;
    lastY = y;
  }
}
DART

# -----------------------------
# Phase 52: Camera Model (headless)
# -----------------------------
cat > lib/game/ui/camera.dart <<'DART'
import '../math/vec2.dart';

class Camera {
  Vec2 position = const Vec2(0, 0);
  double zoom = 1.0;

  void pan(Vec2 delta) {
    position = position + delta;
  }

  void setZoom(double z) {
    zoom = z.clamp(0.25, 4.0);
  }
}
DART

# -----------------------------
# Phase 53: Render Adapter (placeholder)
# -----------------------------
cat > lib/game/ui/render_adapter.dart <<'DART'
/// Placeholder render adapter.
/// Later: bridge ECS world -> Flame renderer.
/// For now: compile-safe and CI-green.
class RenderAdapter {
  void tick(double dt) {
    // noop
  }
}
DART

# -----------------------------
# Phase 54: Selection Box Model
# -----------------------------
cat > lib/game/ui/input/selection_box.dart <<'DART'
import '../../math/vec2.dart';

class SelectionBox {
  Vec2? start;
  Vec2? end;

  bool get active => start != null && end != null;

  void begin(Vec2 p) {
    start = p;
    end = p;
  }

  void update(Vec2 p) {
    end = p;
  }

  void clear() {
    start = null;
    end = null;
  }
}
DART

# -----------------------------
# Phase 55: Command Queue UI stub (headless)
# -----------------------------
cat > lib/game/ui/hud/command_panel.dart <<'DART'
class CommandPanel {
  final List<String> log = [];

  void push(String msg) {
    log.add(msg);
    if (log.length > 50) log.removeAt(0);
  }
}
DART

# -----------------------------
# Phase 56: Minimap stub
# -----------------------------
cat > lib/game/ui/minimap/minimap_model.dart <<'DART'
class MinimapModel {
  double viewX = 0;
  double viewY = 0;
  double viewW = 1;
  double viewH = 1;

  void setView(double x, double y, double w, double h) {
    viewX = x; viewY = y; viewW = w; viewH = h;
  }
}
DART

# -----------------------------
# Phase 57: HUD state stub
# -----------------------------
cat > lib/game/ui/hud/hud_state.dart <<'DART'
class HudState {
  int selectedCount = 0;
  int resources = 0;

  void setSelected(int n) => selectedCount = n;
  void setResources(int r) => resources = r;
}
DART

# -----------------------------
# Phase 58: Save/Load stub (no IO yet)
# -----------------------------
cat > lib/game/save/save_system.dart <<'DART'
class SaveSystem {
  String saveToJson() {
    // Later: serialize WorldState
    return '{"ok":true}';
  }

  void loadFromJson(String json) {
    // Later: deserialize WorldState
  }
}
DART

# -----------------------------
# Phase 59: Audio stub
# -----------------------------
cat > lib/game/audio/audio_system.dart <<'DART'
class AudioSystem {
  bool enabled = true;

  void play(String sfxId) {
    if (!enabled) return;
    // Later: hook Flame Audio or another solution
  }
}
DART

# -----------------------------
# Phase 60: Telemetry stub
# -----------------------------
cat > lib/game/telemetry/telemetry.dart <<'DART'
class Telemetry {
  final Map<String, int> counters = {};

  void inc(String key, [int by = 1]) {
    counters[key] = (counters[key] ?? 0) + by;
  }
}
DART

echo "✅ Phase 51–60 files written."
echo "Next:"
echo "  git add lib phase51_60_cat.sh"
echo "  git commit -m \"Phase 51–60: UI scaffolding + keep CI green\""
echo "  git push"
