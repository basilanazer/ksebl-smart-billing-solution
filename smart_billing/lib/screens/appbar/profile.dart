import 'package:firebase_auth/firebase_auth.dart';
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
  bool isLoading = true;
  bool isEditing = false;
  bool isSaving = false;

  final emailController = TextEditingController();
  final phnoController = TextEditingController();
  final consNumController = TextEditingController();
  final nameController = TextEditingController();
  final mtrController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfileDetails();
  }

  Future<void> _fetchProfileDetails() async {
    setState(() => isLoading = true);
    String msg = 'Some error occurred';

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');

      if (email == null || email.isEmpty) {
        msg = "Email not found in SharedPreferences.";
        throw Exception();
      }

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
      final mtrno = consumerDoc.data()?['meter_no'];
      if (name == null || phno == null) {
        msg = "Name or phone number is missing in consumer details.";
        throw Exception();
      }

      setState(() {
        emailController.text = email;
        consNumController.text = consumerNumber;
        nameController.text = name;
        phnoController.text = phno;
        mtrController.text = mtrno.length <= 7 ? mtrno : 
        mtrno.substring(mtrno.length - 8);

      });
    } catch (e) {
      MySnackbar.show(context, msg);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    setState(() => isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('consumer')
          .doc(consNumController.text)
          .update({
        'name': nameController.text,
        'phno': phnoController.text,
      });

      MySnackbar.show(context, "Profile updated successfully!");
      setState(() => isEditing = false);
    } catch (e) {
      MySnackbar.show(context, "Failed to update profile. Try again.");
    } finally {
      setState(() => isSaving = false);
    }
  }

  void resetPassword(String email, BuildContext context) async {
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      MySnackbar.show(context,
          "An email containing instructions to reset your password has been sent.");
    } catch (e) {
      MySnackbar.show(context, "Some unknown error occurred. Please try again.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    //name
                    InputField(
                      label: "Name",
                      controller: nameController,
                      isEnable: isEditing,
                    ),
                    const SizedBox(height: 8),
                    //email
                    InputField(
                      label: "Email",
                      controller: emailController,
                      isEnable: false,
                    ),
                    //consumer no
                    const SizedBox(height: 8),                    
                    InputField(
                      label: "Consumer Number",
                      controller: consNumController,
                      isEnable: false,
                    ),
                    InputField(
                      label: "Meter Number",
                      controller: mtrController,
                      isEnable: false,
                    ),
                    const SizedBox(height: 8),
                    InputField(  
                      label: "Phone Number",
                      controller: phnoController,
                      isEnable: isEditing,
                    ),
                    const SizedBox(height: 18),
                    Buttons(
                      label: isEditing ? "Save" : "Edit Profile",
                      fn: () {
                        if (isEditing) {
                          _updateProfile();
                        } else {
                          setState(() => isEditing = true);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    if (isSaving) const CircularProgressIndicator(),
                    Buttons(
                      label: "Change Password",
                      fn: () => resetPassword(emailController.text, context),
                      color: const Color(0xFFFD7250),
                      bgcolor: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
