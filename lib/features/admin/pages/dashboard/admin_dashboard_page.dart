import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parking_app/features/admin/widgets/widget_dashboard_tile.dart';
import 'package:parking_app/features/login/pages/login_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {

    signOut() async {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }

    Future<Map<String, int>> getLoginCounts(
      List<QueryDocumentSnapshot> users,
    ) async {
      int totalTodayLogins = 0;
      int totalLogins = 0;

      String todayDate =
          "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";

      for (var user in users) {
        final userId = user.id;

        final allSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('loginHistory')
            .get();

        totalLogins += allSnapshot.docs.length;

        final todaySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('loginHistory')
            .where('date', isEqualTo: todayDate)
            .get();

        totalTodayLogins += todaySnapshot.docs.length;
      }

      return {'today': totalTodayLogins, 'total': totalLogins};
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF2563EB),
        title: InkWell(
          onTap: () {
            signOut();
          },
          child: const Text(
            "Admin Dashboard",
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings, color: Color(0xFF2563EB)),
            ),
          ),
        ],
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
                Text(
                  "Welcome, Admin",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Manage your application easily",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const DashboardTile(
                          title: "Total Users",
                          value: "...",
                          icon: Icons.people,
                          color: Colors.blue,
                        );
                      }

                      if (!snapshot.hasData) {
                        return const DashboardTile(
                          title: "Total Users",
                          value: "0",
                          icon: Icons.people,
                          color: Colors.blue,
                        );
                      }

                      int userCount = snapshot.data!.docs.length;

                      return DashboardTile(
                        title: "Total Users",
                        value: userCount.toString(),
                        icon: Icons.people,
                        color: Colors.blue,
                      );
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Bookings')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const DashboardTile(
                          title: "Revenue",
                          value: "...",
                          icon: Icons.currency_rupee,
                          color: Colors.green,
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const DashboardTile(
                          title: "Revenue",
                          value: "₹0",
                          icon: Icons.currency_rupee,
                          color: Colors.green,
                        );
                      }

                      double totalAmount = 0;

                      for (var doc in snapshot.data!.docs) {
                        var data = doc.data() as Map<String, dynamic>;

                        var amount = data['totalAmount'];

                        if (amount is int) {
                          totalAmount += amount.toDouble();
                        } else if (amount is double) {
                          totalAmount += amount;
                        }
                      }

                      return DashboardTile(
                        title: "Total Booking Amount",
                        value: "₹${totalAmount.toStringAsFixed(0)}",
                        icon: Icons.currency_rupee,
                        color: Colors.green,
                      );
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .snapshots(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const DashboardTile(
                          title: "Today Logged In",
                          value: "...",
                          icon: Icons.login,
                          color: Colors.green,
                        );
                      }

                      if (!userSnapshot.hasData ||
                          userSnapshot.data!.docs.isEmpty) {
                        return const DashboardTile(
                          title: "Today Logged In",
                          value: "0",
                          icon: Icons.login,
                          color: Colors.green,
                        );
                      }

                      final users = userSnapshot.data!.docs;

                      return FutureBuilder<Map<String, int>>(
                        future: getLoginCounts(users),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const DashboardTile(
                              title: "Logins",
                              value: "...",
                              icon: Icons.login,
                              color: Colors.green,
                            );
                          }

                          final today = snapshot.data!['today']!;
                          final total = snapshot.data!['total']!;

                          return DashboardTile(
                            title: "Today: $today | Total: $total",
                            value: today.toString(),
                            icon: Icons.login,
                            color: Colors.green,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
