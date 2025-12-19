import 'package:flutter/material.dart';
import '../game/core/game_loop.dart';
import '../game/core/entity_id.dart';
import '../game/ui/world_painter.dart';
import '../game/math/vec2.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameLoop loop = GameLoop();
  EntityId? selected;

  @override
  void initState() {
    super.initState();
    final world = loop.world;
    world.spawnUnit(const Vec2(120, 260), teamId: 1);
    world.spawnUnit(const Vec2(320, 260), teamId: 2);
  }

  @override
  Widget build(BuildContext context) {
    final world = loop.world;

    final selectedSet = <EntityId>{
      if (selected != null) selected!,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('SwiftConquer')),
      body: GestureDetector(
        onTapDown: (d) {
          setState(() {
            selected = world.entities.isNotEmpty
                ? world.entities.first
                : null;
          });
        },
        child: CustomPaint(
          painter: WorldPainter(
            world: world,
            selected: selectedSet,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
