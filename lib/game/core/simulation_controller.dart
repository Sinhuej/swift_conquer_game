import '../debug/snapshot.dart';
import '../systems/system_manager.dart';
import 'deterministic_rng.dart';
import 'event_queue.dart';
import 'fixed_timestep.dart';
import 'tick_state.dart';
import 'world_state.dart';

import 'package:swift_conquer_game/sim_ext/observability/sim_inspector.dart';
import 'package:swift_conquer_game/sim_ext/replay/replay_buffer.dart';
import 'package:swift_conquer_game/sim_ext/replay/replay_event.dart';
import 'package:swift_conquer_game/sim_ext/safety/perf_guards.dart';
import 'package:swift_conquer_game/sim_ext/tuning/tunables.dart';

class SimulationController {
  final WorldState world;
  final SystemManager systems;

  final DeterministicRng rng;
  final EventQueue events = EventQueue();
  final FixedTimestep fixed;
  final TickState state = TickState();

  final Tunables tunables;

  bool paused = false;
  double timeScale = 1.0;

  SimulationController({
    WorldState? world,
    SystemManager? systems,
    int seed = 1,
    double fixedStep = 1 / 60,
    Tunables? tunables,
  })  : world = world ?? WorldState(),
        systems = systems ?? SystemManager(),
        rng = DeterministicRng(seed: seed),
        fixed = FixedTimestep(step: fixedStep),
        tunables = tunables ?? Tunables();

  void step(
    double frameDtSeconds, {
    SimInspector? inspector,
    PerfGuards? perf,
    int? nowMs,
    ReplayBuffer? replay,
  }) {
    if (paused) return;
    final dt = frameDtSeconds * timeScale;
    final n = fixed.accumulate(dt);

    if (perf != null) {
      if (nowMs == null) {
        throw ArgumentError('nowMs required');
      }
      perf.start(nowMs);
    }

    for (int i = 0; i < n; i++) {
      _tickOnce(inspector: inspector, replay: replay);

      if (perf != null) {
        perf.check(tick: state.tick, nowMs: nowMs!);
      }
    }
  }

  void _tickOnce({
    SimInspector? inspector,
    ReplayBuffer? replay,
  }) {
    state.tick += 1;
    state.simTimeSeconds += fixed.step;

    replay?.record(
      ReplayEvent(
        tick: state.tick,
        type: 'TICK',
        payload: {'simTimeSeconds': state.simTimeSeconds},
      ),
    );

    inspector?.log(
      state.tick,
      'SIM',
      'TICK',
      payload: {'simTimeSeconds': state.simTimeSeconds},
    );

    systems.update(fixed.step, world);
    events.drain();

    inspector?.onTick(state.tick);
  }

  Snapshot snapshot() => Snapshot.fromWorld(tick: state.tick, world: world);
}
