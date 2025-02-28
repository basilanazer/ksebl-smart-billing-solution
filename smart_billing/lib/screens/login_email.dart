import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_billing/widgets/button.dart';
import 'package:smart_billing/widgets/inputfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_billing/widgets/snackbar.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = FirebaseAuth.instance;
  bool isLoading = false;
  String msg = "Some unknown error occured";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4D4C7D),
      body: SafeArea(
        child: SingleChildScrollView(
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
                          height: 30,
                        ),
                        Image.asset(
                          'assets/icon.png',
                          width: 264,
                          height: 112,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // const Text(
                        //   "LOGIN",
                        //   style: TextStyle(
                        //     color: Color(0xFF4D4C7D),
                        //     fontSize: 32,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        const SizedBox(
                          height: 30,
                        ),
                        InputField(
                          label: "E-mail",
                          hintText: "Enter your email",
                          controller: emailController,
                        ),
                        //const SizedBox(height: 8),
                        InputField(
                          label: "Password",
                          hintText: "Enter your password",
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
                          Buttons(
                            fn: () {
                              login(context);
                            },
                            label: 'Login',
                          ),
                        const SizedBox(
                          height: 15,
                        ),
                        Buttons(
                          label: 'Login with phone instead',
                          fn: () {},
                          color: const Color(0xFFFD7250),
                          bgcolor: Colors.white,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushReplacementNamed('/register');
                            },
                            child: const Text(
                              "New Here? Click Here to Register",
                              style: TextStyle(
                                color: Color(0xFF4D4C7D),
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF4D4C7D),
                              ),
                            )),
                        const SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ),
                ))),
      ),
    );
  }

  Future<void> login(context) async {
    setState(() {
      isLoading = true;
    });
    try {
      await auth.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      print("logged in");
      // Save email to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', emailController.text);
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } on FirebaseAuthException catch (e) {
      setState(() {
        msg = "Incorrect email or password";
      });
      MySnackbar.show(context, msg);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     backgroundColor: Colors.red[200],
      //     content: Text(msg, style: const TextStyle(color: Colors.black),),
      //     duration: const Duration(seconds: 3),
      //   )
      // );
      print(e.message);
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
