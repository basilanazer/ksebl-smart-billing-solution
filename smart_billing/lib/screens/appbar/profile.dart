import 'package:flutter/material.dart';
import 'package:smart_billing/widgets/button.dart';
import 'package:smart_billing/widgets/inputfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_billing/widgets/snackbar.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final emailController = TextEditingController();
  final phnoController = TextEditingController();
  final consNumController = TextEditingController();
  final nameController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileDetails();
  }

  Future<void> _fetchProfileDetails() async {
    setState(() {
      isLoading = true;
    });
    String msg = 'Some error occured';
    try {
      // Retrieve the current email from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');
      if (email == null || email.isEmpty) {
        msg = "Email not found in SharedPreferences.";
        throw Exception();
      }

      // Fetch consumer number from consumer_number collection
      final consumerNumberDoc = await FirebaseFirestore.instance
          .collection('consumer number')
          .doc(email)
          .get();
      if (!consumerNumberDoc.exists) {
        msg = "Consumer number not found for the given email.";
        throw Exception();
      }

      final consumerNumber = consumerNumberDoc.data()?['cons no'];
      if (consumerNumber == null || consumerNumber.isEmpty) {
        msg = "Consumer number is empty or invalid.";
        throw Exception();
      }

      // Fetch name and phone number from consumer collection
      final consumerDoc = await FirebaseFirestore.instance
          .collection('consumer')
          .doc(consumerNumber)
          .get();
      if (!consumerDoc.exists) {
        msg = "Consumer details not found for the given consumer number.";
        throw Exception();
      }

      final name = consumerDoc.data()?['name'];
      final phno = consumerDoc.data()?['phno'];
      if (name == null || phno == null) {
        msg = "Name or phone number is missing in consumer details.";
        throw Exception();
      }

      // Populate the text fields with the fetched data
      setState(() {
        emailController.text = email;
        consNumController.text = consumerNumber;
        nameController.text = name;
        phnoController.text = phno;
      });
    } catch (e) {
      MySnackbar.show(context, msg);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    // Name
                    InputField(
                      label: "Name",
                      controller: nameController,
                      isEnable: false,
                    ),
                    const SizedBox(height: 8),
                    // Consumer Number
                    InputField(
                      label: "Consumer Number",
                      controller: consNumController,
                      isEnable: false,
                    ),
                    const SizedBox(height: 8),
                    // Email
                    InputField(
                      label: "Email",
                      controller: emailController,
                      isEnable: false,
                    ),
                    const SizedBox(height: 8),
                    // Phone Number
                    InputField(
                      label: "Phone Number",
                      controller: phnoController,
                      isEnable: false,
                    ),
                    const SizedBox(height: 18),
                    Buttons(label: "Edit Profile", fn: () {}),
                    const SizedBox(height: 10),
                    Buttons(label: "Change Passwords", fn: () {},
                      color: const Color(0xFFFD7250),
                      bgcolor: Colors.white,)
                  ],
                ),
              ),
            ),
    );
  }
}
