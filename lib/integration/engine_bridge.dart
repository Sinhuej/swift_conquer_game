class EngineBridge {
  Future<void> initialize() async {}
  void update(double dt) {}
  List<UnitStub> getUnits() => [];
  void selectAt(double x, double y) {}
  void issueMove(double x, double y) {}
}

class UnitStub {
  UnitStub(this.position);
  final PositionStub position;
}

class PositionStub {
  PositionStub(this.x, this.y);
  final double x;
  final double y;
}
