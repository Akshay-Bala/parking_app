import 'package:flutter/material.dart';
import 'package:parking_app/features/admin/dashboard/pages/admin_dashboard_page.dart';
import 'package:parking_app/features/login/pages/login_page.dart';
import 'package:parking_app/features/login/provider/login_provider.dart';
import 'package:parking_app/features/user/home/pages/homepage_events.dart';
import 'package:provider/provider.dart';

class AuthenticationCheckPage extends StatelessWidget {
  const AuthenticationCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<LoginProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.user == null) {
      return const LoginPage();
    }

    if (authProvider.isAdmin) {
      return const AdminDashboardPage();
    }

    return const HomepageEvents();
  }
}
