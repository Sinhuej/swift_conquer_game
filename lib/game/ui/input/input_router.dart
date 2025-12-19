typedef PointerId = int;

class InputRouter {
  double lastX = 0;
  double lastY = 0;

  void onTap(double x, double y) {
    lastX = x;
    lastY = y;
  }

  void onDrag(PointerId id, double x, double y) {
    lastX = x;
    lastY = y;
  }
}
