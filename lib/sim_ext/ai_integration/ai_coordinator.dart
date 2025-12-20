import '../ai/ai_runner.dart';
import '../ai/ai_types.dart';
import '../ai_wiring/command_envelope.dart';
import 'ai_injection_driver.dart';
import 'command_sink.dart';

/// Phase 154: Coordinates multiple agents safely (headless).
class AiCoordinator {
  final Map<String, AiInjectionDriver> _drivers = {};

  void register({
    required String agentId,
    required AiRunner runner,
  }) {
    _drivers[agentId] = AiInjectionDriver(runner: runner, agentId: agentId);
  }

  /// Runs injection for all agents for a single tick.
  List<CommandEnvelope> tickAll({
    required int tick,
    required Map<String, AiObservation> observationsByAgent,
    required CommandSink sink,
  }) {
    final out = <CommandEnvelope>[];

    final ids = _drivers.keys.toList()..sort();
    for (final id in ids) {
      final driver = _drivers[id]!;
      final obs = observationsByAgent[id];
      if (obs == null) continue;

      final env = driver.tick(tick: tick, obs: obs, sink: sink);
      if (env != null) out.add(env);
    }

    return out;
  }
}
