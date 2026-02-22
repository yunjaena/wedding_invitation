import 'package:flutter/material.dart';

class SubwayIconPainter extends CustomPainter {
  final Color iconColor;
  SubwayIconPainter({required this.iconColor});

  @override
  void paint(Canvas canvas, Size size) { // ui.Size 명시
    final paint = Paint()
      ..color = iconColor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(RRect.fromLTRBR(0, 0, size.width, size.height, const Radius.circular(6)), paint);

    final whitePaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2.0;

    // 전동차 본체
    canvas.drawRRect(RRect.fromLTRBR(size.width * 0.22, size.height * 0.25, size.width * 0.78, size.height * 0.65, const Radius.circular(3)), whitePaint);
    // 전조등
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.55), 1.2, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.55), 1.2, Paint()..color = Colors.white);
    // 선로
    canvas.drawLine(Offset(size.width * 0.15, size.height * 0.78), Offset(size.width * 0.85, size.height * 0.78), whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}