class CoverFinish {
  final String id;
  final String name;
  final String description;

  CoverFinish({
    required this.id,
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  static CoverFinish fromMap(Map<String, dynamic> map) {
    return CoverFinish(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
