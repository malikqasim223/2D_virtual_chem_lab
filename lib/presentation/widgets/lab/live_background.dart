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
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F172A),
                Color(0xFF1E293B),
                Color(0xFF0B101E),
              ],
            ),
          ),
          child: CustomPaint(
            painter: _MoleculePainter(_controller.value),
          ),
        );
      },
    );
  }
}

class _MoleculePainter extends CustomPainter {
  final double time;
  _MoleculePainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.blueAccent.withValues(alpha: 0.05)
      ..strokeWidth = 1.2;

    const int count = 25;
    List<Offset> positions = [];

    for (int i = 0; i < count; i++) {
      double speed = 0.5 + (i % 5) * 0.2;
      double angle = (i * 137.5 + time * 360 * speed) % 360;
      double radius = 8 + (i % 4) * 12;

      double cx = size.width * 0.5 + (size.width * 0.45) * (angle * 3.14159 / 180).abs() + (i % 7) * 40;
      double cy = size.height * 0.5 + (size.height * 0.45) * ((angle + 90) * 3.14159 / 180).abs() + (i % 5) * 50;

      cx = cx % size.width;
      cy = cy % size.height;

      positions.add(Offset(cx, cy));
      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }

    for (int i = 0; i < count; i++) {
      for (int j = i + 1; j < count; j++) {
        double distance = (positions[i] - positions[j]).distance;
        if (distance < 180) {
          canvas.drawLine(positions[i], positions[j], linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MoleculePainter oldDelegate) => true;
}