import 'package:flutter/material.dart';
import 'package:heritage/authentication/models/user_model.dart';
import 'package:heritage/authentication/screens/login_screen.dart';
import 'package:heritage/home_screen.dart';
import 'package:heritage/authentication/screens/registration_screen.dart';
import 'package:heritage/authentication/screens/profile_screen.dart';
import 'package:heritage/authentication/screens/edit_profile_screen.dart';
import 'package:heritage/photo_book/screens/category//category_screen.dart';
import 'package:heritage/photo_book/screens/layout/layout_list_screen.dart';
import 'package:heritage/photo_book/screens/template/template_screen.dart';
import 'package:heritage/photo_book/screens/client/photo_book_client_screen.dart';
import 'package:heritage/photo_book/screens/image_editor_screen.dart';
import 'package:heritage/photo_book/screens/layout/layout_list_screen_new.dart';
import 'package:heritage/photo_book/screens/client/creation_photo_book_screen.dart';

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
    '/photo_book': (context) => const TemplateScreen(),
    '/photo_book_client': (context) => const TemplateClientScreen(),
    '/layout_list_screen': (context) => const LayoutListScreen(),
    '/layout_list_screen_new': (context) => const LayoutListScreenNew(),
    '/image_editor': (context) => ImageEditorScreen() ,

    // Add more routes as needed
  };
}
