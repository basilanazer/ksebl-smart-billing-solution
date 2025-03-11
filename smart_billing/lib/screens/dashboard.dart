import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_billing/model/logout.dart';
import 'package:smart_billing/widgets/button.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

// Future<void> addItems(Map<String, dynamic> dets, String id) async {
//   return await FirebaseFirestore.instance
//       .collection("1114567890123")
//       .doc(id)
//       .set(dets);
// }

class _DashboardState extends State<Dashboard> {
  // Future addItems(Map<String, dynamic> dets, String id) async {
  //   return await FirebaseFirestore.instance
  //       .collection("1112345671234")
  //       .doc(id)
  //       .set(dets);
  // }

  String? dueDate;
  String? unit;
  String? amt;

  @override
  void initState() {
    super.initState();
    fetchDueDate().then((det) {
      setState(() {
        dueDate = det[0];
        amt = det[1];
        unit = det[2];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WillPopScope(
      onWillPop: () async {
        // Show exit confirmation dialog
        bool exit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            //backgroundColor: Colors.amber[50],
            title: const Text("Exit"),
            content: const Text(
              'Are you sure you want to exit?',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Close the dialog and return true
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  'Yes',
                  style: TextStyle(
                      color: Color(0xFF4D4C7D), fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Close the dialog and return false
                  Navigator.of(context).pop(false);
                },
                child: const Text(
                  'No',
                  style: TextStyle(
                      color: Color(0xFFFD7250), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );

        // Return exit if user confirmed, otherwise don't exit
        return exit;
      },
      child: Scaffold(
      appBar: AppBar(
        actions: [
          //logout
          IconButton(
            onPressed: () {
              confirmLogout(context);
            },
            icon: const Icon(
              Icons.logout,
              color: Color(0xFFFD7250),
            ),
          ),
          //analytics
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/analytics');
            },
            icon: const Icon(
              Icons.line_axis,
              color: Color(0xFFFD7250),
            ),
          ),
          //bill history
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/billhistory');
            },
            icon: const Icon(
              Icons.history,
              color: Color(0xFFFD7250),
            ),
          ),          
          //notifications
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(
          //     Icons.notifications_active_outlined,
          //     color: Color(0xFFFD7250),
          //   ),
          // ),
          //profile
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
            icon: const Icon(
              Icons.person_outline,
              color: Color(0xFFFD7250),
            ),
          ),
        ],
        title: const Text('DashBoard',),
      ),
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Image.asset(
                'assets/icon.png',
                width: 264,
                height: 112,
              ),
            ),
            const SizedBox(height: 40,),
            //capture
            Container(
              //margin: const EdgeInsets.all(30),
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF4D4C7D),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    color: Color(0xFFFD7250),
                    size: 40,
                  ),
                  TextButton(
                    onPressed: () {
                      //Navigator.of(context).pushReplacementNamed('/capture');
                      Navigator.of(context).pushNamed('/barcode');
                    }, // Opens the camera
                    child: const Text(
                      "Capture Your Meter Now",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    color: Color(0xFFFD7250),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40,),

            //due date
            Container(
              //margin: const EdgeInsets.all(30),
              height: 100,
              //width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFFFD7250),
              ),
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Icon(
                    Icons.file_copy,
                    color: Colors.white,
                    size: 40,
                  ),
                  Text(
                    "Next Bill Due ${dueDate ?? 'Loading...'}",
                    style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF4D4C7D),
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40,),
            //analytics last month
            const Align(
              alignment: Alignment.topLeft,
              child: 
              // Padding(
              // padding: EdgeInsets.only(left: 30),
              // child: 
              Text(
                  "Last Month Analytics",
                  style: TextStyle(
                      color: Color(0xFF4D4C7D),
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
            //),
            const SizedBox(height:10),
            Container(
              height: 130,
              //margin: const EdgeInsets.all(30),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xffc2c2e1)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Unit: ",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${unit ?? 'Loading...'} KWH",
                        style: const TextStyle(
                            color: Color(0xFF4D4C7D),
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        "Amount(Rs): ",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Rs ${amt ?? 'Loading...'}",
                        style: const TextStyle(
                            color: Color(0xFF4D4C7D),
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40,),
            Buttons(
              label: "How to Capture Meter Reading?",
              color: const Color(0xFFFD7250),
              bgcolor: Colors.white,
              fn: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GuideScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
    )
  )
    );
  }
}

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff4d4c7d),
      body: Center(
        child: Image.asset(
          'assets/guide_image.png', // Replace with your guide image
          //width: double.infinity,
          //height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

Future<List> fetchDueDate() async {
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('email');
  if (email == null) return []; 

  String consno = '';
  String date = '';
  String unit = '';
  String amt = '';

  // Fetch consumer number
  DocumentSnapshot consumerDoc = await FirebaseFirestore.instance
      .collection('consumer number')
      .doc(email)
      .get();

  if (consumerDoc.exists) {
    consno = consumerDoc['cons no'];
  } else {
    return []; 
  }

  // Fetch due date using consumer number
  DocumentSnapshot dueDoc = await FirebaseFirestore.instance
      .collection('dashboard details')
      .doc(consno)
      .get();

  if (dueDoc.exists) {
    date = dueDoc['next bill due'];
    amt = dueDoc['last amt'];
    unit = dueDoc['last unit'];
  }

  return [date,amt,unit]; 
}