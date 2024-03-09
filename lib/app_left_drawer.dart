import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppLeftDrawer extends StatelessWidget {
  final User? user;

  const AppLeftDrawer({super.key, required this.user});

  void _logout(BuildContext context) {
    // Capture the context before the async operation
    final currentContext = context;
    FirebaseAuth.instance.signOut().then((_) {
      // Close the drawer using the captured context
      Navigator.pop(currentContext);
      // Navigate to the login page using the captured context
      Navigator.pushReplacementNamed(currentContext, '/login');
    }).catchError((error) {
      // Handle any errors that occur during sign out
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
            title: const Text('Item 1'),
            onTap: () {
              // Handle item 1 tap
            },
          ),
          ListTile(
            title: const Text('Item 2'),
            onTap: () {
              // Handle item 2 tap
            },
          ),
          // Add more list items as needed
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
