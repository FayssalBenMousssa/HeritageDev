class TextItem {
  final int id;
  final String content;
  final String fontStyle;
  final String color;
  final String alignment;
  final int positionX;
  final int positionY;

  TextItem({
    required this.id,
    required this.content,
    required this.fontStyle,
    required this.color,
    required this.alignment,
    required this.positionX,
    required this.positionY,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'fontStyle': fontStyle,
      'color': color,
      'alignment': alignment,
      'positionX': positionX,
      'positionY': positionY,
    };
  }

  factory TextItem.fromMap(Map<String, dynamic> map) {
    return TextItem(
      id: map['id'],
      content: map['content'] ?? '',
      fontStyle: map['fontStyle'] ?? '',
      color: map['color'] ?? '',
      alignment: map['alignment'] ?? '',
      positionX: map['positionX'],
      positionY: map['positionY'],
    );
  }
}
