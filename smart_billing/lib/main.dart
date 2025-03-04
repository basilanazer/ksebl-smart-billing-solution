// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:firebase_core/firebase_core.dart';
import 'package:smart_billing/screens/appbar/analytics.dart';
import 'package:smart_billing/screens/appbar/profile.dart';
import 'package:smart_billing/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:smart_billing/screens/forgot_pass.dart';
import 'package:smart_billing/screens/ocr/meter_detection.dart';
import 'package:smart_billing/screens/register/login_email.dart';
import 'package:smart_billing/screens/ocr/barcode_scanner.dart';
import 'package:smart_billing/screens/register/login_phone.dart';
import 'package:smart_billing/screens/register/register.dart';
import 'package:smart_billing/screens/splashscreen/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

var email;
var user;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  email = preferences.getString('email');
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KSEBL Smart Billing Solution',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4D4C7D)),
        useMaterial3: true,
        scaffoldBackgroundColor:
            Colors.white, // Sets the background color of the Scaffold
        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF4D4C7D),
            foregroundColor: Color(0xFFFD7250),
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20
          )),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const Login(),
        '/dashboard': (context) => const Dashboard(),
        '/analytics': (context) => const Analytics(),
        '/register': (context) => const Register(),
        '/profile': (context) => const Profile(),
        '/barcode': (context) => const BarcodeScannerScreen(),
        '/mtrdetec': (context) => const MeterDetectionScreen(),
        '/forgotpas': (context)=> const ForgotPasswordPage(),
      
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: email == null ? const Login() : const Dashboard());
  }
}
