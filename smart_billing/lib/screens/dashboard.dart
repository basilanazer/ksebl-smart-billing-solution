
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_fonts/google_fonts.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});
  Future<void> logout(context) async{
    try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('email');

              FirebaseAuth.instance.signOut();

              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route)=>false);
            } catch (e) {
              print(e);
            }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen',style: TextStyle(fontWeight: FontWeight.bold),)),
      body: SingleChildScrollView(
        child: ElevatedButton(
          onPressed: (){
            logout(context);
          },
         child: const Text('logout')),
      )
    );
  }
}