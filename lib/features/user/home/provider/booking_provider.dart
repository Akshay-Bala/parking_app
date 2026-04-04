import 'package:flutter/material.dart';

class BookingProvider extends ChangeNotifier {
  /// ---------------- STATE ----------------
  DateTime selectedDate = DateTime.now();
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  List<Map<String, dynamic>> vehicles = [
    {"type": "Two Wheeler", "controller": TextEditingController()},
  ];

  List<Map<String, dynamic>> pricing = [];

  /// ---------------- INIT ----------------
  void setPricing(List<Map<String, dynamic>> data) {
    pricing = data;
    notifyListeners();
  }

  /// ---------------- VEHICLE ----------------
  void addVehicle() {
    vehicles.add({
      "type": "Two Wheeler",
      "controller": TextEditingController(),
    });
    notifyListeners();
  }

  void removeVehicle(int index) {
    vehicles.removeAt(index);
    notifyListeners();
  }

  void updateVehicleType(int index, String type) {
    vehicles[index]["type"] = type;
    notifyListeners();
  }

  /// ---------------- DATE & TIME ----------------
  void setDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void setStartTime(TimeOfDay time) {
    startTime = time;
    notifyListeners();
  }

  void setEndTime(TimeOfDay time) {
    endTime = time;
    notifyListeners();
  }

  /// ---------------- CALCULATION ----------------
  double getDuration() {
    if (startTime == null || endTime == null) return 0;

    final start = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      startTime!.hour,
      startTime!.minute,
    );

    final end = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      endTime!.hour,
      endTime!.minute,
    );

    return end.difference(start).inMinutes / 60;
  }

  double getVehicleAmount(String type) {
    double hours = getDuration();

    final priceData = pricing.firstWhere(
          (e) => e['type'] == type,
      orElse: () => {},
    );

    double price = (priceData['hour'] ?? 0).toDouble();

    return price * hours;
  }

  double getTotalAmount() {
    double total = 0;

    for (var v in vehicles) {
      total += getVehicleAmount(v["type"]);
    }

    return total;
  }

  /// ---------------- VALIDATION ----------------
  String? validate() {
    if (startTime == null || endTime == null) {
      return "Select time";
    }

    for (var v in vehicles) {
      if (v["controller"].text.isEmpty) {
        return "Enter all vehicle numbers";
      }
    }

    return null;
  }

  /// ---------------- BOOK ----------------
  Map<String, dynamic> getBookingData(BuildContext context) {
    return {
      "date": selectedDate,
      "startTime": startTime!.format(context),
      "endTime": endTime!.format(context),
      "duration": getDuration(),
      "total": getTotalAmount(),
      "vehicles": vehicles.map((v) {
        return {
          "type": v["type"],
          "number": v["controller"].text,
        };
      }).toList(),
    };
  }
}