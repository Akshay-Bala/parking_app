import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ParkingDetailsPage extends StatelessWidget {
  final Map<String, dynamic> data;

  IconData getVehicleIcon(String type) {
    switch (type.toLowerCase()) {
      case "two wheeler":
        return Icons.two_wheeler;

      case "four wheeler":
        return Icons.directions_car;

      case "ev":
        return Icons.ev_station;

      case "other heavy vehicles":
        return Icons.local_shipping;

      default:
        return Icons.directions_car;
    }
  }

  Future<void> openMap() async {
    try {
      final query = Uri.encodeComponent(
        data['locationName'] ?? "${data['address']} ${data['city']}",
      );

      final uri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$query",
      );

      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print("Map launch error: $e");
    }
  }

  Future<void> callNumber() async {
    final phone = data['contact'].toString();

    final uri = Uri.parse("tel:$phone");

    await launchUrl(uri);
  }

  const ParkingDetailsPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final vehicles = List<Map<String, dynamic>>.from(data['vehicles'] ?? []);
    final facilities = data['facilities'] ?? {};
    final timing = data['timing'] ?? {};
    final location = data['location'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        title: Text(data['name']),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['locationName'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        data['city'],
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _highlightBox("Total", data['totalSlots'], Colors.blue),
                      const SizedBox(width: 10),
                      _highlightBox(
                        "Available",
                        data['availableSlots'],
                        Colors.green,
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  _sectionCard(
                    "About Parking",
                    Icons.description,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['description']),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            InkWell(
                              onTap: callNumber,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF2563EB,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.call,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                data['contact'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),

                  _sectionCard(
                    "Location",
                    Icons.location_on,
                    InkWell(
                      onTap: openMap,
                      borderRadius: BorderRadius.circular(10),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.map,
                              color: Color(0xFF2563EB),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['locationName'] ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Click to find the location",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),

                  _sectionCard(
                    "Timing",
                    Icons.access_time,
                    timing['is24']
                        ? const Text("Open 24 Hours")
                        : Text("${timing['start']} - ${timing['end']}"),
                  ),

                  _sectionCard(
                    "Available Days",
                    Icons.calendar_today,
                    Wrap(
                      spacing: 8,
                      children: (data['days'] as List)
                          .map((d) => Chip(label: Text(d)))
                          .toList(),
                    ),
                  ),

                  _sectionCard(
                    "Vehicle Pricing",
                    Icons.directions_car,
                    Column(
                      children: vehicles.map((v) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    getVehicleIcon(v['type']),
                                    color: const Color(0xFF2563EB),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    v['type'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              Wrap(
                                spacing: 10,
                                children: [
                                  _priceChip("Hr", v['hour']),
                                  _priceChip("Day", v['day']),
                                  _priceChip("Month", v['month']),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  _sectionCard(
                    "Facilities",
                    Icons.miscellaneous_services,
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _facilityChip("CCTV", facilities['cctv']),
                        _facilityChip("Security", facilities['security']),
                        _facilityChip("Covered", facilities['covered']),
                        _facilityChip("EV", facilities['ev']),
                        _facilityChip("Washroom", facilities['washroom']),
                      ],
                    ),
                  ),

                  _sectionCard(
                    "Contact",
                    Icons.phone,
                    Text("${data['contact']}"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(String title, IconData icon, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _highlightBox(String label, dynamic value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Text(
              "$value",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceChip(String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB).withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text("$label: ₹$value", style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _facilityChip(String label, bool value) {
    return Chip(
      label: Text(label),
      backgroundColor: value
          ? Colors.green.withOpacity(0.2)
          : Colors.grey.shade200,
    );
  }
}
