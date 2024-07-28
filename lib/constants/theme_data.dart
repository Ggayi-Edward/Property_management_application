import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
  appBarTheme: AppBarTheme(
    color: Colors.blue,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  scaffoldBackgroundColor: Colors.white,
  textTheme: TextTheme(
    titleLarge: TextStyle(color: Colors.black), // Header text style
    titleMedium: TextStyle(color: Colors.black), // Subheader text style
    bodyLarge: TextStyle(color: Colors.black), // Body text style
    bodyMedium: TextStyle(color: Colors.black), // Body text style
  ),
  iconTheme: IconThemeData(color: Colors.black), // Icon color
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blue,
  appBarTheme: AppBarTheme(
    color: Colors.blueGrey,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  scaffoldBackgroundColor: Colors.black,
  textTheme: TextTheme(
    titleLarge: TextStyle(color: Colors.white), // Header text style
    titleMedium: TextStyle(color: Colors.white), // Subheader text style
    bodyLarge: TextStyle(color: Colors.white), // Body text style
    bodyMedium: TextStyle(color: Colors.white), // Body text style
  ),
  iconTheme: IconThemeData(color: Colors.white), // Icon color
);
