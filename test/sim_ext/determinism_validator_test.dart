import 'package:test/test.dart';
import 'package:swift_conquer_game/sim_ext/determinism/determinism_validator.dart';

void main() {
  test('DeterminismValidator passes identical snapshot streams', () {
    Map<int, Map<String, Object?>> run() => {
          0: {'tick': 0, 'state': {'a': 1}},
          10: {'tick': 10, 'state': {'a': 2}},
          20: {'tick': 20, 'state': {'a': 3}},
        };

    final res = DeterminismValidator.validate(runA: run, runB: run);
    expect(res.ok, isTrue, reason: res.message);
  });

  test('DeterminismValidator fails when snapshot differs', () {
    Map<int, Map<String, Object?>> runA() => {
          0: {'tick': 0, 'state': {'a': 1}},
          10: {'tick': 10, 'state': {'a': 2}},
        };

    Map<int, Map<String, Object?>> runB() => {
          0: {'tick': 0, 'state': {'a': 1}},
          10: {'tick': 10, 'state': {'a': 999}},
        };

    final res = DeterminismValidator.validate(runA: runA, runB: runB);
    expect(res.ok, isFalse);
  });
}
