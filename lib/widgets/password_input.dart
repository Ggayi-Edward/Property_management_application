// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class PasswordInput extends StatelessWidget {
  const PasswordInput({
    required this.controller,
    required this.icon,
    required this.hint,
    this.inputType = TextInputType.text,
    required this.inputAction,
    super.key,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType inputType;
  final TextInputAction inputAction;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        height: size.height * 0.08,
        width: size.width * 0.8,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Icon(
                  icon,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.black,  // Hint text color
                fontSize: 16,        // Hint text size
              ),
            ),
            obscureText: true,
            keyboardType: inputType,
            textInputAction: inputAction,
            style: TextStyle(
              color: Colors.black,  // Text color
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
