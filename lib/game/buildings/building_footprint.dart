import 'building_type.dart';

class BuildingFootprint {
  final int cols;
  final int rows;

  const BuildingFootprint(this.cols, this.rows);
}

BuildingFootprint footprintFor(BuildingType type) {
  switch (type) {
    case BuildingType.mobileHqCenter:
      return const BuildingFootprint(1, 1);
    case BuildingType.hq:
      return const BuildingFootprint(3, 3);
    case BuildingType.powerPlant:
      return const BuildingFootprint(2, 2);
    case BuildingType.barracks:
      return const BuildingFootprint(2, 2);
    case BuildingType.refinery:
      return const BuildingFootprint(3, 2);
    case BuildingType.warFactory:
      return const BuildingFootprint(3, 2);
  }
}
