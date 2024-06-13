class Layout {
  final int id;
  final List<int> grid;

  Layout({
    required this.id,
    required this.grid,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'grid': grid,
    };
  }

  factory Layout.fromMap(Map<String, dynamic> map) {
    return Layout(
      id: map['id'],
      grid: List<int>.from(map['grid'] ?? []),
    );
  }
}
