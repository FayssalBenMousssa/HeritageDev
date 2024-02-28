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
      foregroundColor: MaterialStateProperty.all(const Color(0xFFFFFFFF)), // Set text color to white
    ),
  ),
);
