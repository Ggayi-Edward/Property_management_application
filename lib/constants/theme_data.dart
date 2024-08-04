import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor:Color(0xFF0D47A1), // Primary color: Dark Blue
  colorScheme: ColorScheme.light(
    primary: Color(0xFF0D47A1), // Dark Blue for top
    secondary: Colors.blue[100]!, // Very Light Blue for bottom
    background: Colors.white,
  ),
  appBarTheme: AppBarTheme(
    color: Color(0xFF0D47A1), // Dark Blue for AppBar
    iconTheme: IconThemeData(color: Colors.white),
    elevation: 4,
  ),
  scaffoldBackgroundColor: Colors.white,
  textTheme: TextTheme(
    titleLarge: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
    bodyMedium: TextStyle(color: Colors.black54, fontSize: 14),
  ),
  iconTheme: IconThemeData(color: Color(0xFF0D47A1)),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF0D47A1), // Dark Blue for buttons
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.blueGrey[900], // Primary color: Dark Blue Grey
  colorScheme: ColorScheme.dark(
    primary: Colors.blueGrey[900]!, // Dark Blue Grey for top
    secondary: Colors.blueGrey[700]!, // Light Blue Grey for bottom
    background: Colors.black,
  ),
  appBarTheme: AppBarTheme(
    color: Colors.blueGrey[900], // Dark Blue Grey for AppBar
    iconTheme: IconThemeData(color: Colors.white),
    elevation: 4,
  ),
  scaffoldBackgroundColor: Colors.black,
  textTheme: TextTheme(
    titleLarge: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(color: Colors.white, fontSize: 18),
    bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
  ),
  iconTheme: IconThemeData(color: Colors.blueGrey[300]),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueGrey[800], // Darker Blue Grey for buttons
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
);
