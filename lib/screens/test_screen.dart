import 'dart:async';
import 'package:flutter/material.dart';

import '../game/core/game_loop.dart';
import '../game/core/commands.dart';
import '../game/components/position.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final loop = GameLoop();
  late final Commands cmd;

  int? a;
  int? b;

  Timer? timer;
  bool running = false;

  @override
  void initState() {
    super.initState();
    cmd = Commands(loop.world);

    // Spawn 2 units on different teams.
    a = loop.world.spawnUnit(
      x: 120, y: 260,
      teamId: 1,
      hp: 120,
      damage: 10,
      range: 90,
      cooldown: 0.5,
    );

    b = loop.world.spawnUnit(
      x: 320, y: 260,
      teamId: 2,
      hp: 140,
      damage: 8,
      range: 90,
      cooldown: 0.6,
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void tick([double dt = 0.016]) {
    loop.tick(dt);
    setState(() {});
  }

  void toggleRun() {
    running = !running;
    timer?.cancel();
    if (running) {
      timer = Timer.periodic(const Duration(milliseconds: 16), (_) => tick(0.016));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final world = loop.world;

    Widget unitCard(int? id, String label) {
      if (id == null || !world.exists(id)) {
        return Card(child: ListTile(title: Text("$label: dead/none")));
      }
      final p = world.positions[id]!;
      final hp = world.health[id]!;
      final team = world.teams[id]!.id;
      final tgt = world.targetOrders[id]?.targetId;

      return Card(
        child: ListTile(
          title: Text("$label (Team $team)"),
          subtitle: Text("HP ${hp.hp}/${hp.maxHp}  |  Pos (${p.x.toStringAsFixed(1)}, ${p.y.toStringAsFixed(1)})  |  Target ${tgt ?? '-'}"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("SwiftConquer • Skirmish Test (Phase 21)")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            unitCard(a, "Unit A"),
            unitCard(b, "Unit B"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => tick(0.1),
                  child: const Text("Tick +0.1s"),
                ),
                ElevatedButton(
                  onPressed: toggleRun,
                  child: Text(running ? "Stop" : "Run"),
                ),
                ElevatedButton(
                  onPressed: (a != null) ? () => cmd.issueMove(a!, Position(220, 260)) : null,
                  child: const Text("Move A → mid"),
                ),
                ElevatedButton(
                  onPressed: (b != null) ? () => cmd.issueMove(b!, Position(220, 260)) : null,
                  child: const Text("Move B → mid"),
                ),
                ElevatedButton(
                  onPressed: (a != null && b != null) ? () => cmd.issueAttack(a!, b!) : null,
                  child: const Text("A attacks B"),
                ),
                ElevatedButton(
                  onPressed: (a != null && b != null) ? () => cmd.issueAttack(b!, a!) : null,
                  child: const Text("B attacks A"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text("Entities alive: ${world.entityCount}"),
          ],
        ),
      ),
    );
  }
}
