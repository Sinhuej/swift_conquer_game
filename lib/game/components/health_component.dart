class HealthComponent {
  double maxHp;
  double hp;

  HealthComponent(this.maxHp) : hp = maxHp;

  bool get isAlive => hp > 0;

  void damage(double amount) {
    hp -= amount;
    if (hp < 0) hp = 0;
  }
}
