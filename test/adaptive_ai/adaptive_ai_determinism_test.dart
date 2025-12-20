import 'package:test/test.dart';

import 'package:swift_conquer_game/sim_ext/adaptive_ai/behavior_analyzer.dart';
import 'package:swift_conquer_game/sim_ext/adaptive_ai/behavior_event.dart';
import 'package:swift_conquer_game/sim_ext/adaptive_ai/adaptation_policy.dart';
import 'package:swift_conquer_game/sim_ext/adaptive_ai/personality_applier.dart';
import 'package:swift_conquer_game/sim_ext/ai/ai_personality.dart';

void main() {
  test('Adaptive AI produces identical deltas for identical event streams', () {
    List<double> run() {
      final analyzer = BehaviorAnalyzer(earlyTickThreshold: 120);
      final policy = AdaptationPolicy(maxDelta: 0.10);
      final applier = PersonalityApplier(smoothing: 0.25);

      var personality = AiPersonality.balanced;

      final events = <BehaviorEvent>[
        const BehaviorEvent(tick: 10, type: BehaviorEventType.attackIssued),
        const BehaviorEvent(tick: 20, type: BehaviorEventType.moveIssued),
        const BehaviorEvent(tick: 40, type: BehaviorEventType.attackIssued),
        const BehaviorEvent(tick: 70, type: BehaviorEventType.retreatIssued),
        const BehaviorEvent(tick: 100, type: BehaviorEventType.expandStarted),
        const BehaviorEvent(tick: 130, type: BehaviorEventType.techStarted),
      ];

      for (final e in events) {
        analyzer.ingest(e);
      }

      final delta = policy.compute(analyzer.profile);
      personality = applier.apply(current: personality, delta: delta);

      return [
        analyzer.profile.rushRate.value,
        analyzer.profile.turtleRate.value,
        analyzer.profile.expansionRate.value,
        analyzer.profile.retreatRate.value,
        analyzer.profile.techBias.value,
        personality.aggression,
        personality.economyBias,
        personality.riskTolerance,
      ];
    }

    expect(run(), equals(run()));
  });
}
