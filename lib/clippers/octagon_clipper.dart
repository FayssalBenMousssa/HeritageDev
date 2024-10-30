import 'package:flutter/material.dart';

class OctagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double x = size.width / 4;
    double y = size.height / 4;
    Path path = Path();

    path.moveTo(x, 0);
    path.lineTo(size.width - x, 0);
    path.lineTo(size.width, y);
    path.lineTo(size.width, size.height - y);
    path.lineTo(size.width - x, size.height);
    path.lineTo(x, size.height);
    path.lineTo(0, size.height - y);
    path.lineTo(0, y);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
