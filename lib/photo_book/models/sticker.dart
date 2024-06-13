class Sticker {
  final int id;
  final String imageUrl;
  final String category;
  final String description;

  Sticker({
    required this.id,
    required this.imageUrl,
    required this.category,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'stickerId': id,
      'imageUrl': imageUrl,
      'category': category,
      'description': description,
    };
  }

  factory Sticker.fromMap(Map<String, dynamic> map) {
    return Sticker(
      id: map['id'],
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
