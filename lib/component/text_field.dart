import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  // final String prefixIcon;
  const MyTextField(
      {super.key,
        required this.controller,
        required this.hintText,
        required this.obscureText,
      });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red)
        ),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white)
        ),
        fillColor: Colors.grey[400],
        filled: true,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.white,
        )
      ),
    );
  }
}
