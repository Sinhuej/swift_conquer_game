import 'dart:async';
import 'package:flutter/material.dart';
import '../game/core/game_loop.dart';
import '../game/core/entity_id.dart';
import '../game/math/vec2.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final GameLoop loop = GameLoop();
  Timer? _timer;

  EntityId? a;
  EntityId? b;

  @override
  void initState() {
    super.initState();
    final world = loop.world;

    a = world.spawnUnit(const Vec2(120, 260), teamId: 1, hp: 25);
    b = world.spawnUnit(const Vec2(320, 260), teamId: 2, hp: 25);

    // proof of life: move A to the right
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

  @override
  Widget build(BuildContext context) {
    final world = loop.world;

    Widget unitCard(EntityId id) {
      final pos = world.positions[id]!.value;
      final hp = world.health[id]!;
      final team = world.teams[id]!.id;
      final tgt = world.targetOrders[id]?.targetId;

      return Card(
        child: ListTile(
          title: Text("Unit ${id.value} (Team $team)"),
          subtitle: Text(
            "HP ${hp.current}/${hp.max} | Pos (${pos.x.toStringAsFixed(1)}, ${pos.y.toStringAsFixed(1)}) | Target ${tgt?.value ?? '-'}",
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("SwiftConquer • GREEN LOCK")),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text("Entities alive: ${world.entityCount}"),
          const SizedBox(height: 10),
          if (a != null && world.exists(a!)) unitCard(a!),
          if (b != null && world.exists(b!)) unitCard(b!),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              if (a == null || !world.exists(a!)) return;
              world.moveOrders[a!]!.target = const Vec2(520, 140);
            },
            child: const Text("Move Unit A"),
          ),
          ElevatedButton(
            onPressed: () {
              if (b == null || !world.exists(b!)) return;
              world.health[b!]!.current = 0; // prove combat cleanup
            },
            child: const Text("Kill Unit B"),
          ),
        ],
      ),
    );
  }
}
