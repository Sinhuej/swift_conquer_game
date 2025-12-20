import '../core/world_state.dart';

abstract class SimulationStep {
  void run(WorldState world);
}
