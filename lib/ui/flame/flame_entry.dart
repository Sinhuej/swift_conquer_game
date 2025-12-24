import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:flame/game.dart';

import '../bridge/simulation_bridge.dart';
import 'swift_conquer_flame_game.dart';

class FlameEntry extends StatefulWidget {
  const FlameEntry({super.key});

  @override
  State<FlameEntry> createState() => _FlameEntryState();
}

class _FlameEntryState extends State<FlameEntry> with SingleTickerProviderStateMixin {
  late final SimulationBridge _bridge;
  late final SwiftConquerFlameGame _game;

  Ticker? _ticker;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _bridge = SimulationBridge();
    _game = SwiftConquerFlameGame();

    // Flutter drives sim timing. Flame renders only.
    _ticker = createTicker((elapsed) {
      final dt = _last == Duration.zero
          ? (1.0 / 60.0)
          : (elapsed - _last).inMicroseconds / 1000000.0;
      _last = elapsed;

      _bridge.tick(dt);
      final snap = _bridge.snapshot(); // canonical B (UI-safe)
      _game.pushSnapshot(snap);
    });

    _ticker!.start();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: _game);
  }
}
