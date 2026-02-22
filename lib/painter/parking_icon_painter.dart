import 'package:flutter/material.dart';

class ParkingIconPainter extends CustomPainter {
  final Color iconColor;
  ParkingIconPainter({required this.iconColor});

  @override
  void paint(Canvas canvas, Size size) { // ui.Size 명시
    final paint = Paint()
      ..color = iconColor
      ..style = PaintingStyle.fill;

    // 배경 박스
    canvas.drawRRect(RRect.fromLTRBR(0, 0, size.width, size.height, const Radius.circular(6)), paint);

    // 'P' 심볼
    final path = Path()
      ..moveTo(size.width * 0.35, size.height * 0.75)
      ..lineTo(size.width * 0.35, size.height * 0.25)
      ..lineTo(size.width * 0.55, size.height * 0.25)
      ..arcToPoint(Offset(size.width * 0.55, size.height * 0.5), radius: const Radius.circular(4), clockwise: true)
      ..lineTo(size.width * 0.35, size.height * 0.5);

    canvas.drawPath(path, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}