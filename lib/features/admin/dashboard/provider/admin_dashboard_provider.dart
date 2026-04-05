import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parking_app/features/login/pages/login_page.dart';

class DashboardProvider extends ChangeNotifier {
  Stream<QuerySnapshot> getAdminParkingStream() {
    final adminId = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('parking_slots')
        .where('adminId', isEqualTo: adminId)
        .snapshots();
  }

  Stream<DocumentSnapshot> getAdminDetails() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection('admin').doc(uid).snapshots();
  }

  Future<void> logout(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Logout failed")),
    );
  }
}
}
