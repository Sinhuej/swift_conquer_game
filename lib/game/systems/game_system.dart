import '../core/world_state.dart';

abstract class GameSystem {
  /// All systems update against the same WorldState.
  void update(WorldState world, double dt);
}
