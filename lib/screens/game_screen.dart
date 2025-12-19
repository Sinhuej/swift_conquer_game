import 'dart:async';
import 'package:flutter/material.dart';

import '../game/core/game_loop.dart';
import '../game/core/entity_id.dart';
import '../game/math/vec2.dart';
import '../game/ui/world_painter.dart';

/// Minimal Input model so build stays green.
/// If you already have an input controller, replace usage below to match it.
class InputState {
  EntityId? selected;
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameLoop loop = GameLoop();
  final InputState input = InputState();
  Timer? _timer;

  // Camera placeholder for painter (safe even if you replace later)
  CameraView cam = const CameraView();

  EntityId? a;
  EntityId? b;

  @override
  void initState() {
    super.initState();

    final world = loop.world;
    a = world.spawnUnit(const Vec2(120, 260), teamId: 1, hp: 25);
    b = world.spawnUnit(const Vec2(320, 260), teamId: 2, hp: 25);

    world.moveOrders[a!]!.target = const Vec2(520, 260);

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

  Set<EntityId> _selectedSet() {
    final s = input.selected;
    if (s == null) return <EntityId>{};
    return <EntityId>{s};
  }

  @override
  Widget build(BuildContext context) {
    final world = loop.world;

    return Scaffold(
      appBar: AppBar(
        title: const Text("SwiftConquer"),
        actions: [
          IconButton(
            onPressed: () {
              // Quick select toggle
              if (a != null && world.exists(a!)) {
                input.selected = (input.selected == a) ? null : a;
                setState(() {});
              }
            },
            icon: const Icon(Icons.touch_app),
          ),
        ],
      ),
      body: GestureDetector(
        onTapDown: (_) {
          // Simple tap behavior: move Unit A to a new target
          if (a != null && world.exists(a!)) {
            world.moveOrders[a!]!.target = const Vec2(520, 140);
            input.selected = a;
            setState(() {});
          }
        },
        child: CustomPaint(
          painter: WorldPainter(
            world: world,
            cam: cam,
            selected: _selectedSet(),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
