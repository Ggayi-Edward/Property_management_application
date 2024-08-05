import 'package:flutter/material.dart';

class RoundedButton extends StatefulWidget {
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
  _RoundedButtonState createState() => _RoundedButtonState();
}

class _RoundedButtonState extends State<RoundedButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Size size = MediaQuery.of(context).size;
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTapDown: (_) => _onTap(true),
        onTapUp: (_) => _onTap(false),
        onTapCancel: () => _onTap(false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _isPressed ? 42 : 45, // Slightly smaller when pressed
          width: _isHovered ? size.width * 0.75 : size.width * 0.7, // Slightly larger when hovered
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: widget.color ?? theme.colorScheme.primary,
            boxShadow: _isHovered
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ]
                : [],
          ),
          child: TextButton(
            onPressed: widget.onPressed,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              widget.buttonName,
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }

  void _onTap(bool isPressed) {
    setState(() {
      _isPressed = isPressed;
    });
  }
}
