import 'dart:developer';

import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'login.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<void> main() async {


  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Check if Firebase has been initialized
  if (Firebase.apps.isNotEmpty) {
    log('Firebase has been initialized successfully');
  } else {
    log('Firebase initialization failed');
  }


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: customTheme,
      home: const LoginScreen(),
    );
  }
}

