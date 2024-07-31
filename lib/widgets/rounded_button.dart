import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton({
    super.key,
    required this.buttonName,
    required this.onPressed,
    this.color, // Optional: Color for the button
  });

  final String buttonName;
  final VoidCallback onPressed;
  final Color? color; // Optional: Color for the button

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 45, // Adjusted height
      width: size.width * 0.7, // Adjusted width
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: color ?? theme.colorScheme.primary, // Use provided color or theme color
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Adjusted padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          buttonName,
          style: theme.textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold, // Bold font weight
          ),
        ),
      ),
    );
  }
}
