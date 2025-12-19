import 'dart:async';
import 'package:flutter/material.dart';

import '../game/core/game_loop.dart';
import '../game/core/entity_id.dart';
import '../game/math/vec2.dart';
import '../game/ui/camera.dart';
import '../game/ui/world_painter.dart';
import '../game/input/input_state.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameLoop loop = GameLoop();
  final Camera cam = Camera(pos: const Vec2(-40, 120), zoom: 1.0);
  final InputState input = InputState();

  Timer? _timer;
  EntityId? a;
  EntityId? b;

  @override
  void initState() {
    super.initState();

    final w = loop.world;
    a = w.spawnUnit(const Vec2(120, 260), teamId: 1, hp: 25);
    b = w.spawnUnit(const Vec2(320, 260), teamId: 2, hp: 25);
    w.moveOrders[a!]!.target = const Vec2(520, 260);

    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      loop.tick(1 / 60);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  EntityId? _hitTestUnit(Vec2 worldPoint) {
    // cheap hit test: find first unit within radius
    const r2 = 18.0 * 18.0;
    for (final id in loop.world.entities) {
      final p = loop.world.positions[id]?.value;
      if (p == null) continue;
      final dx = p.x - worldPoint.x;
      final dy = p.y - worldPoint.y;
      if (dx * dx + dy * dy <= r2) return id;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final world = loop.world;

    return Scaffold(
      appBar: AppBar(
        title: const Text("SwiftConquer • Ph 51–80 (Playable Stub)"),
        actions: [
          IconButton(
            tooltip: "Zoom In",
            onPressed: () => setState(() => cam.zoomBy(1.1, cam.screenToWorld(const Vec2(200, 200)))),
            icon: const Icon(Icons.zoom_in),
          ),
          IconButton(
            tooltip: "Zoom Out",
            onPressed: () => setState(() => cam.zoomBy(0.9, cam.screenToWorld(const Vec2(200, 200)))),
            icon: const Icon(Icons.zoom_out),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, box) {
          return GestureDetector(
            onTapDown: (d) {
              final local = d.localPosition;
              final worldPoint = cam.screenToWorld(Vec2(local.dx, local.dy));

              final hit = _hitTestUnit(worldPoint);
              setState(() {
                if (hit == null) {
                  input.clearSelection();
                } else {
                  input.selectSingle(hit);
                }
              });
            },
            onPanStart: (d) {
              input.dragging = true;
              input.lastDragScreen = Vec2(d.localPosition.dx, d.localPosition.dy);
            },
            onPanUpdate: (d) {
              final now = Vec2(d.localPosition.dx, d.localPosition.dy);
              final delta = now - input.lastDragScreen;
              input.lastDragScreen = now;
              setState(() => cam.pan(delta));
            },
            onPanEnd: (_) => input.dragging = false,
            child: CustomPaint(
              painter: WorldPainter(world: world, cam: cam, selected: input.selected),
              child: const SizedBox.expand(),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (a == null || !world.exists(a!)) return;
                    setState(() => world.moveOrders[a!]!.target = const Vec2(520, 140));
                  },
                  child: const Text("Move Unit A"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Tap-to-attack placeholder: just decrement target HP if both exist
                    if (a == null || b == null) return;
                    if (!world.exists(a!) || !world.exists(b!)) return;
                    setState(() {
                      world.targetOrders[a!]!.targetId = b;
                      final hp = world.health[b!];
                      if (hp != null) hp.current -= 1;
                    });
                  },
                  child: const Text("A hits B (-1 HP)"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
