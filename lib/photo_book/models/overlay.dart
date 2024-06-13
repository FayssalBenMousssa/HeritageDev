class Overlay {
  final int id;
  final String imageUrl;

  Overlay({
    required this.id,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
    };
  }

  factory Overlay.fromMap(Map<String, dynamic> map) {
    return Overlay(
      id: map['id'],
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}
