import 'package:flutter/material.dart';

class MySnackbar {
  static void show(BuildContext context,String msg){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[200],
          content: Text(msg, style: const TextStyle(color: Colors.black),),
          duration: const Duration(seconds: 3),
        )
      );
  }
}