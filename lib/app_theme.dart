import 'package:flutter/material.dart';

final ThemeData customTheme = ThemeData(
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: const MaterialColor(0xFF4F5D75, {
      50: Color(0xFFF6F5F1),
      100: Color(0xFFF6F5F1),
      200: Color(0xFFF6F5F1),
      300: Color(0xFFF6F5F1),
      400: Color(0xFFF6F5F1),
      500: Color(0xFFF6F5F1),
      600: Color(0xFF4F5D75),
      700: Color(0xFF4F5D75),
      800: Color(0xFF4F5D75),
      900: Color(0xFF4F5D75),
    }),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(const Color(0xFF4F5D75)),
      foregroundColor: MaterialStateProperty.all(const Color(0xFFFFFFFF)),

      shape: MaterialStateProperty.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.0),
      )),
    ),
  ),

  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue),
    ),
    labelStyle: TextStyle(color: Colors.black),
    hintStyle: TextStyle(color: Colors.grey),
  ),
  // Existing colorScheme and other properties
  dialogTheme: DialogTheme(  // Add this line
    backgroundColor: Colors.white, // Set background color
    shape: RoundedRectangleBorder(  // Set rounded corners
      borderRadius: BorderRadius.circular(3.0),
    ),
    contentTextStyle: const TextStyle(fontSize: 16.0), // Set text style
  ),
);
