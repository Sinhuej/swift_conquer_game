class TickState {
  int tick;
  double simTimeSeconds;

  TickState({this.tick = 0, this.simTimeSeconds = 0});

  @override
  String toString() => 'TickState(tick=$tick, t=$simTimeSeconds)';
}
