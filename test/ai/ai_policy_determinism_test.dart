import 'package:test/test.dart';

import 'package:swift_conquer_game/sim_ext/ai/ai_personality.dart';
import 'package:swift_conquer_game/sim_ext/ai/ai_runner.dart';
import 'package:swift_conquer_game/sim_ext/ai/ai_types.dart';
import 'package:swift_conquer_game/sim_ext/ai/default_policy.dart';

void main() {
  test('AI decisions are deterministic for same seed + same observations', () {
    final obs = AiObservation({
      'enemiesNearby': 2,
      'resources': 10,
      'underAttack': true,
    });

    final tuning = AiDifficultyTuning.forLevel(AiDifficulty.normal);

    List<String> run(int seed) {
      final r = AiRunner(
        policy: DefaultPolicy(),
        personality: AiPersonality.balanced,
        difficulty: tuning,
        seed: seed,
      );

      final out = <String>[];
      for (int tick = 1; tick <= 300; tick++) {
        final d = r.maybeDecide(tick: tick, agentId: 'ai-1', obs: obs);
        if (d != null) {
          out.add('${d.tick}:${d.action.type}:${d.meta['mode']}');
        }
      }
      return out;
    }

    expect(run(123), equals(run(123)));
    expect(run(999), equals(run(999)));
  });

  test('AI decisions differ across different seeds (when randomness enabled)', () {
    final obs = AiObservation({
      'enemiesNearby': 0,
      'resources': 100,
      'underAttack': false,
    });

    // Hard has very low randomness, so use easy to get exploration events.
    final tuning = AiDifficultyTuning.forLevel(AiDifficulty.easy);

    List<String> run(int seed) {
      final r = AiRunner(
        policy: DefaultPolicy(),
        personality: AiPersonality.balanced,
        difficulty: tuning,
        seed: seed,
      );

      final out = <String>[];
      for (int tick = 1; tick <= 600; tick++) {
        final d = r.maybeDecide(tick: tick, agentId: 'ai-1', obs: obs);
        if (d != null) {
          out.add('${d.tick}:${d.action.type}:${d.meta['mode']}');
        }
      }
      return out;
    }

    expect(run(1), isNot(equals(run(2))));
  });
}
