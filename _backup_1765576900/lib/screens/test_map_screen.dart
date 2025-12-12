import 'package:flutter/material.dart';
import '../engine/game_state.dart';
import '../engine/engine.dart';
import '../engine/tick_loop.dart';

class TestMapScreen extends StatefulWidget {
  const TestMapScreen({super.key});

  @override
  State<TestMapScreen> createState() => _TestMapScreenState();
}

class _TestMapScreenState extends State<TestMapScreen> {
  late final GameState state;
  late final GameEngine engine;
  late final TickLoop loop;

  @override
  void initState() {
    super.initState();
    state = GameState();
    engine = GameEngine(state);
    loop = TickLoop(engine)..start();
  }

  @override
  void dispose() {
    loop.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test Map")),
      body: Center(
        child: Text(
          "Ticks: ${state.tickCount}",
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
