
class Zone {
  final int id; // Unique identifier for the zone
  final double heightPercent;
  final double widthPercent;
  final bool isEmpty; // True if the zone is empty, false if it contains a photo
  final String? photo;

  Zone({
    required this.id,
    required this.heightPercent,
    required this.widthPercent,
    required this.isEmpty,
    this.photo,
  });

  // Convert Zone object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'heightPercent': heightPercent,
      'widthPercent': widthPercent,
      'isEmpty': isEmpty,
      'photo': photo,
    };
  }

  // Create a Zone object from a map
  static Zone fromMap(Map<String, dynamic> map) {
    return Zone(
      id: map['id'] ?? 0,
      heightPercent: map['heightPercent']?.toDouble() ?? 0.0, // Ensure it's a double
      widthPercent: map['widthPercent']?.toDouble() ?? 0.0, // Ensure it's a double
      isEmpty: map['isEmpty'] ?? true,
      photo: map['photo'], // No need for null check, since `photo` is nullable
    );
  }

  @override
  String toString() {
    return 'Zone ID: $id (Height: $heightPercent%, Width: $widthPercent%, Empty: $isEmpty, Photo: ${photo ?? 'None'})';
  }
}

