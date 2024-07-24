import 'package:flutter/material.dart';

class PasswordInput extends StatefulWidget {
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
  _PasswordInputState createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

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
            controller: widget.controller,
            obscureText: _obscureText,
            keyboardType: widget.inputType,
            textInputAction: widget.inputAction,
            style: TextStyle(
              color: Colors.black,  // Text color
              fontSize: 16,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: Colors.black,  // Hint text color
                fontSize: 16,        // Hint text size
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: _toggleVisibility,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
