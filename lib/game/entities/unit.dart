class Unit {
  final int id;
  double x;
  double y;
  double speed;

  double? targetX;
  double? targetY;

  Unit({
    required this.id,
    required this.x,
    required this.y,
    this.speed = 60,
  });
}
