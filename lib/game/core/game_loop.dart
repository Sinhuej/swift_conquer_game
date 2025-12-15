import '../systems/system_manager.dart';
import 'world_state.dart';

class GameLoop {
  final WorldState world = WorldState();
  final SystemManager systems = SystemManager();

  void update(double dt) {
    systems.update(world, dt);
  }
}
