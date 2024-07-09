class Category {
  final String id;
  final String categoryName;
  final String imageUrl;

  Category({required this.id, required this.categoryName, required this.imageUrl});

  factory Category.fromMap(Map<String, dynamic> data) {
    return Category(
      id: data['id'] ?? '',
      categoryName: data['categoryName'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryName': categoryName,
      'imageUrl': imageUrl,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.categoryName == categoryName &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => id.hashCode ^ categoryName.hashCode ^ imageUrl.hashCode;
}
