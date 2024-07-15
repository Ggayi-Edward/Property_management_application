

// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton({
    super.key,
    required this.buttonName,
  });

  final String buttonName;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.08,
      width: size.width * 0.8,
      decoration: BoxDecoration(borderRadius:BorderRadius.circular(16),
      color:Colors.lightBlue),
      child: TextButton(
         onPressed: () {},
         style: TextButton.styleFrom(
         foregroundColor: Colors.black, // text color
    ), 
      child: Text(
        buttonName,
        style: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    ),
    );
  }
}