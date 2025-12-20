import 'command_envelope.dart';

/// Phase 126–127: A minimal command queue for headless pipelines.
/// This is not your game command queue; it is a staging queue for AI.
class AiCommandQueue {
  final List<CommandEnvelope> _items = [];

  void push(CommandEnvelope c) => _items.add(c);

  List<CommandEnvelope> drain() {
    final out = List<CommandEnvelope>.from(_items);
    _items.clear();
    return out;
  }

  int get length => _items.length;
}
