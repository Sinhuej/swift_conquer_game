import 'package:test/test.dart';
import 'package:swift_conquer_game/game/core/simulation_controller.dart';
import 'package:swift_conquer_game/game/core/world_state.dart';
import 'package:swift_conquer_game/game/systems/system_manager.dart';
import 'package:swift_conquer_game/sim_ext/observability/sim_inspector.dart';
import 'package:swift_conquer_game/sim_ext/observability/sim_hasher.dart';
import 'package:swift_conquer_game/sim_ext/observability/run_meta.dart';

void main() {
  test('Determinism stress: stable per seed', () {
    for (int seed = 1; seed <= 5; seed++) {
      String runOnce() {
        final world = WorldState();
        final sim = SimulationController(
          world: world,
          systems: SystemManager(),
          seed: seed,
        );

        final inspector = SimInspector(
          meta: RunMeta(runId: 'stress', seed: seed, scenarioId: 'default'),
          snapshotBuilder: () => {
            'tick': sim.state.tick,
            'entities': world.entityCount,
          },
          snapshotEveryTicks: 60,
        );

        for (int i = 0; i < 600; i++) {
          sim.step(1 / 60, inspector: inspector);
        }

        inspector.captureSnapshot(sim.state.tick);
        return SimHasher.stableHash(inspector.latestSnapshot!.toJson());
      }

      expect(runOnce(), equals(runOnce()),
          reason: 'Seed $seed nondeterministic');
    }
  });
}
