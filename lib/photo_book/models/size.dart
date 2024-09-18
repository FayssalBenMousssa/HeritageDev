class Size {
  final String id;
  final String name;
  final String dimensions;

  Size({
    required this.id,
    required this.name,
    required this.dimensions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dimensions': dimensions,



    };
  }

  static Size fromMap(Map<String, dynamic> map) {
    return Size(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      dimensions: map['dimensions'] ?? '',
    );
  }

  @override
  String toString() {
    return name; // Customized display for Size objects
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Size &&

        other.name == name &&
        other.dimensions == dimensions;
  }

  @override
  int get hashCode =>  name.hashCode ^ dimensions.hashCode;
}