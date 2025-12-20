import '../../sim_ext/ai_integration/command_sink.dart';
import '../../sim_ext/ai_wiring/command_envelope.dart';

/// Temporary sink: logs commands so we can prove UI -> envelope works
/// without touching the frozen engine.
class DevCommandSink implements CommandSink {
  @override
  void submit(CommandEnvelope command) {
    // ignore: avoid_print
    print('[UI COMMAND] $command');
  }
}
