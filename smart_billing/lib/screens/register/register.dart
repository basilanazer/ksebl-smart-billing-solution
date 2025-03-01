

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
      )
        )
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
       
       DocumentReference consumerno  = FirebaseFirestore.instance
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
      await consumerno.set({
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


//// ignore_for_file: avoid_print

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:smart_billing/widgets/button.dart';
// import 'package:smart_billing/widgets/inputfield.dart';
// import 'package:smart_billing/widgets/snackbar.dart';

// class Register extends StatefulWidget {
//   const Register({super.key});

//   @override
//   RegisterState createState() => RegisterState();
// }

// class RegisterState extends State<Register> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confPasswordController = TextEditingController();
//   final phnoController = TextEditingController();
//   final consNumController = TextEditingController();
//   final auth = FirebaseAuth.instance;

//   bool isLoading = false;
//   String verificationId = '';
//   bool otpSent = false;
//   final otpController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: WillPopScope(
//         onWillPop: () async {
//           return await _showExitDialog(context);
//         },
//         child: Scaffold(
//           backgroundColor: const Color(0xFF4D4C7D),
//           body: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(30),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const SizedBox(height: 10),
//                       Image.asset('assets/icon.png', width: 210, height: 90),
//                       const SizedBox(height: 25),
//                       const Text(
//                         "REGISTER",
//                         style: TextStyle(
//                           color: Color(0xFF4D4C7D),
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 30),
//                       InputField(
//                         label: "Consumer Number",
//                         hintText: "Enter your consumer number",
//                         controller: consNumController,
//                       ),
//                       InputField(
//                         label: "Email",
//                         hintText: "Enter your email",
//                         controller: emailController,
//                       ),
//                       InputField(
//                         label: "Phone Number",
//                         hintText: "Enter your phone number",
//                         controller: phnoController,
//                       ),
//                       InputField(
//                         label: "Password",
//                         hintText: "Enter your password",
//                         controller: passwordController,
//                         obscure: true,
//                       ),
//                       InputField(
//                         label: "Confirm Password",
//                         hintText: "Confirm your password",
//                         controller: confPasswordController,
//                         obscure: true,
//                       ),
//                       if (otpSent)
//                         InputField(
//                           label: "OTP",
//                           hintText: "Enter OTP",
//                           controller: otpController,
//                         ),
//                       const SizedBox(height: 24.0),
//                       if (isLoading)
//                         const CircularProgressIndicator()
//                       else
//                         Buttons(
//                           label: otpSent ? "VERIFY OTP" : "REGISTER",
//                           fn: otpSent ? _verifyOtp : _sendOtp,
//                         ),
//                       const SizedBox(height: 10),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.of(context).pushReplacementNamed('/login');
//                         },
//                         child: const Text(
//                           "Already Registered? Click Here to Login",
//                           style: TextStyle(
//                             color: Color(0xFF4D4C7D),
//                             decoration: TextDecoration.underline,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 95),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<bool> _showExitDialog(BuildContext context) async {
//     return await showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text("Exit"),
//             content: const Text("Are you sure you want to exit?"),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(true),
//                 child: const Text(
//                   'Yes',
//                   style: TextStyle(color: Color(0xFF4D4C7D), fontWeight: FontWeight.bold),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(false),
//                 child: const Text(
//                   'No',
//                   style: TextStyle(color: Color(0xFFFD7250), fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ],
//           ),
//         ) ??
//         false;
//   }

//   Future<void> _sendOtp() async {
//     String phoneNumber = "+91${phnoController.text.trim()}";

//     setState(() {
//       isLoading = true;
//     });

//     await auth.verifyPhoneNumber(
//       phoneNumber: phoneNumber,
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         await auth.signInWithCredential(credential);
//         _registerUser();
//       },
//       verificationFailed: (FirebaseAuthException e) {
//         setState(() {
//           isLoading = false;
//         });
//         MySnackbar.show(context, "Verification failed: ${e.message}");
//       },
//       codeSent: (String verificationId, int? resendToken) {
//         setState(() {
//           this.verificationId = verificationId;
//           otpSent = true;
//           isLoading = false;
//         });
//         MySnackbar.show(context, "OTP sent to your phone.");
//       },
//       codeAutoRetrievalTimeout: (String verificationId) {
//         this.verificationId = verificationId;
//       },
//     );
//   }

//   Future<void> _verifyOtp() async {
//     String smsCode = otpController.text.trim();
//     PhoneAuthCredential credential = PhoneAuthProvider.credential(
//       verificationId: verificationId,
//       smsCode: smsCode,
//     );

//     try {
//       await auth.signInWithCredential(credential);
//       _registerUser();
//     } catch (e) {
//       MySnackbar.show(context, "Invalid OTP. Please try again.");
//     }
//   }

//   Future<void> _registerUser() async {
//     String email = emailController.text.trim();
//     String consumerNumber = consNumController.text.trim();
//     String phone = phnoController.text.trim();
//     String password = passwordController.text.trim();

//     try {
//       UserCredential userCredential = await auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       await userCredential.user?.updatePhoneNumber(
//         PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otpController.text.trim()),
//       );

//       DocumentReference consumerRef =
//           FirebaseFirestore.instance.collection('consumer').doc(consumerNumber);
//       DocumentReference registeredRef =
//           FirebaseFirestore.instance.collection('registered').doc(consumerNumber);

//       await consumerRef.update({"email": email, "phno": phone});
//       await registeredRef.set({'reg': '1'});

//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('email', email);

//       Navigator.of(context).pushReplacementNamed('/login');
//       MySnackbar.show(context, "Successfully registered.");
//     } catch (e) {
//       MySnackbar.show(context, "Error: ${e.toString()}");
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
// }

