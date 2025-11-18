import 'package:flutter/material.dart';

class CurvedTopContainer extends StatelessWidget {
  final Widget child;

  const CurvedTopContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: TopConcaveClipper(),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF9C65C), // your yellow-ish background
        ),
        child: child,
      ),
    );
  }
}

class TopConcaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();

    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.995);

    // Left concave transition
    path.quadraticBezierTo(
      10,
      size.height - 40, // Concave dip upward
      50,
      size.height - 40,
    );
    path.lineTo(size.width - 50, size.height - 40);

    // Right side of concave curve
    path.quadraticBezierTo(
      size.width - 10,
      size.height - 40, // Concave dip upward
      size.width,
      size.height,
    );

    // Right to bottom
    path.lineTo(size.width, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
