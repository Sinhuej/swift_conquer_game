import '../systems/system_manager.dart';
import 'world_state.dart';

class GameLoop {
  final WorldState world = WorldState();
  final SystemManager systems = SystemManager();

  void tick(double dt) {
    systems.update(dt, world);
  }
}
