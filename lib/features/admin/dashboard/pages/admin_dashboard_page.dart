import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parking_app/features/admin/dashboard/pages/admin_profile_page.dart';
import 'package:parking_app/features/admin/dashboard/provider/admin_dashboard_provider.dart';
import 'package:parking_app/features/admin/dashboard/widgets/widget_dashboard_tile.dart';
import 'package:provider/provider.dart';
import 'package:parking_app/features/admin/parkings/pages/parking_spots.dart';
import 'package:parking_app/features/login/pages/login_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    signOut() async {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }

    return ChangeNotifierProvider(
      create: (_) => DashboardProvider(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF2563EB),
          title: InkWell(
            onTap: signOut,
            child: const Text(
              "Dashboard",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(25),
                ),
              ),
              child: Consumer<DashboardProvider>(
                builder: (context, provider, _) {
                  return StreamBuilder<DocumentSnapshot>(
                    stream: provider.getAdminDetails(),
                    builder: (context, snapshot) {
                      String username = "Admin";

                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        username = data['username'] ?? "Admin";
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome, $username",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  "Manage your application easily",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminProfilePage(),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Consumer<DashboardProvider>(
                  builder: (context, provider, child) {
                    return StreamBuilder<QuerySnapshot>(
                      stream: provider.getAdminParkingStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return GridView.count(
                            crossAxisCount: 2,
                            children: const [
                              DashboardTile(
                                title: "Total Parking Spots",
                                value: "...",
                                icon: Icons.local_parking,
                                color: Colors.blue,
                              ),
                            ],
                          );
                        }

                        if (!snapshot.hasData) {
                          return GridView.count(
                            crossAxisCount: 2,
                            children: const [
                              DashboardTile(
                                title: "Total Parking Spots",
                                value: "0",
                                icon: Icons.local_parking,
                                color: Colors.blue,
                              ),
                            ],
                          );
                        }

                        final docs = snapshot.data!.docs;
                        int parkingCount = docs.length;

                        return GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const UsersListPage(),
                                  ),
                                );
                              },
                              child: DashboardTile(
                                title: "My Parking Spots",
                                value: parkingCount.toString(),
                                icon: Icons.local_parking,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
