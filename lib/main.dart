import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heritage/home_screen.dart';

import 'app_theme.dart';
import 'authentication/screens/login_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app_routes.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your  application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: customTheme,
      routes: AppRoutes.routes,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while checking the user's authentication state
            return const CircularProgressIndicator();
          } else if (snapshot.hasData) {
            // User is already logged in, navigate to the home screen
            return const HomeScreen();
          } else {
            // User is not logged in, navigate to the login screen
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
