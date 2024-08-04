import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:heritage/authentication/models/user_model.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);


  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User> userFuture;
  late User profile ;

  @override
  void initState() {
    super.initState();
    userFuture = loadUserData();

  }

  Future<User> loadUserData() async {
    auth.User? user = auth.FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        final userData = snapshot.data();
        if (userData != null) {
          profile = User.fromMap(userData);
          return profile;
        } else {
          log('User data is null. Document might not exist for user.uid : ${user.uid}');
          throw Exception('User data not found');
        }
      } catch (e, stackTrace) {
        log('Error fetching user data: $e\n$stackTrace');
        throw Exception('Error fetching user data');
      }
    } else {
      throw Exception('Google user not authenticated');
    }
  }




    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to the edit profile screen
              Navigator.pushReplacementNamed(
                context,
                '/edit_profile',
                arguments: profile,
              );

            },
          ),
        ],
      ),
      body: FutureBuilder<User>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading user data'),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('User not found'),
            );
          } else {
            final userData = snapshot.data!;
            final String firstName = userData.firstName ?? '';
            final String lastName = userData.lastName ?? '';
            final String? photoUrl = userData.photoUrl;
            final String? telephone = userData.telephone;
            final String? address = userData.address;
            final String role = userData.role;
            final String email = userData.email;
            final String lastLogin = userData.lastLogin.toString();

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: photoUrl != null
                        ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                    ).image
                        : Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/1/1e/Default-avatar.jpg', // Replace with your default avatar URL
                      fit: BoxFit.cover,
                    ).image,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Name: $firstName $lastName',
                    style: const TextStyle(fontSize: 20),
                  ),
                  if (telephone != null) Text('Telephone: $telephone'),
                  if (address != null) Text('Address: $address'),
                  if (role != null) Text('Role: $role'),
                  if (email != null) Text('Email: $email'),
                  if (lastLogin != null) Text('Last Login: $lastLogin'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
