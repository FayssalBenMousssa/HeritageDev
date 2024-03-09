class User {
  final String? id;
  final String firstName;
  final String lastName;
  final String telephone;
  final String address;
  final String password;
  final String role;
  final String email;
  final DateTime registrationDate;
  final DateTime lastLogin;

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
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'telephone': telephone,
      'address': address,
      'password': password,
      'role': role,
      'email': email,
      'registrationDate': registrationDate,
      'lastLogin': lastLogin,
    };
  }
}
