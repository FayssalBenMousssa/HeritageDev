import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'app_left_drawer.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String userEmail = user?.email ?? 'No email available';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      drawer: AppLeftDrawer(user: user),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to the Home Page!',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              'User Email: $userEmail',
              style: const TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () {
              },
              child: const Text('Store Data in Firebase'),
            ),
          ],
        ),
      ),
    );
  }
}
