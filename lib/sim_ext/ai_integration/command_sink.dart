import '../ai_wiring/command_envelope.dart';

/// Phase 151: Engine-facing sink interface.
///
/// This avoids importing game/commands to keep CI safe.
/// Your real adapter will implement this and forward to CommandQueue/IntentQueue.
abstract class CommandSink {
  void submit(CommandEnvelope command);
}
