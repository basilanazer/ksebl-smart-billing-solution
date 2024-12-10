

// ignore_for_file: avoid_print


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_billing/widgets/inputfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:mediwise/register/reset_password.dart';




class Login extends StatefulWidget{
  const Login({super.key});
 
  @override
  LoginState createState() => LoginState();
}


class LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confPasswordController = TextEditingController();
  final phnoController = TextEditingController();
  final consNumController = TextEditingController();
  final userNameController = TextEditingController();
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
                  const SizedBox(height: 8,),
                  //username
                  InputField(
                    label: "Username",
                    isEnable: false,
                    controller: userNameController,
                  ),
                  const SizedBox(height: 8),
                  //email
                  InputField(
                    label: "Email",
                    hintText: "enter your email",
                    controller: emailController,
                  ),
                  const SizedBox(height: 8),
                  //phno
                  InputField(
                    label: "Phone Number",
                    hintText: "enter your phone number",
                    controller: phnoController,
                  ),
                  const SizedBox(height: 8),
                  //password
                  InputField(
                    label: "Password",
                    hintText: "enter your password",
                    controller: passwordController,
                    obscure: true,
                  ),
                  const SizedBox(height: 8),
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
                    ElevatedButton(
                      onPressed: (){_register(context);},
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFFFD7250), // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Corner radius
                        ),
                        minimumSize: const Size(320, 45), // Width and height
                      ),
                      child: const Text('REGISTER',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                    ),
                    const SizedBox(height: 10,),
                    TextButton(
                      onPressed: (){},
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
  Future<void> _register(context) async {
    setState(() {
      isLoading = true;
    });
    try {
      final consumer = FirebaseFirestore.instance.collection('users').doc(consNumController.text);
      final consumerDoc = await consumer.get();
      if (!consumerDoc.exists) {
        throw Exception("This consumer number doesnt exist");
      }
      userNameController.value = consumerDoc["name"];
      if (passwordController.text!=confPasswordController.text) {
        throw Exception("Password doesnt Match");
      }      
      await auth.createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text);
      await consumer.set({
        "email" : emailController.text,
        "phno" : phnoController.text,
      });
      //await auth.verifyPhoneNumber();
      print("registered");
      // Save email to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', emailController.text);
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } catch (e){      
      setState(() {
        msg = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[200],
          content: Text(msg, style: const TextStyle(color: Colors.black),),
          duration: const Duration(seconds: 3),
        )
      );
    }
    finally{
      setState(() {
        isLoading = false;
      });
     
    }
  }
}



