import '../core/world_state.dart';

abstract class GameSystem {
  void update(WorldState world, double dt);
}
