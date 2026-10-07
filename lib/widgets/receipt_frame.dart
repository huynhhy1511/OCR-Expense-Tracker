import 'package:flutter/material.dart';

class ReceiptFrame extends StatelessWidget {
  const ReceiptFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ReceiptFramePainter(),
    );
  }
}

class ReceiptFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final frameRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.85,
        height: size.height * 0.7,
      ),
      const Radius.circular(16),
    );

    final bgPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final framePath = Path()..addRRect(frameRect);
    
    final finalPath = Path.combine(PathOperation.difference, bgPath, framePath);
    
    canvas.drawPath(finalPath, paint);

    // Draw borders
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(frameRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
