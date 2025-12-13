import 'world_state.dart';
import '../systems/system_manager.dart';

class GameLoop {
  final WorldState world;
  late final SystemManager systems;

  GameLoop(this.world) {
    systems = SystemManager(world);
  }

  void update(double dt) {
    systems.update(dt);
  }
}
