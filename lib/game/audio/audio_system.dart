class AudioSystem {
  bool enabled = true;

  void play(String sfxId) {
    if (!enabled) return;
    // Later: hook Flame Audio or another solution
  }
}
