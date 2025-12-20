import '../systems/system_manager.dart';
import 'world_state.dart';
import 'time_controller.dart';

class GameLoop {
  final WorldState world = WorldState();
  final SystemManager systems = SystemManager();
  final TimeController time = TimeController();

  void tick(double dt) {
    final scaledDt = time.apply(dt);
    if (scaledDt <= 0) return;
    systems.update(scaledDt, world);
  }
}
