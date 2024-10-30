import 'package:flutter/material.dart';
import 'dart:math';

class HeartClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.moveTo(0, size.height * 0.67); // Approximate the bottom
    path.lineTo(0, 0); // Draw the left vertical line
    path.lineTo(size.width * 0.67, 0); // Top right point

    // First arc (right side of the heart)
    path.arcToPoint(
      Offset(size.width * 0.67, size.height * 0.67), // Bottom right
      radius: Radius.elliptical(size.width * 0.33, size.height * 0.33),
      rotation: pi / 2,
      largeArc: false,
      clockwise: true,
    );

    // Second arc (left side of the heart)
    path.arcToPoint(
      Offset(0, size.height * 0.67), // Bottom left
      radius: Radius.elliptical(size.width * 0.33, size.height * 0.33),
      rotation: pi / 2,
      largeArc: false,
      clockwise: true,
    );

    path.close();

    final rotationMatrix = Matrix4.identity()
      ..translate(size.width / 2, size.height / 2) // Move to center
      ..rotateZ(pi) // Rotate by 180 degrees (pi radians)
      ..translate(-size.width / 2, -size.height / 2); // Move back

    return path.transform(rotationMatrix.storage);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
