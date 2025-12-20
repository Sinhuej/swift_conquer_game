import 'package:test/test.dart';

import 'package:swift_conquer_game/game/core/simulation_controller.dart';
import 'package:swift_conquer_game/game/core/world_state.dart';
import 'package:swift_conquer_game/game/systems/system_manager.dart';

import 'package:swift_conquer_game/sim_ext/observability/run_meta.dart';
import 'package:swift_conquer_game/sim_ext/observability/sim_hasher.dart';
import 'package:swift_conquer_game/sim_ext/observability/sim_inspector.dart';

void main() {
  test('Determinism: same seed produces identical snapshot hashes', () {
    const seed = 12345;

    Map<int, String> runOnce() {
      final world = WorldState();
      final systems = SystemManager();

      final sim = SimulationController(
        world: world,
        systems: systems,
        seed: seed,
        fixedStep: 1 / 60,
      );

      final inspector = SimInspector(
        meta: const RunMeta(
          runId: 'det-test',
          seed: seed,
          scenarioId: 'default',
        ),
        snapshotBuilder: () => <String, Object?>{
          'tick': sim.state.tick,
          'entities': world.entityCount,
          'positions': world.positions.length,
          'health': world.health.length,
          'teams': world.teams.length,
          'moveOrders': world.moveOrders.length,
          'targetOrders': world.targetOrders.length,
        },
        snapshotEveryTicks: 60,
      );

      for (int i = 0; i < 600; i++) {
        sim.step(1 / 60, inspector: inspector);
      }

      inspector.captureSnapshot(sim.state.tick);
      final snap = inspector.latestSnapshot!;
      return {snap.tick: SimHasher.stableHash(snap.toJson())};
    }

    final a = runOnce();
    final b = runOnce();

    expect(a.keys, equals(b.keys));
    for (final k in a.keys) {
      expect(a[k], equals(b[k]), reason: 'Mismatch at tick $k');
    }
  });
}
