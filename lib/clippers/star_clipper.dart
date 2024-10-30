import 'dart:math';
import 'package:flutter/material.dart';

class StarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double radius = min(centerX, centerY);
    Path path = Path();
    int numberOfPoints = 5;
    double angle = (2 * pi) / numberOfPoints;
    double halfAngle = angle / 2;

    for (int i = 0; i < numberOfPoints; i++) {
      double outerX = centerX + radius * cos(i * angle - pi / 2);
      double outerY = centerY + radius * sin(i * angle - pi / 2);
      double innerX = centerX + (radius / 2.5) * cos((i * angle) + halfAngle - pi / 2);
      double innerY = centerY + (radius / 2.5) * sin((i * angle) + halfAngle - pi / 2);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
