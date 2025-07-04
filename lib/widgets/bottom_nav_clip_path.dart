import 'package:flutter/material.dart';
import 'dart:ui';

class BottomNavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;

    Path path = Path();
    path.lineTo(0, 0);
    path.lineTo((w / 2) - 35, 0); // Left side
    path.quadraticBezierTo(w / 2, -40, (w / 2) + 35, 0); // Circular cutout
    path.lineTo(w, 0);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
