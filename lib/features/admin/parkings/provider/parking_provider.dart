import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:parking_app/features/admin/parkings/models/model_vehicle_price.dart';

class ParkingProvider extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController priceHour = TextEditingController();
  TextEditingController priceDay = TextEditingController();
  TextEditingController priceMonth = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  void setSearch(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    notifyListeners();

    _debounce = Timer(const Duration(seconds: 2), () {
      searchQuery = value.toLowerCase().trim();
      notifyListeners();
    });
  }

  Timer? _debounce;

  bool is24Hours = false;
  bool cctv = false;
  bool security = false;
  bool covered = false;

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  List<String> selectedDays = [];
  List<VehiclePricing> vehicles = [];

  double? latitude;
  double? longitude;
  String? locationName;

  void addEmptyVehicle(BuildContext context) {
    final allTypes = ['Two Wheeler', 'Four Wheeler', 'Other'];

    final usedTypes = vehicles.map((e) => e.type).toSet();

    final availableTypes = allTypes
        .where((t) => !usedTypes.contains(t))
        .toList();

    if (availableTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All vehicle types already added")),
      );
      return;
    }

    vehicles.add(
      VehiclePricing(
        type: availableTypes.first,
        slots: 0,
        balanceSlots: 0,
        hour: 0,
        day: 0,
        month: 0,
      ),
    );

    notifyListeners();
  }

  void notifyListen(){
    notifyListeners();
  }

  void updateVehicleAt(int index, VehiclePricing vehicle) {
    if (index < 0 || index >= vehicles.length) return;
    vehicles[index] = vehicle;
    notifyListeners();
  }

  void removeVehicleAt(int index) {
    if (index < 0 || index >= vehicles.length) return;
    vehicles.removeAt(index);
    notifyListeners();
  }

  int get totalSlotsCount {
    return vehicles.fold(0, (sum, v) => sum + (v.slots));
  }

  bool validateVehicles() {
    if (vehicles.isEmpty) return false;
    for (final v in vehicles) {
      if (v.type.trim().isEmpty) return false;
      if (v.slots < 0) return false;
      if (v.hour < 0 || v.day < 0 || v.month < 0) return false;
    }
    return true;
  }

  void addVehicle(VehiclePricing vehicle) {
    vehicles.removeWhere((v) => v.type == vehicle.type);
    vehicles.add(vehicle);
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery = "";
    notifyListeners();
  }

  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }

  void toggleDay(String day) {
    if (selectedDays.contains(day)) {
      selectedDays.remove(day);
    } else {
      selectedDays.add(day);
    }
    notifyListeners();
  }

  String get displayDays {
    return selectedDays.join(", ");
  }

  Future<void> setLocation(double lat, double lng) async {
    latitude = lat;
    longitude = lng;

    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        locationName =
            "${place.name}, ${place.locality}, ${place.administrativeArea}";
      }
    } catch (e) {
      locationName = "Unknown Location";
    }

    notifyListeners();
  }

  bool isLoading = false;

  Stream<QuerySnapshot> getMyParkingStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('parking_slots')
        .where('adminId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> addParking(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;

    if (latitude == null || longitude == null) {
      _showError(context, "Please select location from map");
      return false;
    }

    if (vehicles.isEmpty) {
      _showError(context, "Add at least one vehicle type");
      return false;
    }

    if (!validateVehicles()) {
      _showError(context, "Please fill valid vehicle slots and rates");
      return false;
    }

    if (!is24Hours) {
      if (startTime == null || endTime == null) {
        _showError(context, "Please select start and end time");
        return false;
      }
    }

    if (selectedDays.isEmpty) {
      _showError(context, "Select at least one day");
      return false;
    }
    try {
      isLoading = true;
      notifyListeners();

      final vehiclePayload = vehicles.map((v) => v.toJson()).toList();
      final total = totalSlotsCount;

      await FirebaseFirestore.instance.collection('parking_slots').add({
        "parking_name": name.text,
        "description": description.text,
        "address": address.text,
        "city": city.text,
        "vehicles": vehiclePayload,

        "total_slots": total,
        "available_slots": total,

        "location": GeoPoint(latitude!, longitude!),
        "locationName": locationName ?? "",

        "timing": {
          "is24": is24Hours,
          "start": startTime != null ? formatTime(startTime!) : "",
          "end": endTime != null ? formatTime(endTime!) : "",
        },

        "days": selectedDays,

        "facilities": {"cctv": cctv, "security": security, "covered": covered},

        "contact": contact.text,
        "adminId": FirebaseAuth.instance.currentUser!.uid,
        "createdAt": FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print("Exception in Adding parking slots");
      _showError(context, "Something went wrong");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
      clearForm();
    }
  }

  void clearForm() {
    name.clear();
    description.clear();
    address.clear();
    city.clear();
    contact.clear();

    vehicles.clear();

    latitude = null;
    longitude = null;
    locationName = null;

    startTime = null;
    endTime = null;
    is24Hours = false;

    selectedDays.clear();

    cctv = false;
    security = false;
    covered = false;

    notifyListeners();
  }

  bool isParkingActive(Map<String, dynamic> data) {
    try {
      final timing = data['timing'];
      final days = List<String>.from(data['days'] ?? []);

      final now = DateTime.now();
      final currentDay = _getDayShort(now.weekday);

      if (!days.contains(currentDay)) return false;

      if (timing['is24'] == true) return true;

      final start = timing['start'];
      final end = timing['end'];

      if (start == null || end == null || start.isEmpty || end.isEmpty) {
        return false;
      }

      final startTime = _parseTime(start);
      final endTime = _parseTime(end);

      final nowMinutes = now.hour * 60 + now.minute;
      final startMinutes = startTime.hour * 60 + startTime.minute;
      final endMinutes = endTime.hour * 60 + endTime.minute;

      return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
    } catch (e) {
      return false;
    }
  }

  String _getDayShort(int weekday) {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days[weekday - 1];
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(" ");
    final timePart = parts[0];
    final period = parts[1];

    final split = timePart.split(":");
    int hour = int.parse(split[0]);
    int minute = int.parse(split[1]);

    if (period == "PM" && hour != 12) hour += 12;
    if (period == "AM" && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }
}
