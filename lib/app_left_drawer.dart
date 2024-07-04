import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppLeftDrawer extends StatelessWidget {
  final User? user;

  const AppLeftDrawer({Key? key, required this.user});

  void _logout(BuildContext context) {
    final currentContext = context;
    FirebaseAuth.instance.signOut().then((_) {
      Navigator.pop(currentContext);
      Navigator.pushReplacementNamed(currentContext, '/login');
    }).catchError((error) {
      log('Error signing out: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? 'No name available'),
            accountEmail: Text(user?.email ?? 'No email available'),
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            title: const Text('Profile'),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            title: const Text('Category'),
            onTap: () {
              Navigator.pushNamed(context, '/category');
            },
          ),
          ListTile(
            title: const Text('Photo Books  '), // Add menu item for Photo Books
            onTap: () {
              Navigator.pushNamed(context, '/photo_book');
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              _logout(context);
            },
          ),
        ],
      ),
    );
  }
}
