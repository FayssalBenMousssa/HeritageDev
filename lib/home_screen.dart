import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String userEmail = user?.email ?? 'No email available';

    // Generate a random name
    String generateRandomName() {
      List<String> names = ['Alice', 'Bob', 'Charlie', 'David', 'Eve', 'Frank', 'Grace', 'Henry'];
      Random random = Random();
      return names[random.nextInt(names.length)];
    }

// Generate a random age between 18 and 60
    int generateRandomAge() {
      Random random = Random();
      return 18 + random.nextInt(43); // Generates a random age between 18 and 60
    }

// Store random data in Firestore
    Future<void> storeRandomDataInFirestore() async {
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      await users.doc(user?.uid).set({
        'email': user?.email,
        'name': generateRandomName(),
        'age': generateRandomAge(),
        'Hello' :'Test'
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
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
                storeRandomDataInFirestore(); // Call the function to store data in Firebase
              },
              child: const Text('Store Data in Firebase'),
            ),
          ],
        ),
      ),
    );
  }
}
