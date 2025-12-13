class Attack {
  final int damage;
  final double range;
  final double cooldown; // seconds per hit
  double _cdLeft = 0;

  Attack({
    required this.damage,
    required this.range,
    required this.cooldown,
  });

  bool get ready => _cdLeft <= 0;

  void tick(double dt) {
    if (_cdLeft > 0) _cdLeft -= dt;
    if (_cdLeft < 0) _cdLeft = 0;
  }

  void trigger() {
    _cdLeft = cooldown;
  }
}
