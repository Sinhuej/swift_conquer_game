import '../systems/system_manager.dart';

class GameLoop {
  final SystemManager systems = SystemManager();

  void tick(double dt) {
    systems.update(dt);
  }
}
