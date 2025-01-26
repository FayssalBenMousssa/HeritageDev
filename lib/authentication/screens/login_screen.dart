import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heritage/authentication/screens/registration_screen.dart';
import '../../home_screen.dart';
import 'email_login_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Google Sign-In Function
    Future<void> signInWithGoogle() async {
      try {
        // Trigger the Google Sign-In flow
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

          // Extract user details
          String firstName = '';
          String lastName = '';
          List<String> nameParts = googleUser.displayName?.split(' ') ?? [];
          if (nameParts.isNotEmpty) {
            firstName = nameParts[0];
            lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
          }

          // Create credentials for Firebase Authentication
          final credential = auth.GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          // Sign in with Firebase using the Google credentials
          auth.UserCredential userCredential =
          await auth.FirebaseAuth.instance.signInWithCredential(credential);

          // Check if the user is new or existing
          if (userCredential.additionalUserInfo?.isNewUser ?? false) {
            // New user - save user data to Firestore
            final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
            await usersCollection.doc(userCredential.user?.uid).set({
              'id': userCredential.user?.uid,
              'firstName': firstName,
              'lastName': lastName,
              'email': googleUser.email,
              'photoUrl': googleUser.photoUrl,
              'role': 'user',
              'registrationDate': DateTime.now(),
              'lastLogin': DateTime.now(),
            }, SetOptions(merge: true));
          } else {
            // Existing user - update their last login time
            await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).update({
              'lastLogin': DateTime.now(),
            });
          }

          // Navigate to the home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()), // Replace with your home screen
          );
        }
      } catch (e) {
        // Show an error message if Google Sign-In fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In failed: $e')),
        );
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF394773), // Blue background color
      body: SafeArea(
        child: Stack(
          children: [
            // Main Column Layout
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and Title
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Image.asset(
                        'assets/login_logo.png', // Add your logo image to assets
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Email Login Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to EmailLoginScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmailLoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF394773),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.email),
                        label: const Text(
                          'Se connecter avec mon Email',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.white70,
                          thickness: 1,
                          indent: 80,
                          endIndent: 10,
                        ),
                      ),
                      Text(
                        'ou continuer avec',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.white70,
                          thickness: 1,
                          indent: 10,
                          endIndent: 80,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Social Media Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      socialButton('assets/facebook.png', () {}),
                      const SizedBox(width: 20),
                      socialButton('assets/google.png', () => signInWithGoogle()),
                      const SizedBox(width: 20),
                      socialButton('assets/apple.png', () {}),
                    ],
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),

            // Bottom Section for Account Creation
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  // Navigate to CreateAccountScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegistrationScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Vous N'avez pas de Compte ?",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Social Media Button Widget
  Widget socialButton(String imagePath, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.white,
        child: Image.asset(
          imagePath,
          width: 30,
          height: 30,
        ),
      ),
    );
  }
}
