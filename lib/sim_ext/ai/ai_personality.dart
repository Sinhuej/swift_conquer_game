/// Phase 102: AI personality knobs (data-only).
class AiPersonality {
  /// Higher = more likely to choose aggressive actions.
  final double aggression;

  /// Higher = more likely to invest in economy over combat.
  final double economyBias;

  /// Higher = more likely to accept risky moves.
  final double riskTolerance;

  const AiPersonality({
    required this.aggression,
    required this.economyBias,
    required this.riskTolerance,
  });

  static const AiPersonality balanced = AiPersonality(
    aggression: 0.5,
    economyBias: 0.5,
    riskTolerance: 0.5,
  );
}

enum AiDifficulty {
  easy,
  normal,
  hard,
}

class AiDifficultyTuning {
  final int thinkEveryTicks;
  final double randomness;

  const AiDifficultyTuning({
    required this.thinkEveryTicks,
    required this.randomness,
  });

  static AiDifficultyTuning forLevel(AiDifficulty d) {
    switch (d) {
      case AiDifficulty.easy:
        return const AiDifficultyTuning(thinkEveryTicks: 90, randomness: 0.30);
      case AiDifficulty.normal:
        return const AiDifficultyTuning(thinkEveryTicks: 60, randomness: 0.15);
      case AiDifficulty.hard:
        return const AiDifficultyTuning(thinkEveryTicks: 30, randomness: 0.05);
    }
  }
}
