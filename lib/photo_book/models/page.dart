import 'package:heritage/photo_book/models/background.dart';
import 'package:heritage/photo_book/models/layout.dart';
import 'package:heritage/photo_book/models/overlay.dart';
import 'package:heritage/photo_book/models/photo.dart';
import 'package:heritage/photo_book/models/sticker.dart';
import 'package:heritage/photo_book/models/text_item.dart';

class Page {
  final String id;
  final List<Photo> photos;
  final List<TextItem> texts;
  final List<Sticker> stickers;
  String background;
  Overlay? overlay;
  Layout? layout;
  final bool isEditable; // Add isEditable property

  Page({
    required this.id,
    required this.photos,
    required this.texts,
    required this.stickers,
    required this.background,
    this.overlay,
    this.layout,
    this.isEditable = true, // Default to true if not specified
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'photos': photos.map((photo) => photo.toMap()).toList(),
      'texts': texts.map((text) => text.toMap()).toList(),
      'stickers': stickers.map((sticker) => sticker.toMap()).toList(),
      'background': background,
      'overlay': overlay?.toMap(),
      'layout': layout?.toMap(),
      'isEditable': isEditable, // Include isEditable in the map
    };
  }

  factory Page.fromMap(Map<String, dynamic> map) {
    return Page(
      id: map['id'],
      photos: List<Photo>.from(map['photos']?.map((photo) => Photo.fromMap(photo)) ?? []),
      texts: List<TextItem>.from(map['texts']?.map((text) => TextItem.fromMap(text)) ?? []),
      stickers: List<Sticker>.from(map['stickers']?.map((sticker) => Sticker.fromMap(sticker)) ?? []),
      background: map['background'],
      overlay: Overlay.fromMap(map['overlay']),
      layout: Layout.fromMap(map['layout']),
      isEditable: map['isEditable'] ?? true, // Default to true if not provided
    );
  }

  @override
  String toString() {
    return 'Page(id: $id, photos: ${photos.length}), layout: ${layout?.miniatureImage}, isEditable: $isEditable';
  }
}
