import 'tick.dart';
import 'world_state.dart';
import '../systems/system_manager.dart';

class GameLoop {
  final WorldState world = WorldState();
  final SystemManager systems = SystemManager();

  void update() {
    systems.update(Tick.fixedDelta, world);
  }
}
