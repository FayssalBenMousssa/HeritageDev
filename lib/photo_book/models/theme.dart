import 'package:heritage/photo_book/models/background.dart';
import 'package:heritage/photo_book/models/layout.dart';
import 'package:heritage/photo_book/models/overlay.dart';
import 'package:heritage/photo_book/models/sticker.dart';

class Theme {
  final int id;
  final String themeName;
  final Background background;
  final Overlay overlay;
  final List<Layout> layouts;
  final List<Sticker> stickerIds;
  final String description;

  Theme({
    required this.id,
    required this.themeName,
    required this.background,
    required this.overlay,
    required this.layouts,
    required this.stickerIds,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'themeName': themeName,
      'background': background,
      'layouts': layouts,
      'overlay': overlay,
      'stickerIds': stickerIds,
      'description': description,
    };
  }

  factory Theme.fromMap(Map<String, dynamic> map) {
    return Theme(
      id: map['id'],
      themeName: map['themeName'] ?? '',
      background: map['background'],
      overlay: map['overlay'],
      layouts: List<Layout>.from(map['layouts'] ?? []),
      stickerIds: List<Sticker>.from(map['sticker'] ?? []),
      description: map['description'] ?? '',
    );
  }
}
