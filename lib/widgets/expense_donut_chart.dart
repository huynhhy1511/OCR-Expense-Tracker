import 'package:flutter/material.dart';
import 'dart:math';

class ExpenseDonutChart extends StatefulWidget {
  final Map<String, int> data;
  final int total;

  const ExpenseDonutChart({
    super.key,
    required this.data,
    required this.total,
  });

  @override
  State<ExpenseDonutChart> createState() => _ExpenseDonutChartState();
}

class _ExpenseDonutChartState extends State<ExpenseDonutChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }
  
  @override
  void didUpdateWidget(ExpenseDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.total == 0) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No spending data')),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          height: 250,
          child: CustomPaint(
            painter: DonutChartPainter(
              data: widget.data,
              total: widget.total,
              progress: _animation.value,
              context: context,
            ),
          ),
        );
      },
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final Map<String, int> data;
  final int total;
  final double progress;
  final BuildContext context;

  DonutChartPainter({
    required this.data,
    required this.total,
    required this.progress,
    required this.context,
  });

  final List<Color> colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 20;
    final strokeWidth = radius * 0.4;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -pi / 2;
    int colorIndex = 0;

    data.forEach((category, amount) {
      if (amount <= 0) return;
      
      final sweepAngle = (amount / total) * 2 * pi * progress;
      paint.color = colors[colorIndex % colors.length];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
      colorIndex++;
    });
    
    // Draw total in center
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Total\n',
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
        children: [
          TextSpan(
            text: '100%',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(DonutChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.data != data;
  }
}
