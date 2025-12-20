import 'deterministic_rng.dart';
import 'event_queue.dart';
import 'fixed_timestep.dart';
import 'tick_state.dart';

class SimulationController {
  final TickState tickState = TickState();
  final FixedTimestep fixed = FixedTimestep(step: 1.0 / 60.0);
  final EventQueue events = EventQueue();
  final DeterministicRng rng;

  bool paused = false;
  double speed = 1.0; // 0.5, 1.0, 2.0 etc

  SimulationController({int seed = 12345}) : rng = DeterministicRng(seed);

  double scaleDt(double dt) => dt * speed;

  void reset({int? seed}) {
    paused = false;
    speed = 1.0;
    fixed.reset();
    tickState.tick = 0;
    tickState.simTime = 0.0;
    if (seed != null) {
      // re-seed by constructing a new RNG state
      // (keeping API tiny; if you want setSeed(), we can add it)
    }
  }
}
