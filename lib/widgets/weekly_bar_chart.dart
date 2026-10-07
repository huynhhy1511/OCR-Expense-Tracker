import 'package:flutter/material.dart';

class WeeklyBarChart extends StatefulWidget {
  final Map<int, int> data; // 1 (Mon) to 7 (Sun)

  const WeeklyBarChart({super.key, required this.data});

  @override
  State<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<WeeklyBarChart> with SingleTickerProviderStateMixin {
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
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(WeeklyBarChart oldWidget) {
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
    final maxAmount = widget.data.values.fold(0, (max, val) => val > max ? val : max);
    if (maxAmount == 0) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No spending data')),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          height: 200,
          child: CustomPaint(
            painter: BarChartPainter(
              data: widget.data,
              maxAmount: maxAmount,
              progress: _animation.value,
              context: context,
            ),
          ),
        );
      },
    );
  }
}

class BarChartPainter extends CustomPainter {
  final Map<int, int> data;
  final int maxAmount;
  final double progress;
  final BuildContext context;

  BarChartPainter({
    required this.data,
    required this.maxAmount,
    required this.progress,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Theme.of(context).colorScheme.primary
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final bgPaint = Paint()
      ..color = Theme.of(context).colorScheme.surfaceContainerHighest
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final int barCount = 7;
    final double barSpacing = size.width / barCount;
    final double barWidth = barSpacing * 0.5;
    final double maxBarHeight = size.height - 30; // Leave room for labels

    final List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    for (int i = 1; i <= 7; i++) {
      final double xOffset = (i - 1) * barSpacing + (barSpacing - barWidth) / 2;
      
      // Draw background bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(xOffset, 0, barWidth, maxBarHeight),
          const Radius.circular(4),
        ),
        bgPaint,
      );

      // Draw value bar
      final int amount = data[i] ?? 0;
      final double targetHeight = maxAmount > 0 ? (amount / maxAmount) * maxBarHeight : 0;
      final double currentHeight = targetHeight * progress;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(xOffset, maxBarHeight - currentHeight, barWidth, currentHeight),
          const Radius.circular(4),
        ),
        paint,
      );

      // Draw label
      final textPainter = TextPainter(
        text: TextSpan(
          text: days[i - 1],
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(xOffset + barWidth / 2 - textPainter.width / 2, maxBarHeight + 8),
      );
    }
  }

  @override
  bool shouldRepaint(BarChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.data != data;
  }
}
