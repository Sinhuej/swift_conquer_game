import '../buildings/building_type.dart';

class BuildMode {
  BuildingType? pendingType;

  bool get isActive => pendingType != null;

  void select(BuildingType type) {
    pendingType = type;
  }

  void clear() {
    pendingType = null;
  }
}
