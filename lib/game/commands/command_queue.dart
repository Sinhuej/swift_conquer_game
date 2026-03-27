class CommandQueue {
  final List<dynamic> _queue = [];

  void push(dynamic cmd) => _queue.add(cmd);
  bool get isEmpty => _queue.isEmpty;
  dynamic pop() => _queue.removeAt(0);
}
