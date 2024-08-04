import 'package:flutter/material.dart';
import 'package:heritage/authentication/models/user_model.dart';
import 'package:heritage/authentication/screens/login_screen.dart';
import 'package:heritage/home_screen.dart';
import 'package:heritage/authentication/screens/registration_screen.dart';
import 'package:heritage/authentication/screens/profile_screen.dart';
import 'package:heritage/authentication/screens/edit_profile_screen.dart';
import 'package:heritage/photo_book/screens/category_screen.dart';
import 'package:heritage/photo_book/screens/photo_book_screen.dart';
import 'package:heritage/photo_book/screens/photo_book_client_screen.dart';



class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    '/login': (context) => const LoginScreen(),
    '/home': (context) => const HomeScreen(),
    '/registration_screen': (context) => const RegistrationScreen(),
    '/profile': (context) => const ProfileScreen(),
    '/edit_profile': (context) {
      final User user = ModalRoute.of(context)!.settings.arguments as User;
      return EditProfileScreen(user: user);
    },
    '/category': (context) => const CategoryScreen(),
    '/photo_book': (context) => const PhotoBookScreen(),
    '/photo_book_client': (context) => const PhotoBookClientScreen(),
    // Add more routes as needed
  };
}
