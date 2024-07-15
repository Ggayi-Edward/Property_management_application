import 'package:flutter/material.dart';

class AppColors {
  static const white = Colors.white;
  static const black = Colors.black;
  static const grey = Colors.grey;
  static const grey20 = Color(0xFFEEEEEE);
  static const lightGrey = Color(0xFFBDBDBD);
  static const red = Colors.redAccent;
  static const green = Colors.green;

  static const appButtonGradient = LinearGradient(
    colors: [Color(0xFF304FFE), Colors.lightBlueAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const inactiveIndicator = Color(0xFFB7B3B3);
  static const activeIndicator = Color(0xFF332F2F);
}
