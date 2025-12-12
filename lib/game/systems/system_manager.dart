import 'game_system.dart';

class SystemManager {
  final List<GameSystem> _systems = [];

  void add(GameSystem system) {
    _systems.add(system);
  }

  void update(double dt) {
    for (final system in _systems) {
      system.update(dt);
    }
  }
}
