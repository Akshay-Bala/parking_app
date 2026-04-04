import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/const/constants.dart';

class MapPickerPage extends StatefulWidget {
  final double initialLat;
  final double initialLng;

  const MapPickerPage({
    super.key,
    required this.initialLat,
    required this.initialLng,
  });

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final TextEditingController searchController = TextEditingController();
  final MapController mapController = MapController();

  LatLng? selectedLatLng;
  LatLng? currentLatLng;
  bool isLoading = false;

  Future<void> searchPlace(String place) async {
    if (place.isEmpty) return;

    List<Location> locations = await locationFromAddress(place);

    if (locations.isNotEmpty) {
      final latlng = LatLng(
        locations.first.latitude,
        locations.first.longitude,
      );

      mapController.move(latlng, 15);
    }
  }

  Future<void> getCurrentLocation() async {
    setState(() => isLoading = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      setState(() => isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => isLoading = false);
      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    final latlng = LatLng(position.latitude, position.longitude);

    setState(() {
      selectedLatLng = latlng;
      isLoading = false;
    });

    mapController.move(latlng, 16);
  }

  void onMapTapped(LatLng latlng) {
    setState(() {
      selectedLatLng = latlng;
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Location"),
        content: Text(
          "Latitude: ${latlng.latitude}\nLongitude: ${latlng.longitude}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, latlng);
            },
            child: const Text("Select"),
          ),
        ],
      ),
    );
  }

  Future<void> loadCurrentLocation() async {
    setState(() => isLoading = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      setState(() => isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => isLoading = false);
      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    final latlng = LatLng(position.latitude, position.longitude);

    setState(() {
      currentLatLng = latlng;
      selectedLatLng = latlng;
      isLoading = false;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      mapController.move(latlng, 16);
    });
  }

  @override
  void initState() {
    super.initState();

    final latlng = LatLng(widget.initialLat, widget.initialLng);

    currentLatLng = latlng;
    selectedLatLng = latlng;

    Future.delayed(const Duration(milliseconds: 300), () {
      mapController.move(latlng, 16);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
        backgroundColor: const Color(0xFF2563EB),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search place",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => searchPlace(searchController.text),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                ),
                onPressed: getCurrentLocation,
                icon: const Icon(Icons.my_location, color: Colors.white),
                label: const Text(
                  "Use Current Location",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: currentLatLng ?? LatLng(11.2588, 75.7804),
                      initialZoom: 13,
                      onTap: (tapPosition, latlng) => onMapTapped(latlng),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: mapUrlPlaceTemplate,
                        userAgentPackageName: "com.example.parking_app",
                      ),
                      TileLayer(
                        urlTemplate: mapUrlTemplate,
                        userAgentPackageName: "com.example.parking_app",
                      ),

                      if (selectedLatLng != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: selectedLatLng!,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
