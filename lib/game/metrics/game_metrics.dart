class GameMetrics {
  int ticks = 0;
  int entitiesCreated = 0;
  int entitiesDestroyed = 0;

  void onTick() => ticks++;
}
