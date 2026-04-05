import 'package:flutter/material.dart';

class BookingProvider extends ChangeNotifier {
  DateTime selectedDate = DateTime.now();
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  List<Map<String, dynamic>> vehicles = [];
  List<Map<String, dynamic>> pricing = [];

  void setPricing(List<Map<String, dynamic>> data) {
    pricing = data;

    vehicles = [
      {
        "type": data.isNotEmpty ? data.first['type'] : "",
        "controller": TextEditingController(),
      },
    ];

    notifyListeners();
  }

  void addVehicle() {
    vehicles.add({
      "type": pricing.isNotEmpty ? pricing.first['type'] : "",
      "controller": TextEditingController(),
    });
    notifyListeners();
  }

  void removeVehicle(int index) {
    if (vehicles.length > 1) {
      vehicles[index]["controller"].dispose();
      vehicles.removeAt(index);
      notifyListeners();
    }
  }

  void updateVehicleType(int index, String type) {
    vehicles[index]["type"] = type;
    notifyListeners();
  }

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

    if (end.isBefore(start)) return 0;

    return end.difference(start).inMinutes / 60;
  }

  double getVehicleAmount(String type) {
    double hours = getDuration();

    final priceData = pricing.firstWhere(
      (e) => e['type'] == type,
      orElse: () => {},
    );

    double price = (priceData['rate_per_hour'] ?? 0).toDouble();

    return price * hours;
  }

  double getTotalAmount() {
    double total = 0;

    for (var v in vehicles) {
      total += getVehicleAmount(v["type"]);
    }

    return total;
  }

  String? validate() {
    if (startTime == null || endTime == null) {
      return "Select time";
    }

    if (getDuration() <= 0) {
      return "Invalid time selection";
    }

    for (var v in vehicles) {
      if (v["controller"].text.trim().isEmpty) {
        return "Enter all vehicle numbers";
      }
    }

    return null;
  }

  Map<String, dynamic> getBookingData(BuildContext context) {
    return {
      "date": selectedDate,
      "startTime": startTime!.format(context),
      "endTime": endTime!.format(context),
      "duration": getDuration(),
      "total": getTotalAmount(),
      "vehicles": vehicles.map((v) {
        return {"type": v["type"], "number": v["controller"].text.trim()};
      }).toList(),
    };
  }
}
