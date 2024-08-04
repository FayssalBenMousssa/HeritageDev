import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../home_screen.dart';
import '../models/user_model.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    final GoogleSignIn googleSignIn = GoogleSignIn();

    Future<void> signInWithGoogle() async {
      try {
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
          String firstName ='';
          String lastName ='';
            List<String> nameParts = googleUser.displayName!.split(' ');
            if (nameParts.length > 1) {
                firstName = nameParts[0];
                lastName = nameParts.sublist(1).join(' ');
            } else {
              firstName = nameParts[0];
            }
          final credential = auth.GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken,);
          auth.UserCredential userCredential = await auth.FirebaseAuth.instance.signInWithCredential(credential);
          final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

          User newUser = User(
            id: userCredential.user?.uid,
            firstName: firstName,
            lastName: lastName,
            telephone: null,
            address: null,
            password: null,
            role: 'user',
            email: googleUser.email,
            registrationDate: DateTime.now(),
            lastLogin: DateTime.now(),
            photoUrl: googleUser.photoUrl,
          );

          // Save user data to Firestore
          await usersCollection.doc(userCredential.user?.uid).set(newUser.toMap());
          // Navigate to the HomeScreen after successful login
          Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()),);
        }
      } catch (e) {
        // Handle errors, e.g., display an error message
        print(e); // For debugging
      }
    }

    Future<void> signInWithEmailAndPassword(BuildContext context) async {
      try {
        auth.UserCredential userCredential = await auth.FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        // Navigate to the HomeScreen after successful login
        Navigator.pushReplacementNamed(context, '/home');

      } catch (e) {
        // Handle login errors, e.g., display an error message
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login failed. Please check your credentials.')));
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView( // Wrap the Column with SingleChildScrollView
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset('assets/logo.png', width: 100, height: 100),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        signInWithEmailAndPassword(context); // Call the login function
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Login'),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Call the registration function
                        Navigator.pushNamed(context, '/registration_screen');
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Register'),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => signInWithGoogle(),
                      icon: const Icon(Icons.g_mobiledata),
                      label: const Text('Sign in with Google'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
