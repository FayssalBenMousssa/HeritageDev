import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? id;
  final String firstName;
  final String lastName;
  final String? telephone;
  final String? address;
  final String? password;
  final String role;
  final String email;
  final DateTime registrationDate;
  final DateTime lastLogin;
  final String? photoUrl;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.telephone,
    required this.address,
    required this.password,
    required this.role,
    required this.email,
    required this.registrationDate,
    required this.lastLogin,
    required this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'email': email,
      'registrationDate': registrationDate,
      'lastLogin': lastLogin,
      'photoUrl': photoUrl,
    };



    if (telephone != null) {
      map['telephone'] = telephone;
    }

    if (address != null) {
      map['address'] = address;
    }

    if (password != null) {
      map['password'] = password;
    }

    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      telephone: map['telephone'],
      address: map['address'] ,
      password: map['password'] ,
      role: map['role'] ?? '',
      email: map['email'] ?? '',
      registrationDate: _parseTimestamp(map['registrationDate']),
      lastLogin: _parseTimestamp(map['lastLogin']),
      photoUrl: map['photoUrl'] ?? '',
    );
  }

  static DateTime _parseTimestamp(Timestamp timestamp) {
    return DateTime.fromMicrosecondsSinceEpoch(
      timestamp.microsecondsSinceEpoch,
    );
  }
}
