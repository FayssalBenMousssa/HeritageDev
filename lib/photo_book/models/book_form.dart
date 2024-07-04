class BookForm {
  final String id;
  final String name;
  final String description;

  BookForm({
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

  static BookForm fromMap(Map<String, dynamic> map) {
    return BookForm(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
