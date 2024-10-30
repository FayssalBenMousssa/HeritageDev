import 'package:flutter/material.dart';

class KiteClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width / 2, 0); // Top center point
    path.lineTo(size.width, size.height / 2); // Right center
    path.lineTo(size.width / 2, size.height); // Bottom center
    path.lineTo(0, size.height / 2); // Left center
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
