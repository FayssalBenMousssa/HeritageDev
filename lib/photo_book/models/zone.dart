import 'dart:math';
import 'package:flutter/material.dart';

import '../../clippers/circle_clipper.dart';
import '../../clippers/ellipse_clipper.dart';
import '../../clippers/heart_clipper.dart';
import '../../clippers/kite_clipper.dart';
import '../../clippers/octagon_clipper.dart';
import '../../clippers/rectangle_clipper.dart';
import '../../clippers/rhombus_clipper.dart';
import '../../clippers/square_clipper.dart';
import '../../clippers/star_clipper.dart';
import '../../clippers/triangle_clipper.dart';

class Zone {
  String imageUrl;
  double scale;
  Offset offset;
  double left;
  double top;
  double width;
  double height;
  CustomClipper<Path>? clipper;

  Zone({
    required this.imageUrl,
    this.scale = 1.0,
    this.offset = Offset.zero,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    this.clipper,
  });

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'scale': scale,
      'offset': {'dx': offset.dx, 'dy': offset.dy},
      'left': left,
      'top': top,
      'width': width,
      'height': height,
    };
  }

  static Zone fromMap(Map<String, dynamic> map) {
    return Zone(
      left: map['left']?.toDouble() ?? 0.0,
      top: map['top']?.toDouble() ?? 0.0,
      width: map['width']?.toDouble() ?? 100.0,
      height: map['height']?.toDouble() ?? 100.0,
      clipper: _getClipperFromString(map['clipper'] as String),
      imageUrl: map['imageUrl'] ?? '',
      scale: map['scale']?.toDouble() ?? 1.0,
      offset: Offset(
        map['offsetX']?.toDouble() ?? 0.0,
        map['offsetY']?.toDouble() ?? 0.0,
      ),
    );
  }

  static CustomClipper<Path> _getClipperFromString(String clipperName) {
    switch (clipperName) {
      case 'CircleClipper':
        return CircleClipper();
      case 'TriangleClipper':
        return TriangleClipper();
      case 'StarClipper':
        return StarClipper();
      case 'HeartClipper':
        return HeartClipper();
      case 'SquareClipper':
        return SquareClipper();
      case 'RectangleClipper':
        return RectangleClipper();
      case 'KiteClipper':
        return KiteClipper();
      case 'EllipseClipper':
        return EllipseClipper();
      case 'OctagonClipper':
        return OctagonClipper();
      case 'RhombusClipper':
        return RhombusClipper();
      default:
        return CircleClipper();
    }
  }
}

