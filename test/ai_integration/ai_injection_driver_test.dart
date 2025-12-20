import 'package:test/test.dart';

import 'package:swift_conquer_game/sim_ext/ai/ai_personality.dart';
import 'package:swift_conquer_game/sim_ext/ai/ai_runner.dart';
import 'package:swift_conquer_game/sim_ext/ai/ai_types.dart';
import 'package:swift_conquer_game/sim_ext/ai/default_policy.dart';
import 'package:swift_conquer_game/sim_ext/ai_integration/ai_injection_driver.dart';
import 'package:swift_conquer_game/sim_ext/ai_integration/command_sink.dart';
import 'package:swift_conquer_game/sim_ext/ai_wiring/command_envelope.dart';
import 'package:swift_conquer_game/sim_ext/ai_wiring/observation_template.dart';

class _CaptureSink implements CommandSink {
  final List<CommandEnvelope> captured = [];
  @override
  void submit(CommandEnvelope command) => captured.add(command);
}

void main() {
  test('Injection driver emits deterministically for same seed/obs', () {
    final tuning = AiDifficultyTuning.forLevel(AiDifficulty.normal);

    AiInjectionDriver make(int seed) {
      return AiInjectionDriver(
        agentId: 'ai-1',
        runner: AiRunner(
          policy: DefaultPolicy(),
          personality: AiPersonality.balanced,
          difficulty: tuning,
          seed: seed,
        ),
      );
    }

    List<String> run(int seed) {
      final driver = make(seed);
      final sink = _CaptureSink();

      final obs = ObservationTemplate.minimal(
        enemiesNearby: 2,
        resources: 10,
        underAttack: true,
      );

      for (int tick = 1; tick <= 300; tick++) {
        driver.tick(tick: tick, obs: obs, sink: sink);
      }

      return sink.captured
          .map((e) => '${e.tick}:${e.commandType}:${e.payload['mode']}')
          .toList();
    }

    expect(run(123), equals(run(123)));
  });

  test('Injection emits envelopes into sink', () {
    final tuning = AiDifficultyTuning.forLevel(AiDifficulty.normal);

    final driver = AiInjectionDriver(
      agentId: 'ai-1',
      runner: AiRunner(
        policy: DefaultPolicy(),
        personality: AiPersonality.balanced,
        difficulty: tuning,
        seed: 7,
      ),
    );

    final sink = _CaptureSink();
    final obs = ObservationTemplate.minimal(
      enemiesNearby: 1,
      resources: 0,
      underAttack: true,
    );

    for (int tick = 1; tick <= 120; tick++) {
      driver.tick(tick: tick, obs: obs, sink: sink);
    }

    expect(sink.captured.isNotEmpty, isTrue);
  });
}
