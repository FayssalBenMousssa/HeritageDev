import 'package:flutter/material.dart';
import 'package:heritage/authentication/login.dart';
import 'package:heritage/home_screen.dart';
import 'package:heritage/authentication/registration_screen.dart';


class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    '/login': (context) => const LoginScreen(),
    '/home': (context) => const HomeScreen(),
    '/registration_screen': (context) => const RegistrationScreen(),
    // Add more routes as needed
  };
}