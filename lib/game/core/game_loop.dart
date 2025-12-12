import '../systems/system_manager.dart';

class GameLoop {
  final SystemManager systems = SystemManager();

  void update(double dt) {
    systems.update(dt);
  }
}
