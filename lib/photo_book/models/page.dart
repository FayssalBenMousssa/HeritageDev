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
   Background? background;
   Overlay? overlay;
   Layout? layout;


  Page({
    required this.id,
    required this.photos,
    required this.texts,
    required this.stickers,
     this.background,
     this.overlay,
     this.layout,

  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'photos': photos.map((photo) => photo.toMap()).toList(),
      'texts': texts.map((text) => text.toMap()).toList(),
      'stickers': stickers.map((sticker) => sticker.toMap()).toList(),
      'background': background?.toMap(),
      'overlay': overlay?.toMap(),
      'layout': layout?.toMap()
    };
  }

  factory Page.fromMap(Map<String, dynamic> map) {
    return Page(
      id: map['id'],
      photos: List<Photo>.from(
          map['photos']?.map((photo) => Photo.fromMap(photo)) ?? []),
      texts: List<TextItem>.from(
          map['texts']?.map((text) => TextItem.fromMap(text)) ?? []),
      stickers: List<Sticker>.from(
          map['stickers']?.map((sticker) => Sticker.fromMap(sticker)) ?? []),
      background: Background.fromMap(map['background']),
      overlay: Overlay.fromMap(map['overlay']),
      layout: Layout.fromMap(map['layout']),

    );
  }

  @override
  String toString() {
    return 'Page(id: $id, photos: ${photos.length}), layout : ${layout?.miniatureImage}'; // Customize as needed
  }
}
