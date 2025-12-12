class GameEngine {
  int tick = 0;
  bool running = false;

  void start() {
    running = true;
  }

  void stop() {
    running = false;
  }

  void update() {
    if (!running) return;
    tick++;
  }
}
