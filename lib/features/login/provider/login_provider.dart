import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginProvider extends ChangeNotifier {
  User? user;

  bool isLoading = true;
  bool isAdmin = false;

  TextEditingController emailLoginController = TextEditingController();
  TextEditingController passwordLoginController = TextEditingController();

  bool isPasswordVisible = false;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  LoginProvider() {
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      isLoading = true;
      notifyListeners();

      user = firebaseUser;

      if (user != null) {
        await checkUserRole();
      } else {
        isAdmin = false;
      }

      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> checkUserRole() async {
    final uid = user!.uid;

    final adminDoc = await FirebaseFirestore.instance
        .collection("admin")
        .doc(uid)
        .get();

    if (adminDoc.exists) {
      isAdmin = true;
    } else {
      isAdmin = false;
    }
  }

  Future<String?> login(String email, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Login failed";
    } catch (e) {
      return "Login failed";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  void clearFields() {
    emailLoginController.clear();
    passwordLoginController.clear();
  }
}
