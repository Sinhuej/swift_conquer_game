class CommandPanel {
  final List<String> log = [];

  void push(String msg) {
    log.add(msg);
    if (log.length > 50) log.removeAt(0);
  }
}
