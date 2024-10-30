import 'package:flutter/material.dart';

class RhombusClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width / 2, 0); // Top middle
    path.lineTo(size.width, size.height / 2); // Right middle
    path.lineTo(size.width / 2, size.height); // Bottom middle
    path.lineTo(0, size.height / 2); // Left middle
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
