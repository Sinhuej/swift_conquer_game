class Health {
  int hp;
  final int maxHp;
  Health(this.hp, this.maxHp);

  bool get isDead => hp <= 0;
  void damage(int amount) {
    hp -= amount;
    if (hp < 0) hp = 0;
  }
}
