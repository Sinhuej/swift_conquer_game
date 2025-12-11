import 'package:flame/game.dart';
import '../integration/engine_bridge.dart';

class SwiftConquerFlameGame extends FlameGame {
  final engine = EngineBridge();

  @override
  Future<void> onLoad() async {
    await engine.initialize();
  }

  @override
  void update(double dt) {
    engine.update(dt);
  }
}
