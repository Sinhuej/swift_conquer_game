class MinimapModel {
  double viewX = 0;
  double viewY = 0;
  double viewW = 1;
  double viewH = 1;

  void setView(double x, double y, double w, double h) {
    viewX = x; viewY = y; viewW = w; viewH = h;
  }
}
