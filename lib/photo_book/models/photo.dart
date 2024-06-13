class Photo {
  final int id;
  final int zIndex;
  final int xPosition;
  final int yPosition;
  final int height;
  final int width;
  final double rotation;
  final String url;

  Photo({
    required this.id,
    required this.zIndex,
    required this.xPosition,
    required this.yPosition,
    required this.height,
    required this.width,
    required this.rotation,
    required this.url,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'zIndex': zIndex,
      'xPosition': xPosition,
      'yPosition': yPosition,
      'height': height,
      'width': width,
      'rotation': rotation,
      'url': url,
    };
  }

  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'],
      zIndex: map['zIndex'],
      xPosition: map['xPosition'],
      yPosition: map['yPosition'],
      height: map['height'],
      width: map['width'],
      rotation: map['rotation'],
      url: map['url'] ?? '',
    );
  }
}
