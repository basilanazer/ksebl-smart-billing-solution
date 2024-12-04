

// ignore_for_file: avoid_print


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_billing/widgets/inputfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:mediwise/register/reset_password.dart';




class Login extends StatefulWidget{
  const Login({super.key});
 
  @override
  LoginState createState() => LoginState();
}


class LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
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
                  const SizedBox(height: 60,),
                  Image.asset('assets/icon.png',width: 264, height: 112,),
                  const SizedBox(height: 40,),
                  const Text(
                    "LOGIN",
                    style: TextStyle(
                      color: Color(0xFF4D4C7D),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30,),
                  InputField(
                    label: "E-mail",
                    hintText: "enter your email",
                    controller: emailController,
                  ),
                  const SizedBox(height: 8),
                  InputField(
                    label: "Password",
                    hintText: "enter your password",
                    controller: passwordController,
                    obscure: true,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                        //Navigator.of(context).pushNamed('/resetpas');
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Color(0xFF4D4C7D),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF4D4C7D),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                    if (isLoading)
                      const CircularProgressIndicator()
                    else
                    ElevatedButton(
                      onPressed: (){login(context);},
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFFFD7250), // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Corner radius
                        ),
                        minimumSize: const Size(320, 45), // Width and height
                      ),
                      child: const Text('LOGIN',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                    ),             
                    const SizedBox(height: 15,),

                    ElevatedButton(
                      onPressed: (){},
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color(0xFFFD7250), 
                        backgroundColor: Colors.white, // Text color
                        shape: RoundedRectangleBorder(                    
                          borderRadius: BorderRadius.circular(10), // Corner radius
                          side: const BorderSide(
                            color: Color(0xFFFD7250), // Border color
                            width: 2,                // Border width
                          ),
                        ),
                        minimumSize: const Size(320, 45), // Width and height
                      ),
                      child: const Text('Login with phone instead'),
                    ),  
                  
                    const SizedBox(height: 10,),
                    TextButton(
                      onPressed: (){},
                      child: const Text(
                        "New Here? Click Here to Register",
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
  Future<void> login(context) async {
    setState(() {
      isLoading = true;
    });
    try {
      await auth.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);
      print("logged in");
      // Save email to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', emailController.text);
      Navigator.of(context).pushReplacementNamed('/dashboard');


     
    } on FirebaseAuthException catch (e) {
      setState(() {
        msg = "Incorrect email or password";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[200],
          content: Text(msg, style: const TextStyle(color: Colors.black),),
          duration: const Duration(seconds: 3),
        )
      );
      print(e.message);
    }
    catch (e){      
      print(e);
    }
    finally{
      setState(() {
        isLoading = false;
      });
     
    }
  }
}



