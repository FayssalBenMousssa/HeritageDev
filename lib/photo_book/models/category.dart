class Category {
  String id;
  String categoryName;
  String imageUrl;

  Category({
    required this.id,
    required this.categoryName,
    required this.imageUrl,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      categoryName: map['categoryName'],
      imageUrl: map['imageUrl'], // Assigns an empty string if the value is null

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryName': categoryName,
      'imageUrl': imageUrl,
    };
  }
}
