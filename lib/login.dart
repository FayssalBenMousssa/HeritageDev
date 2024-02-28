import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController(text: 'HeritageBookApp@gmail.com');
    TextEditingController passwordController = TextEditingController(text: 'AbirBerbeche');

    Future<void> signInWithEmailAndPassword(BuildContext context) async {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        // Navigate to the HomeScreen after successful login
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset('assets/logo.png', width: 100, height: 100), // Replace 'assets/logo.png' with your logo image path
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
