class ModelFloor {
  String floorName;
  List<VehicleSlot> vehicles;

  ModelFloor({required this.floorName, required this.vehicles});
}

class VehicleSlot {
  String type;
  int slots;

  VehicleSlot({required this.type, required this.slots});
}
