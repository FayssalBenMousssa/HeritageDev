class PaperFinish {
  final String id;
  final String name;
  final String description;

  PaperFinish({
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

  static PaperFinish fromMap(Map<String, dynamic> map) {
    return PaperFinish(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
