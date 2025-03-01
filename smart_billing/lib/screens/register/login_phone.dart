import 'package:flutter/material.dart';
import 'package:smart_billing/screens/register/otp.dart';
import 'package:smart_billing/widgets/button.dart';
import 'package:smart_billing/widgets/inputfield.dart';
class LoginPhno extends StatefulWidget {
  const LoginPhno({super.key});

  @override
  LoginPhnoState createState() => LoginPhnoState();
}

class LoginPhnoState extends State<LoginPhno> {
  final phnoController = TextEditingController();
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
                      const SizedBox(
                        height: 60,
                      ),
                      Image.asset(
                        'assets/icon.png',
                        width: 264,
                        height: 112,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      const Text(
                        "LOGIN",
                        style: TextStyle(
                          color: Color(0xFF4D4C7D),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      InputField(
                        label: "Phone number",
                        hintText: "enter your registered phone number",
                        controller: phnoController,
                      ),
                      const SizedBox(height: 10),
                      const Text("an otp will be sent to this phone number"),
                      const SizedBox(height: 24.0),
                      Buttons(
                          fn: () {
                             Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return OTPverification(phno: phnoController.text.trim());
                            }));
                          },
                          label: 'Get OTP',
                        ),
                      const SizedBox(
                        height: 300,
                      ),
                    ],
                  ),
                ),
              ))),
                );
  }
  
}