class ReplayLog {
  final List<String> events = [];
  void record(String e) => events.add(e);
}
