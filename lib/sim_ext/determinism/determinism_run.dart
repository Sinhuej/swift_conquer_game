/// Represents a deterministic simulation run.
/// Used for validating replay, snapshot, and hash stability.
class DeterminismRun {
  final int seed;
  final String scenarioId;

  DeterminismRun({
    required this.seed,
    required this.scenarioId,
  });

  @override
  String toString() =>
      'DeterminismRun(seed=$seed, scenarioId=$scenarioId)';
}
