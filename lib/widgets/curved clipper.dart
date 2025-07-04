import 'package:flutter/material.dart';
import 'dart:ui';

class CurvedBorderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    double curveHeight = 30.0; // Depth of the curve

    path.lineTo(size.width / 2 - 40, 0); // Start of curve
    path.quadraticBezierTo(size.width / 2, curveHeight, size.width / 2 + 40, 0); // Curve
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
