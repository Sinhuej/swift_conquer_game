import '../observability/sim_hasher.dart';

class DeterminismResult {
  final bool ok;
  final String message;

  const DeterminismResult._(this.ok, this.message);

  factory DeterminismResult.pass(String msg) => DeterminismResult._(true, msg);
  factory DeterminismResult.fail(String msg) => DeterminismResult._(false, msg);
}

typedef RunAndGetSnapshots = Map<int, Map<String, Object?>> Function();

class DeterminismValidator {
  /// Compare two runs by snapshot-json at the same tick keys.
  /// You provide two functions that execute a run and return:
  ///   tick -> snapshotJson
  static DeterminismResult validate({
    required RunAndGetSnapshots runA,
    required RunAndGetSnapshots runB,
  }) {
    final a = runA();
    final b = runB();

    final ticks = <int>{...a.keys, ...b.keys}.toList()..sort();
    for (final t in ticks) {
      final sa = a[t];
      final sb = b[t];
      if (sa == null || sb == null) {
        return DeterminismResult.fail(
          'Snapshot mismatch: tick=$t missing in ${sa == null ? "A" : ""}${sb == null ? "B" : ""}',
        );
      }
      final ha = SimHasher.stableHash(sa);
      final hb = SimHasher.stableHash(sb);
      if (ha != hb) {
        return DeterminismResult.fail(
          'Determinism fail at tick=$t (hashA=$ha hashB=$hb)',
        );
      }
    }

    return DeterminismResult.pass('Determinism OK at ${ticks.length} checkpoints');
  }
}
