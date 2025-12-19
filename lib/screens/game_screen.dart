import 'dart:async';
import 'package:flutter/material.dart';
import '../game/camera/camera_state.dart';
import '../game/core/game_loop.dart';
import '../game/input/input_controller.dart';
import '../game/math/vec2.dart';
import '../game/ui/hud.dart';
import '../game/ui/world_painter.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameLoop loop = GameLoop();
  final CameraState cam = CameraState();
  final InputController input = InputController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Spawn 2 demo units
    loop.world.spawnUnit(const Vec2(160, 260), teamId: 1, hp: 25);
    loop.world.spawnUnit(const Vec2(380, 260), teamId: 2, hp: 25);

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

  @override
  Widget build(BuildContext context) {
    final world = loop.world;

    return Scaffold(
      appBar: AppBar(title: const Text("SwiftConquer • Playable Prototype")),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) {
          final p = d.localPosition;
          input.onTap(world, cam, Vec2(p.dx, p.dy));
          setState(() {});
        },
        child: Stack(
          children: [
            CustomPaint(
              painter: WorldPainter(world: world, cam: cam, selected: input.selected),
              child: const SizedBox.expand(),
            ),
            Positioned(
              left: 12,
              top: 12,
              child: Hud(world: world, selected: input.selected),
            ),
          ],
        ),
      ),
    );
  }
}
