import 'golden_run.dart';

class DeterminismRegressionGuard {
  static void verify(String actual, GoldenRun golden) {
    if (actual != golden.hash) {
      throw StateError('Determinism regression for seed ${golden.seed}');
    }
  }
}
