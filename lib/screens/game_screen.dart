import 'dart:async';
import 'package:flutter/material.dart';
import '../game/core/game_loop.dart';
import '../game/math/vec2.dart';
import '../game/ui/camera_view.dart';
import '../game/ui/input_controller.dart';
import '../game/ui/world_painter.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameLoop loop = GameLoop();
  final CameraView cam = CameraView(offset: const Vec2(0, 0), zoom: 1.0);
  final InputController input = InputController();

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Spawn 2 units so you see something immediately.
    final w = loop.world;
    final a = w.spawnUnit(const Vec2(140, 240), teamId: 1, hp: 25);
    final b = w.spawnUnit(const Vec2(340, 240), teamId: 2, hp: 25);

    // Give unit A a starter move target so movement shows.
    w.moveOrders[a]!.target = const Vec2(520, 240);

    // Tick loop
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      loop.tick(1 / 60);
      setState(() {});
    });

    // keep analyzer happy about unused 'b' if needed later
    // ignore: unused_local_variable
    final _ = b;
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
      appBar: AppBar(
        title: const Text("SwiftConquer • Phase 32–40"),
        actions: [
          IconButton(
            onPressed: () => setState(input.clearSelection),
            icon: const Icon(Icons.cancel),
            tooltip: "Clear selection",
          )
        ],
      ),
      body: GestureDetector(
        onTapDown: (d) => setState(() {
          input.onTapDown(details: d, world: world, cam: cam);
        }),
        child: CustomPaint(
          painter: WorldPainter(world: world, cam: cam, selected: input.selected),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
