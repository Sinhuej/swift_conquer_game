class TimeController {
  double _timeScale = 1.0;

  double get timeScale => _timeScale;

  void setNormal() {
    _timeScale = 1.0;
  }

  void setPaused() {
    _timeScale = 0.0;
  }

  void setFast(double multiplier) {
    if (multiplier <= 0) {
      _timeScale = 1.0;
    } else {
      _timeScale = multiplier;
    }
  }

  double apply(double dt) {
    return dt * _timeScale;
  }
}
