

import 'package:heritage/photo_book/models/template.dart';

import '../../authentication/models/user_model.dart';

class ClientBooks {
  final String id; // Unique identifier for the ClientBooks
  final User user; // User who created the ClientBooks
  final List<Template> templates; // List of associated templates

  ClientBooks({
    required this.id,
    required this.user,
    required this.templates,
  });

  // Convert ClientBooks object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user': user.toMap(), // Ensure User is converted to a map
      'templates': templates.map((template) => template.toMap()).toList(), // Ensure each Template is converted to a map
    };
  }

  // Create a ClientBooks object from a map
  static ClientBooks fromMap(Map<String, dynamic> map) {
    return ClientBooks(
      id: map['id'] ?? '', // Assign default value if not present
      user: User.fromMap(map['user'] as Map<String, dynamic>), // Convert user from map
      templates: (map['templates'] as List<dynamic>?)
          ?.map((templateMap) => Template.fromMap(templateMap as Map<String, dynamic>))
          .toList() ?? [], // Convert each template from map
    );
  }
}
