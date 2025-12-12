import 'dart:async';
import 'engine.dart';

class TickLoop {
  final GameEngine engine;
  Timer? _timer;

  TickLoop(this.engine);

  void start() {
    _timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => engine.tick(),
    );
  }

  void stop() {
    _timer?.cancel();
  }
}
