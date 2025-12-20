import '../systems/system_manager.dart';
import 'simulation_controller.dart';
import 'time_controller.dart';
import 'world_state.dart';

import '../../sim_ext/observability/run_meta.dart';
import '../../sim_ext/observability/sim_inspector.dart';

class GameLoop {
  final WorldState world = WorldState();
  final SystemManager systems = SystemManager();
  final TimeController time = TimeController();

  bool _started = false;

  late final SimulationController sim = SimulationController(
    world: world,
    systems: systems,
    seed: 1,
    fixedStep: 1 / 60,
  );

  late final SimInspector inspector = SimInspector(
    meta: RunMeta(
      runId: 'default-run',
      seed: 1,
      scenarioId: 'default-scenario',
    ),
    // Phase 71 baseline snapshot (pure data, safe, minimal)
    snapshotBuilder: () => <String, Object?>{
      'tick': sim.state.tick,
      'entities': world.entityCount,
      'positions': world.positions.length,
      'health': world.health.length,
      'teams': world.teams.length,
      'moveOrders': world.moveOrders.length,
      'targetOrders': world.targetOrders.length,
    },
  );

  /// Called by UI/driver. Internally advances deterministic fixed ticks.
  void tick(double dt) {
    final scaledDt = time.apply(dt);
    if (scaledDt <= 0) return;

    if (!_started) {
      inspector.log(
        sim.state.tick,
        'SYS',
        'RUN_START',
        payload: {
          'seed': 1,
          'fixedStep': 1 / 60,
        },
      );
      _started = true;
    }

    sim.step(
      scaledDt,
      inspector: inspector,
    );
  }

  /// Optional explicit shutdown hook (headless / tests).
  void endRun() {
    if (!_started) return;

    inspector.log(
      sim.state.tick,
      'SYS',
      'RUN_END',
    );

    // Optional: capture final snapshot for determinism validation later.
    inspector.captureSnapshot(sim.state.tick);
  }
}
