import 'dart:async';
import 'package:flutter/material.dart';
import '../game/core/game_loop.dart';
import '../game/math/vec2.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final GameLoop loop = GameLoop();
  Timer? _timer;
  int ticks = 0;

  @override
  void initState() {
    super.initState();

    final world = loop.world;
    world.spawnUnit(const Vec2(100, 100));
    world.spawnUnit(const Vec2(300, 100));

    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      loop.tick(1 / 60);
      ticks++;
      if (ticks % 60 == 0) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SwiftConquer – Headless Sim')),
      body: Center(
        child: Text(
          'Entities: ${loop.world.entityCount}\nTicks: $ticks',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
