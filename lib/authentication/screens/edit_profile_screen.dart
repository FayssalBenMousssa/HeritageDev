import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heritage/authentication/models/user_model.dart';


class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _telephoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _telephoneController = TextEditingController(text: widget.user.telephone ?? '');
    _addressController = TextEditingController(text: widget.user.address ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _telephoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: _telephoneController,
              decoration: const InputDecoration(labelText: 'Telephone'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            ElevatedButton(
              onPressed: () {
                // Save the updated profile information
                _saveProfile();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() {
    // Get the updated values from the text controllers
    final String firstName = _firstNameController.text;
    final String lastName = _lastNameController.text;
    final String telephone = _telephoneController.text;
    final String address = _addressController.text;

    // Update the user object with the new values
    final updatedUser = User(
      id: widget.user.id,
      firstName: firstName,
      lastName: lastName,
      telephone: telephone,
      address: address,
      password: widget.user.password,
      role: widget.user.role,
      email: widget.user.email,
      registrationDate: widget.user.registrationDate,
      lastLogin: widget.user.lastLogin,
      photoUrl: widget.user.photoUrl,
    );

    // Save the updated user object to Firestore
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.id)
        .update(updatedUser.toMap())
        .then((_) {
      // Show a success message or navigate back to the profile screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    }).catchError((error) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    });
  }
}
