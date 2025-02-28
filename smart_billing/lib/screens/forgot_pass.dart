import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_billing/widgets/button.dart';
import 'package:smart_billing/widgets/inputfield.dart';
import 'package:smart_billing/widgets/snackbar.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  
  @override
  State<ForgotPasswordPage> createState() => ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
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
                      const SizedBox(
                        height: 80,
                      ),
                      Image.asset(
                        'assets/lock.png',
                        width: 115,
                        height: 115,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      const Text(
                        "TROUBLE LOGGING IN ?",
                        style: TextStyle(
                          color: Color(0xFF4D4C7D),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "Enter your email and we will send you a link to reset your password ?",                         
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      InputField(
                        label: "E-mail",
                        hintText: "enter your email",
                        controller: emailController,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      if (isloading)
                        const CircularProgressIndicator()
                      else
                        Buttons(
                          fn: () {
                            resetpswd(emailController.text.trim(),context);
                          },
                          label: 'Reset Password',
                        ),
                        const SizedBox(height: 220,)
                    ]
                  )
                )
              )
          )
      )                
    );
  }
  void resetpswd(String email, BuildContext context) async {
    setState(() {
      isloading = true;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      MySnackbar.show(
        context, "An email containing instructions to reset your password has been sent to your email address.",
      );
    } on FirebaseAuthException {
      // print(e);
      MySnackbar.show(
          context, "Some unknown error occured please try again");
    }
    finally{
      setState(() {
        isloading = false;
      });
    }
  }
}