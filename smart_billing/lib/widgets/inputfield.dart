import 'package:flutter/material.dart';




class InputField extends StatefulWidget {
  final String label;
  final String hintText;
  final bool isEnable;
  final bool obscure;
  final String obscureChar;
  final  controller;  // Updated to explicitly require a TextEditingController




  const InputField({
    super.key,
    this.hintText='',
    this.obscureChar = "●",
    this.isEnable = true,
    this.obscure = false,
    this.controller,
    this.label = ''
  });




  @override
  State<InputField> createState() => _InputFieldState();
}




class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              color: Color(0xFF4D4C7D),
              fontWeight: FontWeight.bold,
              fontSize: 16
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 5,),
          TextFormField(
            style: TextStyle(color: widget.isEnable ? Colors.black : Colors.black87),
            controller: widget.controller,
            obscureText: widget.obscure,
            obscuringCharacter: widget.obscureChar,
            enabled: widget.isEnable,
            maxLines: widget.obscure ? 1 : null, // Disable multiline when obscure is true
            keyboardType: widget.obscure ? TextInputType.visiblePassword : TextInputType.multiline,
            decoration: InputDecoration(
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF4D4C7D)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF4D4C7D)),
              ),
              hintText: widget.hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      )
    );
  }
}









