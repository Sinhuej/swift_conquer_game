import 'behavior_event.dart';
import 'player_behavior_profile.dart';

double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

/// Phase 164–165: updates a PlayerBehaviorProfile from BehaviorEvents.
///
/// Uses simple heuristics:
/// - attackIssued early -> rushRate increases
/// - many idleTick -> turtleRate increases
/// - expandStarted -> expansionRate increases
/// - retreatIssued -> retreatRate increases
/// - techStarted -> techBias increases
class BehaviorAnalyzer {
  final PlayerBehaviorProfile profile;

  /// Consider "early game" threshold for rush detection.
  final int earlyTickThreshold;

  BehaviorAnalyzer({
    PlayerBehaviorProfile? profile,
    this.earlyTickThreshold = 600, // e.g., first 10 seconds @ 60tps
  }) : profile = profile ?? PlayerBehaviorProfile();

  void ingest(BehaviorEvent e) {
    switch (e.type) {
      case BehaviorEventType.attackIssued:
        // stronger signal early
        final earlyBoost = e.tick <= earlyTickThreshold ? 1.0 : 0.5;
        profile.rushRate.update(_clamp01(0.6 + 0.4 * earlyBoost));
        // attacking generally implies not turtling
        profile.turtleRate.update(0.2);
        break;

      case BehaviorEventType.retreatIssued:
        profile.retreatRate.update(1.0);
        // retreat implies risk-avoidant / not rushing
        profile.rushRate.update(0.2);
        break;

      case BehaviorEventType.expandStarted:
        profile.expansionRate.update(1.0);
        // expansion tends to reduce turtling
        profile.turtleRate.update(0.3);
        break;

      case BehaviorEventType.techStarted:
        profile.techBias.update(1.0);
        break;

      case BehaviorEventType.idleTick:
        profile.turtleRate.update(1.0);
        break;

      case BehaviorEventType.moveIssued:
        // movement reduces turtle slightly
        profile.turtleRate.update(0.4);
        break;
    }
  }
}
