import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parking_app/features/admin/parkings/pages/parking_details_page.dart';
import 'package:parking_app/features/admin/parkings/provider/parking_provider.dart';
import 'package:provider/provider.dart';
import 'package:parking_app/features/admin/parkings/pages/add_parking_spot.dart';
import 'package:url_launcher/url_launcher.dart';

class UsersListPage extends StatelessWidget {
  const UsersListPage({super.key});

  IconData getVehicleIcon(String type) {
    switch (type.toLowerCase()) {
      case "two wheeler":
        return Icons.two_wheeler;
      case "four wheeler":
        return Icons.directions_car;
      default:
        return Icons.directions_car;
    }
  }

  Future<void> openMap(Map<String, dynamic> data) async {
    final query = Uri.encodeComponent(
      data['locationName'] ?? "${data['address']} ${data['city']}",
    );

    final url = "https://www.google.com/maps/search/?api=1&query=$query";
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ParkingProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2563EB),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddParkingPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 90),
                Text(
                  "Parking Management",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "View and manage your parking spots",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: provider.searchController,
              onChanged: provider.setSearch,
              decoration: InputDecoration(
                hintText: "Search parking...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: provider.searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: provider.clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: provider.getMyParkingStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("No Parking Added"));
                }

                final filtered = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final name = (data['parking_name'] ?? "")
                      .toString()
                      .toLowerCase();

                  final query = provider.searchQuery;

                  return name.contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Parking Found",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final data = filtered[index].data() as Map<String, dynamic>;

                    final timing = data['timing'] ?? {};
                    final vehicles = (data['vehicles'] ?? []) as List;

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ParkingDetailsPage(data: data),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.local_parking,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          data['parking_name'] ?? "Unnamed",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color:
                                                  provider.isParkingActive(data)
                                                  ? Colors.green
                                                  : Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            provider.isParkingActive(data)
                                                ? "Active"
                                                : "Closed",
                                            style: TextStyle(
                                              color:
                                                  provider.isParkingActive(data)
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    data['locationName'] ??
                                        data['address'] ??
                                        "No location",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  vehicles.isEmpty
                                      ? const Text(
                                          "No vehicles",
                                          style: TextStyle(fontSize: 12),
                                        )
                                      : Wrap(
                                          spacing: 6,
                                          children: vehicles.map<Widget>((v) {
                                            return Icon(
                                              getVehicleIcon(v['type'] ?? ""),
                                              size: 16,
                                              color: const Color(0xFF2563EB),
                                            );
                                          }).toList(),
                                        ),

                                  const SizedBox(height: 6),

                                  Text(
                                    (timing['is24'] ?? false)
                                        ? "24 Hours"
                                        : "${timing['start'] ?? "--"} - ${timing['end'] ?? "--"}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),

                            const Icon(Icons.arrow_forward_ios, size: 14),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
