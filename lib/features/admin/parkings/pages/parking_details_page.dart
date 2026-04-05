import 'package:flutter/material.dart';
import 'package:parking_app/features/admin/parkings/provider/parking_provider.dart';
import 'package:provider/provider.dart';
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
    final provider = Provider.of<ParkingProvider>(context);

    final vehicles = List<Map<String, dynamic>>.from(data['vehicles'] ?? []);
    final facilities = data['facilities'] ?? {};
    final timing = data['timing'] ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        title: Text(data['parking_name'] ?? ''),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['locationName'] ?? "",
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
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              data['city'] ?? "",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: provider.isParkingActive(data)
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: provider.isParkingActive(data)
                                ? Colors.green
                                : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          provider.isParkingActive(data) ? "Active" : "Closed",
                          style: TextStyle(
                            color: provider.isParkingActive(data)
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
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
                      _statCard("Total", data['total_slots'], Colors.blue),
                      const SizedBox(width: 10),
                      _statCard(
                        "Available",
                        data['available_slots'],
                        Colors.green,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _section(
                    "About",
                    Icons.description,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['description'] ?? ""),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.phone, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(data['contact'].toString()),
                          ],
                        ),
                      ],
                    ),
                  ),

                  _section(
                    "Location",
                    Icons.location_on,
                    InkWell(
                      onTap: openMap,
                      child: Row(
                        children: [
                          const Icon(Icons.map, color: Colors.blue),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              data['locationName'] ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  _section(
                    "Timing",
                    Icons.access_time,
                    Text(
                      timing['is24']
                          ? "Open 24 Hours"
                          : "${timing['start']} - ${timing['end']}",
                    ),
                  ),

                  _section(
                    "Available Days",
                    Icons.calendar_today,
                    Wrap(
                      spacing: 8,
                      children: (data['days'] as List)
                          .map((d) => Chip(label: Text(d)))
                          .toList(),
                    ),
                  ),

                  _section(
                    "Vehicle Pricing",
                    Icons.directions_car,
                    Column(
                      children: vehicles.map((v) {
                        final type = v['type'];
                        final hour = v['rate_per_hour'];
                        final day = v['rate_per_day'];
                        final month = v['rate_per_month'];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                children: [
                                  _priceChip("Hr", hour),
                                  _priceChip("Day", day),
                                  _priceChip("Month", month),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  _section(
                    "Facilities",
                    Icons.miscellaneous_services,
                    Wrap(
                      spacing: 10,
                      children: [
                        _facilityChip("CCTV", facilities['cctv']),
                        _facilityChip("Security", facilities['security']),
                        _facilityChip("Covered", facilities['covered']),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, dynamic value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Text(
              "$value",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, IconData icon, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
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
      child: Text("$label: ₹$value"),
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
