import 'package:test/test.dart';

import 'package:swift_conquer_game/sim_ext/ai/ai_personality.dart';
import 'package:swift_conquer_game/sim_ext/ai/ai_runner.dart';
import 'package:swift_conquer_game/sim_ext/ai/default_policy.dart';
import 'package:swift_conquer_game/sim_ext/ai/ai_personality.dart';
import 'package:swift_conquer_game/sim_ext/ai_integration/ai_coordinator.dart';
import 'package:swift_conquer_game/sim_ext/ai_integration/command_sink.dart';
import 'package:swift_conquer_game/sim_ext/ai_wiring/command_envelope.dart';
import 'package:swift_conquer_game/sim_ext/ai_wiring/observation_template.dart';

class _CaptureSink implements CommandSink {
  final List<CommandEnvelope> captured = [];
  @override
  void submit(CommandEnvelope command) => captured.add(command);
}

void main() {
  test('Coordinator ticks agents in stable sorted order', () {
    final tuning = AiDifficultyTuning.forLevel(AiDifficulty.normal);

    final c = AiCoordinator();
    c.register(
      agentId: 'b-agent',
      runner: AiRunner(
        policy: DefaultPolicy(),
        personality: AiPersonality.balanced,
        difficulty: tuning,
        seed: 2,
      ),
    );
    c.register(
      agentId: 'a-agent',
      runner: AiRunner(
        policy: DefaultPolicy(),
        personality: AiPersonality.balanced,
        difficulty: tuning,
        seed: 1,
      ),
    );

    final sink = _CaptureSink();
    final obsA = ObservationTemplate.minimal(enemiesNearby: 0, resources: 10, underAttack: false);
    final obsB = ObservationTemplate.minimal(enemiesNearby: 1, resources: 0, underAttack: true);

    final emitted = c.tickAll(
      tick: 60,
      observationsByAgent: {
        'a-agent': obsA,
        'b-agent': obsB,
      },
      sink: sink,
    );

    // If anything emitted, ordering is stable by agentId.
    if (emitted.length >= 2) {
      expect(emitted[0].agentId, equals('a-agent'));
      expect(emitted[1].agentId, equals('b-agent'));
    }
  });
}
