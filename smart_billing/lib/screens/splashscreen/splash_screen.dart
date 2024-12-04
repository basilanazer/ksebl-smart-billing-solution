import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(context).pushReplacementNamed('/home'); 
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9A9AC3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/icon.png',width: 264, height: 112,),
            const SizedBox(height: 40),
            Container(
              width: 200,
              child: const LinearProgressIndicator(color: Colors.white,minHeight: 25,semanticsValue: "loading...",borderRadius: BorderRadius.all(Radius.circular(15)),),
            )
            
            //const CircularProgressIndicator(color: Colors.white,),
          ],
        ),
      ),
    );
  }
}
