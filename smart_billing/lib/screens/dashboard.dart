import 'package:flutter/material.dart';
import 'package:smart_billing/model/logout.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // Future addItems(Map<String, dynamic> dets, String id) async {
  //   return await FirebaseFirestore.instance
  //       .collection("1112345671234")
  //       .doc(id)
  //       .set(dets);
  // }

  @override
  Widget build(BuildContext context) {
    //USE THIS PART TO ADD DUMMY VALUES
    // addItems({
    //   "Bill Date": "06.10.2020",
    //   "Current Reading": "22255",
    //   "Previous Reading": "22176",
    //   "Units Consumed": "79",
    //   "Amount Payable": "454",
    // }, "2020-10");

    return SafeArea(
        child: WillPopScope(
      onWillPop: () async {
        // Show exit confirmation dialog
        bool exit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            //backgroundColor: Colors.amber[50],
            title: const Text("Exit"),
            content: const Text('Are you sure you want to exit?',),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Close the dialog and return true
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  'Yes',
                  style: TextStyle(color: Color(0xFF4D4C7D), fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Close the dialog and return false
                  Navigator.of(context).pop(false);
                },
                child: const Text(
                  'No',
                  style: TextStyle(color: Color(0xFFFD7250), fontWeight: FontWeight.bold),
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
          //notifications
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_active_outlined,
              color: Color(0xFFFD7250),
            ),
          ),
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
            Container(
              margin: const EdgeInsets.all(30),
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
                      Navigator.of(context).pushReplacementNamed('/capture');
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
            Container(
              margin: const EdgeInsets.all(30),
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFFFD7250),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(
                    Icons.file_copy,
                    color: Colors.white,
                    size: 40,
                  ),
                  Text(
                    "Next Bill Due 11th November",
                    style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF4D4C7D),
                        fontWeight: FontWeight.bold),
                  ),
                ],
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
              //height: 100,
              margin: const EdgeInsets.all(30),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromARGB(255, 189, 188, 231),
              ),
              child: const Column(
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
            ),
            // Your existing code continues...
          ],
        ),
      ),
    ),
    )
  );
  }
}
