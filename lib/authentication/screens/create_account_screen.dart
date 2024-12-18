import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heritage/utiles/dialog_utils.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:heritage/authentication/models/user_model.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  String phoneNumber = '';

  bool _isPasswordVisible = false;

  // Registration Logic
  Future<void> register(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        auth.UserCredential userCredential = await auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        String? userId = userCredential.user?.uid;

        User newUser = User(
          id: userId,
          firstName: fullNameController.text.split(' ')[0],
          lastName: fullNameController.text.split(' ').length > 1 ? fullNameController.text.split(' ')[1] : '',
          telephone: phoneNumber,
          address: '',
          password: passwordController.text,
          role: 'user',
          email: emailController.text,
          registrationDate: DateTime.now(),
          lastLogin: DateTime.now(),
          photoUrl: '',
        );

        final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
        await usersCollection.doc(newUser.id).set(newUser.toMap());

        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        String errorMessage = 'Registration failed. Please try again.';
        if (e is auth.FirebaseAuthException) {
          switch (e.code) {
            case 'weak-password':
              errorMessage = 'The password provided is too weak.';
              break;
            case 'email-already-in-use':
              errorMessage = 'The account already exists for that email.';
              break;
            case 'invalid-email':
              errorMessage = 'The email address is not valid.';
              break;
          }
        }
        DialogUtils.showCustomDialog(context, 'Registration Error', errorMessage, Icons.error, Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Sign Up with Email',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Full Name Field
                    TextFormField(
                      controller: fullNameController,
                      decoration: InputDecoration(
                        hintText: 'Full Name',
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Email Field
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Password Field
                    TextFormField(
                      controller: passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Phone Field
                    IntlPhoneField(
                      decoration: InputDecoration(
                        hintText: 'Phone Number',
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      initialCountryCode: 'MA',
                      onChanged: (phone) {
                        phoneNumber = phone.completeNumber;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () => register(context),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Social Login
                    const Text(
                      'or Sign Up with',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Image.asset('assets/icons/facebook.png'),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Image.asset('assets/icons/google.png'),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Image.asset('assets/icons/apple.png'),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
