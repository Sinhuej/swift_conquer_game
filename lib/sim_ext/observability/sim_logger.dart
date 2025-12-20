import 'sim_log_entry.dart';

class SimLogger {
  final int capacity;

  final List<SimLogEntry> _buffer;
  int _start = 0;
  int _length = 0;

  SimLogger({this.capacity = 5000}) : _buffer = List.filled(capacity, _sentinel);

  static const SimLogEntry _sentinel = SimLogEntry(
    tick: -1,
    category: 'SYS',
    message: 'SENTINEL',
  );

  int get length => _length;
  bool get isEmpty => _length == 0;

  void clear() {
    _start = 0;
    _length = 0;
  }

  void add(SimLogEntry entry) {
    if (capacity <= 0) return;

    if (_length < capacity) {
      _buffer[(_start + _length) % capacity] = entry;
      _length++;
    } else {
      // Overwrite oldest
      _buffer[_start] = entry;
      _start = (_start + 1) % capacity;
    }
  }

  List<SimLogEntry> lastN(int n) {
    if (n <= 0 || _length == 0) return const [];
    final count = n > _length ? _length : n;
    final result = <SimLogEntry>[];

    // read last `count` in order
    final startIndex = (_start + (_length - count)) % capacity;
    for (var i = 0; i < count; i++) {
      result.add(_buffer[(startIndex + i) % capacity]);
    }
    return result;
  }

  List<SimLogEntry> toList() {
    if (_length == 0) return const [];
    final result = <SimLogEntry>[];
    for (var i = 0; i < _length; i++) {
      result.add(_buffer[(_start + i) % capacity]);
    }
    return result;
  }
}
