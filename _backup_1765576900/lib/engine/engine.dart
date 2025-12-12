class GameEngine {
  final GameState state;
  GameEngine(this.state);

  void tick() {
    state.tickCount++;
  }
}
