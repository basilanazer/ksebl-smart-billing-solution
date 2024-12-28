import 'package:flutter/material.dart';
class Buttons extends StatelessWidget {
  final String label;
  final Function() fn;
  final Color? bgcolor;
  final Color? color;
  const Buttons({
    super.key,
    required this.label,
    required this.fn,
    this.bgcolor = const Color(0xFFFD7250),
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: fn,
          style: ElevatedButton.styleFrom(
            foregroundColor: color, 
            backgroundColor: bgcolor, // Text color
            shape: RoundedRectangleBorder(                    
              borderRadius: BorderRadius.circular(10), // Corner radius
              side: const BorderSide(
                color: Color(0xFFFD7250), // Border color
                width: 2,                // Border width
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10), // Vertical padding
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
    );
  }
}