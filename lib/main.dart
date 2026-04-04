import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:parking_app/features/admin/dashboard/provider/admin_dashboard_provider.dart';
import 'package:parking_app/features/admin/parkings/provider/parking_provider.dart';
import 'package:parking_app/features/login/pages/authentication_check_page.dart';
import 'package:parking_app/features/login/provider/login_provider.dart';
import 'package:parking_app/features/register/provider/sign_up_provider.dart';
import 'package:parking_app/features/user/home/provider/booking_provider.dart';
import 'package:parking_app/features/user/home/provider/homepage_provider.dart';
import 'package:parking_app/features/user/profile/provider/profile_provider.dart';
import 'package:parking_app/firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => SignUpProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ParkingProvider()),
        ChangeNotifierProvider(create: (_) => HomepageProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white54,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white54,
          surfaceTintColor: Colors.transparent,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthenticationCheckPage(),
    );
  }
}
