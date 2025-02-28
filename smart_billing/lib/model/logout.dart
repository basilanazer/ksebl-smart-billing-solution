import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> confirmLogout(BuildContext context) async {
  bool shouldLogout = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Return true
            child: const Text("Yes",style: TextStyle(color: Color(0xFF4D4C7D), fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Return false
            child: const Text("No", style: TextStyle(color: Color(0xFFFD7250), fontWeight: FontWeight.bold),),
          ),          
        ],
      );
    },
  );

  if (shouldLogout == true) {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('email');

      await FirebaseAuth.instance.signOut();

      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      print(e);
    }
  }
}

