import '../core/world_state.dart';

abstract class GameSystem {
  void update(double dt, WorldState world);
}
