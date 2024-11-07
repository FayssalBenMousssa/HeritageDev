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
  final double left;
  final double top;
  final double width;
  final double height;
  final CustomClipper<Path> clipper;
  String imageUrl; // URL or path for the image

  // New properties for zoom and pan transformations
  double scale;
  Offset offset;

  Zone({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.clipper,
    required this.imageUrl, // Add image to zone
    this.scale = 1.0, // Default zoom level
    this.offset = Offset.zero, // Default offset (no pan)
  });

  // Convert Zone object to a Map
  Map<String, dynamic> toMap() {
    return {
      'left': left,
      'top': top,
      'width': width,
      'height': height,
      'clipper': clipper.runtimeType.toString(),
      'imageUrl': imageUrl, // Add image URL to the Map
      'scale': scale, // Add scale to the Map
      'offsetX': offset.dx, // Store offset X component
      'offsetY': offset.dy, // Store offset Y component
    };
  }

  // Create a Zone object from a Map
  static Zone fromMap(Map<String, dynamic> map) {
    return Zone(
      left: map['left']?.toDouble() ?? 0.0,
      top: map['top']?.toDouble() ?? 0.0,
      width: map['width']?.toDouble() ?? 100.0,
      height: map['height']?.toDouble() ?? 100.0,
      clipper: _getClipperFromString(map['clipper'] as String),
      imageUrl: map['imageUrl'] ?? '', // Add image URL initialization
      scale: map['scale']?.toDouble() ?? 1.0, // Initialize scale
      offset: Offset(
        map['offsetX']?.toDouble() ?? 0.0,
        map['offsetY']?.toDouble() ?? 0.0,
      ), // Initialize offset
    );
  }

  // Helper function to map string back to CustomClipper
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
        return CircleClipper(); // Default clipper
    }
  }
}
