import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum UserRole { admin, user, none }

class LoginProvider extends ChangeNotifier {
  User? user;
  UserRole role = UserRole.none;

  bool isLoading = true;

  TextEditingController emailLoginController = TextEditingController();
  TextEditingController passwordLoginController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  Future<void> init() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await fetchUserRole();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUserRole() async {
    String uid = user!.uid;
    final adminDoc = await FirebaseFirestore.instance
        .collection("admin")
        .doc(uid)
        .get();
    if (adminDoc.exists) {
      role = UserRole.admin;
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();
    if (userDoc.exists) {
      role = UserRole.user;
    } else {
      role = UserRole.none;
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = credential.user;
      await fetchUserRole();
      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return "Login failed";
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    user = null;
    role = UserRole.none;
    notifyListeners();
  }
}
