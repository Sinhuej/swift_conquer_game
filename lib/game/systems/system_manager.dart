import 'movement_system.dart';
import '../core/world_state.dart';

class SystemManager {
  final MovementSystem movement = MovementSystem();

  void update(double dt, WorldState world) {
    movement.update(dt, world.units.values);
  }
}
