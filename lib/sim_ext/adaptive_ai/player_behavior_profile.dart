import 'rolling_stat.dart';

/// Phase 161–162: summary of observed player behavior (0..1).
///
/// Values are rolling averages updated from events by BehaviorAnalyzer.
class PlayerBehaviorProfile {
  final RollingStat rushRate;       // early aggression / early attacks
  final RollingStat turtleRate;     // defensive posture / low movement
  final RollingStat expansionRate;  // expansion behavior
  final RollingStat retreatRate;    // retreats / disengage tendency
  final RollingStat techBias;       // teching vs fighting

  PlayerBehaviorProfile({
    RollingStat? rushRate,
    RollingStat? turtleRate,
    RollingStat? expansionRate,
    RollingStat? retreatRate,
    RollingStat? techBias,
  })  : rushRate = rushRate ?? RollingStat(alpha: 0.05),
        turtleRate = turtleRate ?? RollingStat(alpha: 0.05),
        expansionRate = expansionRate ?? RollingStat(alpha: 0.05),
        retreatRate = retreatRate ?? RollingStat(alpha: 0.05),
        techBias = techBias ?? RollingStat(alpha: 0.05);

  Map<String, Object?> toJson() => {
        'rushRate': rushRate.toJson(),
        'turtleRate': turtleRate.toJson(),
        'expansionRate': expansionRate.toJson(),
        'retreatRate': retreatRate.toJson(),
        'techBias': techBias.toJson(),
      };
}
