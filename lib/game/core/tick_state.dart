class TickState {
  int tick = 0;
  double simTime = 0.0;

  void advance(double dt) {
    tick += 1;
    simTime += dt;
  }
}
