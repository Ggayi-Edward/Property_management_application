import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton({
    super.key,
    required this.buttonName,
    required this.onPressed,
  });

  final String buttonName;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 45, // Reduced height
      width: size.width * 0.7, // Reduced width
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.blue, // Solid color to match theme
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.white, // Text color
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Adjusted padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          buttonName,
          style: TextStyle(
            fontSize: 16, // Consistent font size
            fontWeight: FontWeight.bold, // Bold font weight
          ),
        ),
      ),
    );
  }
}
