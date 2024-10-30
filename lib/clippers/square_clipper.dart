import 'package:flutter/material.dart';

class SquareClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.width));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
