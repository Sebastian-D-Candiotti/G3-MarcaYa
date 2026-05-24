import 'package:flutter/material.dart';

class HeaderClipper extends CustomClipper<Path> {
  const HeaderClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width - 40, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - 40, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
