class HealthComponent {
  double maxHealth;
  double currentHealth;

  HealthComponent({required this.maxHealth})
      : currentHealth = maxHealth;

  bool get isAlive => currentHealth > 0;

  void damage(double amount) {
    currentHealth -= amount;
    if (currentHealth < 0) currentHealth = 0;
  }
}
