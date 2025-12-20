class RunMeta {
  final String runId;
  final int seed;
  final String scenarioId;

  /// Optional / informational only. Must never influence sim determinism.
  final String? buildLabel;

  const RunMeta({
    required this.runId,
    required this.seed,
    required this.scenarioId,
    this.buildLabel,
  });

  Map<String, Object?> toJson() => <String, Object?>{
        'runId': runId,
        'seed': seed,
        'scenarioId': scenarioId,
        'buildLabel': buildLabel,
      };

  @override
  String toString() =>
      'RunMeta(runId=$runId, seed=$seed, scenarioId=$scenarioId, buildLabel=$buildLabel)';
}
