

// ignore_for_file: avoid_print


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:smart_billing/main.dart';
import 'package:smart_billing/widgets/button.dart';
import 'package:smart_billing/widgets/inputfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_billing/widgets/snackbar.dart';
// import 'package:mediwise/register/reset_password.dart';




class Register extends StatefulWidget{
  const Register({super.key});
 
  @override
  RegisterState createState() => RegisterState();
}


class RegisterState extends State<Register> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confPasswordController = TextEditingController();
  final phnoController = TextEditingController();
  final consNumController = TextEditingController();
  final auth = FirebaseAuth.instance;
  bool isLoading = false;
  String msg="Some unknown error occured";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4D4C7D),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20), // Corner radius
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10,),
                  Image.asset('assets/icon.png',width: 210, height: 90,),
                  const SizedBox(height: 25,),
                  const Text(
                    "REGISTER",
                    style: TextStyle(
                      color: Color(0xFF4D4C7D),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30,),
                  //consumer number
                  InputField(
                    label: "Consumer Number",
                    hintText: "enter your consumer number",
                    controller: consNumController,
                  ),
                  //const SizedBox(height: 8,),
                  //email
                  InputField(
                    label: "Email",
                    hintText: "enter your email",
                    controller: emailController,
                  ),
                  //const SizedBox(height: 8),
                  //phno
                  InputField(
                    label: "Phone Number",
                    hintText: "enter your phone number",
                    controller: phnoController,
                  ),
                  //const SizedBox(height: 8),
                  //password
                  InputField(
                    label: "Password",
                    hintText: "enter your password",
                    controller: passwordController,
                    obscure: true,
                  ),
                  //const SizedBox(height: 8),
                  //confirm password
                  InputField(
                    label: "Confirm Password",
                    hintText: "confirm your password",
                    controller: confPasswordController,
                    obscure: true,
                  ),
                  const SizedBox(height: 24.0),
                    if (isLoading)
                      const CircularProgressIndicator()
                    else
                    Buttons(label: "REGISTER", fn: (){_register(context);}),
                    const SizedBox(height: 10,),
                    TextButton(
                      onPressed: (){
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: const Text(
                        "Already Registered? Click Here to Login",
                        style: TextStyle(
                          color: Color(0xFF4D4C7D),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF4D4C7D),
                        ),
                      )
                    ),
                    const SizedBox(height: 95,)                
                ],
              ),
            ),
          )
        )
    ),
    );
  }
  Future<void> _register(BuildContext context) async {
    String errorMessage = '';
    setState(() {
      isLoading = true;
    });

    try {
      // Validate input fields
      if (consNumController.text.trim().isEmpty) {
        errorMessage = "Consumer number is required.";
        throw Exception();        
      }
      if (emailController.text.trim().isEmpty) {
        errorMessage = "Email is required.";
        throw Exception();
      }
      if (phnoController.text.trim().isEmpty) {
        errorMessage = "Phone number is required.";
        throw Exception();
      }
      if (passwordController.text.isEmpty || confPasswordController.text.isEmpty) {
        errorMessage = "Password and Confirm Password are required.";
        throw Exception();
      }
      if (passwordController.text != confPasswordController.text) {
        errorMessage="Passwords do not match.";
        throw Exception();
      }

      // Check if the consumer exists in Firestore
      final consumer = FirebaseFirestore.instance
          .collection('consumer')
          .doc(consNumController.text.trim());
      final reg = FirebaseFirestore.instance
          .collection('registered')
          .doc(consNumController.text.trim());
       DocumentReference docRef  = FirebaseFirestore.instance
          .collection('consumer number')
          .doc(emailController.text.trim());
      final consumerDoc = await consumer.get();
      final regDoc = await reg.get();

      if (!consumerDoc.exists) {
        errorMessage = "This consumer number does not exist in the database.";
        throw Exception();
      }
      if (regDoc.exists) {
        errorMessage = "This consumer number is already registered.";
        throw Exception();
      }

      // Create a new user with Firebase Authentication
      await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Update Firestore with additional details
      await consumer.update({
        "email": emailController.text.trim(),
        "phno": phnoController.text.trim(),
      });
      await docRef.set({
        'cons no' : consNumController.text
      }); 
      DocumentReference regRef  = FirebaseFirestore.instance
          .collection('registered')
          .doc(consNumController.text.trim());
      await regRef.set({'reg':'1'});
      // Save email to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', emailController.text.trim());

      // Navigate to login page
      Navigator.of(context).pushReplacementNamed('/login');
      MySnackbar.show(context, "Successfully registered a new user.");
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Authentication errors
      
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = "This email is already registered.";
          break;
        case 'invalid-email':
          errorMessage = "The email address is not valid.";
          break;
        case 'weak-password':
          errorMessage = "The password is too weak.";
          break;
        default:
          errorMessage = "Error : ${e.code}";
      }
      MySnackbar.show(context, errorMessage);
    } on Exception {
      // Handle general errors
      MySnackbar.show(context, errorMessage);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

}



