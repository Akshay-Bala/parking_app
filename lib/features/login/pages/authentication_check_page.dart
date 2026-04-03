import 'package:flutter/material.dart';
import 'package:parking_app/features/login/pages/login_page.dart';
import 'package:parking_app/features/login/provider/login_provider.dart';
import 'package:parking_app/features/user/home/homepage_events.dart';
import 'package:provider/provider.dart';

class AuthenticationCheckPage extends StatelessWidget {
  const AuthenticationCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<LoginProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authProvider.user == null) {
      return const LoginPage();
    }

    switch (authProvider.role) {
      case UserRole.admin:
        return const Scaffold(body: Center(child: Text("Admin Page")));

      case UserRole.user:
        return const HomepageEvents();

      case UserRole.none:
      default:
        return const LoginPage();
    }
  }
}
