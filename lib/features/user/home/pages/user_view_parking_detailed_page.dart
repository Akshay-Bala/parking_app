import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UserViewParkingDetailedPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const UserViewParkingDetailedPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final vehicles = List<Map<String, dynamic>>.from(data['vehicles'] ?? []);
    final facilities = data['facilities'] ?? {};
    final timing = data['timing'] ?? {};
    final displayName = data['parking_name'] ?? data['name'] ?? "";
    final totalSlots = data['total_slots'] ?? data['totalSlots'];
    final availableSlots = data['available_slots'] ?? data['availableSlots'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFF2563EB),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                displayName,
                style: const TextStyle(fontSize: 16),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _card(
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            data['locationName'] ?? "",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.map),
                          onPressed: () => _openMap(),
                        ),
                      ],
                    ),
                  ),

                  Row(
                    children: [
                      _infoBox("Total", totalSlots, Colors.blue),
                      const SizedBox(width: 10),
                      _infoBox(
                        "Available",
                        availableSlots,
                        Colors.green,
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  _card(
                    title: "About Parking",
                    child: Text(data['description'] ?? ""),
                  ),

                  _card(
                    title: "Timing",
                    child: Text(
                      timing['is24']
                          ? "24 Hours Open"
                          : "${timing['start']} - ${timing['end']}",
                    ),
                  ),

                  _card(
                    title: "Available Days",
                    child: Wrap(
                      spacing: 8,
                      children: (data['days'] as List)
                          .map((d) => Chip(label: Text(d)))
                          .toList(),
                    ),
                  ),

                  _card(
                    title: "Vehicle Pricing",
                    child: Column(
                      children: vehicles.map((v) {
                        final hour = v['rate_per_hour'] ?? v['hour'] ?? 0;
                        final day = v['rate_per_day'] ?? v['day'] ?? 0;
                        final month = v['rate_per_month'] ?? v['month'] ?? 0;
                        final type = v['type'] ?? v['vehicle_type'] ?? 'Unknown';

                        return ListTile(
                          leading: Icon(
                            _getVehicleIcon(type),
                            color: Colors.blue,
                          ),
                          title: Text(type),
                          subtitle: Text(
                            "Hr: ₹$hour | Day: ₹$day | Month: ₹$month",
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  _card(
                    title: "Facilities",
                    child: Wrap(
                      spacing: 10,
                      children: [
                        _chip("CCTV", facilities['cctv'] ?? false),
                        _chip("Security", facilities['security'] ?? false),
                        _chip("Covered", facilities['covered'] ?? false),
                        _chip("EV", facilities['ev'] ?? false),
                        _chip("Washroom", facilities['washroom'] ?? false),
                      ],
                    ),
                  ),

                  _card(
                    title: "Contact",
                    child: Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.green),
                        const SizedBox(width: 10),
                        Expanded(child: Text("${data['contact']}")),
                        IconButton(
                          icon: const Icon(Icons.call),
                          onPressed: () => _callNumber(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => SlotBooking(pricing: vehicles,),
                        //   ),
                        // );
                      },
                      child: const Text(
                        "Book Slot",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({String? title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          if (title != null) const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _infoBox(String label, dynamic value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(label),
            const SizedBox(height: 6),
            Text(
              "$value",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool value) {
    return Chip(
      label: Text(label),
      backgroundColor: value
          ? Colors.green.withOpacity(0.2)
          : Colors.grey.shade200,
    );
  }

  IconData _getVehicleIcon(String type) {
    switch (type.toLowerCase()) {
      case "two wheeler":
        return Icons.two_wheeler;
      case "four wheeler":
        return Icons.directions_car;
      case "ev":
        return Icons.ev_station;
      default:
        return Icons.local_shipping;
    }
  }

  void _openMap() async {
    final query = Uri.encodeComponent(data['locationName']);
    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$query",
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _callNumber() async {
    final uri = Uri.parse("tel:${data['contact']}");
    await launchUrl(uri);
  }
}
