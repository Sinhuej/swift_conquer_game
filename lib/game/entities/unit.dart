class Unit {
  final int id;
  int owner;
  double x;
  double y;
  double hp;
  double attack;

  Unit({
    required this.id,
    required this.owner,
    required this.x,
    required this.y,
    this.hp = 100,
    this.attack = 10,
  });

  bool get isAlive => hp > 0;
}
