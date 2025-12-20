import 'replay_event.dart';

class ReplayBuffer {
  final List<ReplayEvent> _events = [];

  void record(ReplayEvent event) {
    _events.add(event);
  }

  List<ReplayEvent> get events =>
      List.unmodifiable(_events);

  Map<String, Object?> toJson() => {
        'events': _events.map((e) => e.toJson()).toList(),
      };
}
