import 'unit_intent.dart';

class IntentQueue {
  final List<UnitIntent> _queue = [];

  void add(UnitIntent intent) {
    _queue.add(intent);
  }

  List<UnitIntent> drain() {
    _queue.sort((a, b) => a.actor.value.compareTo(b.actor.value));
    final out = List<UnitIntent>.from(_queue);
    _queue.clear();
    return out;
  }

  bool get isEmpty => _queue.isEmpty;
}
