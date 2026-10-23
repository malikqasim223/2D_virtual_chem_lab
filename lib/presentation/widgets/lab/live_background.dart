import 'package:flutter/material.dart';
import 'dart:math';

class LiveBackground extends StatefulWidget {
  const LiveBackground({Key? key}) : super(key: key);
  @override
  State<LiveBackground> createState() => _LiveBackgroundState();
}

class _LiveBackgroundState extends State<LiveBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0B101E),
                Color(0xFF0F172A),
                Color(0xFF0B101E),
              ],
            ),
          ),
          child: CustomPaint(
            painter: _BubblePainter(_controller.value),
          ),
        );
      },
    );
  }
}

class _BubblePainter extends CustomPainter {
  final double time;
  _BubblePainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final random = Random(42);
    const int count = 25;

    for (int i = 0; i < count; i++) {
      double speed = 0.2 + random.nextDouble() * 0.3;
      double startX = random.nextDouble() * size.width;
      double radius = 5 + random.nextDouble() * 25;
      
      // Move upwards
      double y = size.height + 100 - ((time * speed * size.height * 2 + i * 50) % (size.height + 200));
      
      // Sway left/right
      double x = startX + sin(time * 2 * 3.14 + i) * 20;

      // Color (Cyan/Blue glow)
      Color bubbleColor = Colors.cyanAccent.withValues(alpha: 0.1 + random.nextDouble() * 0.15);

      paint.color = bubbleColor;
      borderPaint.color = bubbleColor.withValues(alpha: 0.3);

      canvas.drawCircle(Offset(x, y), radius, paint);
      canvas.drawCircle(Offset(x, y), radius, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) => true;
}