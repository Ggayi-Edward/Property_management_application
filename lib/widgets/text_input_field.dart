import 'package:flutter/material.dart';

class TextInputField extends StatefulWidget {
  const TextInputField({
    required this.controller,
    required this.icon,
    required this.hint,
    required this.inputType,
    required this.inputAction,
    this.maxLines = 1,
    this.color = Colors.blue, // Added color parameter
    super.key,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final int maxLines;
  final Color color; // Added color parameter

  @override
  _TextInputFieldState createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // Optional: Uncomment if you want to clear text on focus
        // widget.controller.clear();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        height: size.height * 0.07, // Adjusted height
        width: size.width * 0.8,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _focusNode.hasFocus ? widget.color : Colors.transparent, // Use color parameter
            width: 2.0,
          ),
        ),
        child: Center(
          child: TextField(
            focusNode: _focusNode,
            controller: widget.controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: widget.color, // Use color parameter
                ),
              ),
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            keyboardType: widget.inputType,
            textInputAction: widget.inputAction,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
            maxLines: widget.maxLines,
          ),
        ),
      ),
    );
  }
}
