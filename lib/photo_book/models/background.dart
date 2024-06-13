class Background {
  final String id;
  final String imageUrl;

  Background({
    required this.id,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
    };
  }

  factory Background.fromMap(Map<String, dynamic> map) {
    return Background(
      id: map['id'],
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}
