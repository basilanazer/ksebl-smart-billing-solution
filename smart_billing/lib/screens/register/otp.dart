import 'package:flutter/material.dart';
import 'package:smart_billing/widgets/button.dart';
import 'package:smart_billing/widgets/inputfield.dart';
class OTPverification extends StatefulWidget {
  final String phno;
  const OTPverification({super.key, required this.phno});

  @override
  OTPverificationState createState() => OTPverificationState();
}

class OTPverificationState extends State<OTPverification> {
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
                        "OTP VERIFICATION",
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
                        label: "OTP",
                        hintText: "enter the OTP send to ${widget.phno}",
                      ),
                      const SizedBox(height: 24.0),
                      Buttons(
                          fn: () {
                            
                          },
                          label: 'Verify',
                        ),
                      const SizedBox(
                        height: 300,
                      ),
                    ]
                  )
                )
              )
          )
      )
    );
  }
}