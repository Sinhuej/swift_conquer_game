import '../ai/ai_runner.dart';
import '../ai/ai_types.dart';
import '../ai_wiring/ai_command_mapper.dart';
import '../ai_wiring/command_envelope.dart';
import 'command_sink.dart';

/// Phase 152–153: Drives AI on cadence and emits CommandEnvelopes to a sink.
/// This stays engine-agnostic by design.
class AiInjectionDriver {
  final AiRunner runner;
  final String agentId;

  AiInjectionDriver({
    required this.runner,
    required this.agentId,
  });

  /// Runs one tick worth of injection.
  ///
  /// Returns the emitted envelope if any.
  CommandEnvelope? tick({
    required int tick,
    required AiObservation obs,
    required CommandSink sink,
  }) {
    final decision = runner.maybeDecide(
      tick: tick,
      agentId: agentId,
      obs: obs,
    );

    if (decision == null) return null;

    final envelope = AiCommandMapper.map(decision);
    sink.submit(envelope);
    return envelope;
  }
}
