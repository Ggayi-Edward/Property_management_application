// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton({
    super.key,
    required this.buttonName,
    required this.onPressed, // Added onPressed callback
  });

  final String buttonName;
  final VoidCallback onPressed; // Type for onPressed callback

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.08,
      width: size.width * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: const [Color(0xFF304FFE), Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.3, 1.0],
        ),
      ),
      child: TextButton(
        onPressed: onPressed, // Call the provided callback
        style: TextButton.styleFrom(
          foregroundColor: Colors.black, // Text color
        ),
        child: Text(
          buttonName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
