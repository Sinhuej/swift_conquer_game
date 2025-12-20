import '../debug/snapshot.dart';
import '../systems/system_manager.dart';
import 'deterministic_rng.dart';
import 'event_queue.dart';
import 'fixed_timestep.dart';
import 'tick_state.dart';
import 'world_state.dart';

class SimulationController {
  final WorldState world;
  final SystemManager systems;

  final DeterministicRng rng;
  final EventQueue events = EventQueue();
  final FixedTimestep fixed;
  final TickState state = TickState();

  bool paused = false;
  double timeScale = 1.0;

  SimulationController({
    WorldState? world,
    SystemManager? systems,
    int seed = 1,
    double fixedStep = 1 / 60,
  })  : world = world ?? WorldState(),
        systems = systems ?? SystemManager(),
        rng = DeterministicRng(seed: seed),
        fixed = FixedTimestep(step: fixedStep);

  /// Step using a frame dt; internally runs N fixed ticks.
  void step(double frameDtSeconds) {
    if (paused) return;
    final dt = frameDtSeconds * timeScale;
    final n = fixed.accumulate(dt);
    for (int i = 0; i < n; i++) {
      tick();
    }
  }

  /// One deterministic fixed tick.
  void tick() {
    state.tick += 1;
    state.simTimeSeconds += fixed.step;

    systems.update(fixed.step, world);

    // events.drain() later for combat/FX/etc
    events.drain();
  }

  Snapshot snapshot() => Snapshot.fromWorld(tick: state.tick, world: world);
}
