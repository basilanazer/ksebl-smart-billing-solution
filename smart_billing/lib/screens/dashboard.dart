import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_billing/database/opn.dart';
// import 'package:google_fonts/google_fonts.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () {
                    logout(context);
                  },
                  icon: Icon(
                    Icons.logout,
                    color: Color(0xFFFD7250),
                  )),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/analytics');
                  },
                  icon: Icon(
                    Icons.line_axis,
                    color: Color(0xFFFD7250),
                  )),
              IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.notifications_active_outlined,
                    color: Color(0xFFFD7250),
                  )),
              IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.person_outline,
                    color: Color(0xFFFD7250),
                  ))
            ],
            title: const Text(
              'DashBoard',
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Center(
                child: Image.asset(
                  'assets/icon.png',
                  width: 264,
                  height: 112,
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      color: Color(0xFFFD7250),
                    ),
                    Text(
                      "Capture Your Meter Now",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: Color(0xFFFD7250),
                    )
                  ],
                ),
                margin: EdgeInsets.all(30),
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xFF4D4C7D),
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(
                      Icons.note,
                      color: Colors.white,
                    ),
                    const Text(
                      "Next Bill Due 11th November",
                      style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF4D4C7D),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                margin: const EdgeInsets.all(30),
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFFFD7250),
                ),
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: Text(
                    "Last Month Analytics",
                    style: TextStyle(
                        color: Color(0xFF4D4C7D),
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
              ),
              Container(
                height: 100,
                margin: const EdgeInsets.all(30),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Unit: ",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "235 KW",
                          style: TextStyle(
                              color: Color(0xFF4D4C7D),
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Amount(Rs): ",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "1640.00",
                          style: TextStyle(
                              color: Color(0xFF4D4C7D),
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        )
                      ],
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color.fromARGB(255, 189, 188, 231),
                ),
              ),
            ],
          ),
        ));
  }
}
