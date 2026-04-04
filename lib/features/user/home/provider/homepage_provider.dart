import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class HomepageProvider extends ChangeNotifier {
  Position? currentPosition;

  List<Map<String, dynamic>> nearByParking = [];
  List<Map<String, dynamic>> allParking = [];

  TextEditingController searchController = TextEditingController();

  bool isLoading = false;
  String? error;
  String? currentLocationName;
  String? selectedLocationName;

  String searchQuery = "";

  void setSearch(String value) async {
    if (value.trim().isNotEmpty) {
      isLoading = true;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 400));
    }
    searchQuery = value.toLowerCase();
    if (value.trim().isNotEmpty) {
      selectedLocationName = value;
    } else {
      selectedLocationName = currentLocationName;
    }
    isLoading = false;
    notifyListeners();
  }

  List<Map<String, dynamic>> get filteredParkings {
    if (searchQuery.isNotEmpty) {
      return allParking.where((parking) {
        final name = (parking['name'] ?? "").toString().toLowerCase();
        final city = (parking['city'] ?? "").toString().toLowerCase();
        final address = (parking['address'] ?? "").toString().toLowerCase();
        final location = (parking['locationName'] ?? "")
            .toString()
            .toLowerCase();

        return name.contains(searchQuery) ||
            city.contains(searchQuery) ||
            address.contains(searchQuery) ||
            location.contains(searchQuery);
      }).toList();
    }

    return nearByParking;
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoading = true;
      notifyListeners();

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        error = "Location services disabled";
        currentLocationName = "Enable Location";
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        error = "Location permission permanently denied";
        currentLocationName = "Permission Denied";
        return;
      }

      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        currentPosition!.latitude,
        currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        currentLocationName =
            "${place.locality ?? ""}, ${place.administrativeArea ?? ""}";
        selectedLocationName = currentLocationName;
      } else {
        currentLocationName = "Unknown Location";
      }

      error = null;
    } catch (e) {
      error = "Failed to get location";
      currentLocationName = "Error getting location";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371;

    double dLat = _deg2rad(lat2 - lat1);
    double dLon = _deg2rad(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  Future<void> fetchNearbyParking() async {
    if (currentPosition == null) return;

    try {
      isLoading = true;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('parking_places')
          .get();

      List<Map<String, dynamic>> tempNearby = [];
      List<Map<String, dynamic>> tempAll = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        if (data['location'] == null) continue;

        final geo = data['location'] as GeoPoint;

        double distance = calculateDistance(
          currentPosition!.latitude,
          currentPosition!.longitude,
          geo.latitude,
          geo.longitude,
        );

        final item = {...data, "distance": distance, "docId": doc.id};

        tempAll.add(item);

        if (distance <= 2) {
          tempNearby.add(item);
        }
      }

      tempNearby.sort((a, b) => a['distance'].compareTo(b['distance']));

      allParking = tempAll;
      nearByParking = tempNearby;

      error = null;
    } catch (e) {
      error = "Failed to load parkings";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> init() async {
    await getCurrentLocation();
    await fetchNearbyParking();
  }
}
