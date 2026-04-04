import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpProvider extends ChangeNotifier {
  bool isLoading = false;

  TextEditingController usernameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    notifyListeners();
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return "Username required";
    if (value.length < 3) return "Minimum 3 characters";
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return "Enter phone number";
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return "Enter valid 10-digit number";
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email required";
    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
      return "Enter valid email";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password required";
    }
    if (value.length < 6) {
      return "Minimum 6 characters";
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Confirm password required";
    }

    if (value != passwordController.text) {
      return "Passwords do not match";
    }

    return null;
  }

  Future<String?> register() async {
    try {
      isLoading = true;
      notifyListeners();

      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final userId = credential.user!.uid;
      final phone = int.tryParse(phoneController.text.trim());

      if (phone == null) {
        isLoading = false;
        notifyListeners();
        return "Invalid phone number";
      }
      await FirebaseFirestore.instance.collection("users").doc(userId).set({
        "userId": userId,
        "username": usernameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phone,
      });

      isLoading = false;
      notifyListeners();

      return null;
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      notifyListeners();

      if (e.code == 'email-already-in-use') {
        return "Email already exists";
      } else if (e.code == 'weak-password') {
        return "Password too weak";
      } else if (e.code == 'invalid-email') {
        return "Invalid email";
      }
      return "Signup failed";
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return "Something went wrong";
    } finally {}
  }

  clearFields() {
    usernameController.clear();
    phoneController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }
}
