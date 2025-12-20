typedef GameEvent = Object;

class EventQueue {
  final List<GameEvent> _events = [];

  void push(GameEvent e) => _events.add(e);

  List<GameEvent> drain() {
    if (_events.isEmpty) return const [];
    final out = List<GameEvent>.from(_events);
    _events.clear();
    return out;
  }

  bool get isEmpty => _events.isEmpty;
  int get length => _events.length;
}
