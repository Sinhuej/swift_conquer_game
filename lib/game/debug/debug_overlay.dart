class DebugOverlayState {
  int entityCount = 0;
  double lastDt = 0;

  void update({required int entityCount, required double dt}) {
    this.entityCount = entityCount;
    lastDt = dt;
  }
}
