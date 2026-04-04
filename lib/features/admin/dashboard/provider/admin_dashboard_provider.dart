import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  Stream<QuerySnapshot> getAdminParkingStream() {
    final adminId = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('parking_places')
        .where('adminId', isEqualTo: adminId)
        .snapshots();
  }
}