import 'package:flutter/material.dart';
import 'dart:math';

class LabLiveBackground extends StatefulWidget {
  const LabLiveBackground({Key? key}) : super(key: key);
  @override
  State<LabLiveBackground> createState() => _LabLiveBackgroundState();
}

class _LabLiveBackgroundState extends State<LabLiveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_LabFloatingDot> _backDots = [];
  final List<_LabFloatingDot> _midDots = [];
  final List<_LabFloatingDot> _frontDots = [];
  final Random _rng = Random(42);

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 60; i++) {
      _backDots.add(_LabFloatingDot(
        startX: _rng.nextDouble(),
        startY: _rng.nextDouble(),
        offset: _rng.nextDouble() * 10,
        radius: 0.5 + _rng.nextDouble() * 0.8,
        opacity: 0.2,
        speedMultiplier: 0.4,
        color: i % 2 == 0 ? Colors.white : const Color(0xFF3B82F6),
      ));
    }
    for (int i = 0; i < 40; i++) {
      _midDots.add(_LabFloatingDot(
        startX: _rng.nextDouble(),
        startY: _rng.nextDouble(),
        offset: _rng.nextDouble() * 10,
        radius: 1.0 + _rng.nextDouble() * 1.2,
        opacity: 0.5,
        speedMultiplier: 0.8,
        color: i % 2 == 0 ? const Color(0xFF8B5CF6) : Colors.white,
      ));
    }
    for (int i = 0; i < 20; i++) {
      _frontDots.add(_LabFloatingDot(
        startX: _rng.nextDouble(),
        startY: _rng.nextDouble(),
        offset: _rng.nextDouble() * 10,
        radius: 1.8 + _rng.nextDouble() * 1.5,
        opacity: 0.9,
        speedMultiplier: 1.2,
        color: i % 3 == 0 ? const Color(0xFF00E5FF) : Colors.white,
      ));
    }
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _LabParticlePainter(
              backDots: _backDots,
              midDots: _midDots,
              frontDots: _frontDots,
              progress: _controller.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _LabParticlePainter extends CustomPainter {
  final List<_LabFloatingDot> backDots;
  final List<_LabFloatingDot> midDots;
  final List<_LabFloatingDot> frontDots;
  final double progress;

  _LabParticlePainter({
    required this.backDots,
    required this.midDots,
    required this.frontDots,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    _drawLayer(canvas, size, backDots, paint, 0.02);
    _drawLayer(canvas, size, midDots, paint, 0.035);
    _drawLayer(canvas, size, frontDots, paint, 0.05);
  }

  void _drawLayer(Canvas canvas, Size size, List<_LabFloatingDot> dots, Paint paint, double baseAmplitude) {
    for (var p in dots) {
      final floatX = sin(progress * 2 * pi * p.speedMultiplier + p.offset) * (baseAmplitude * p.speedMultiplier);
      final floatY = cos(progress * 2 * pi * p.speedMultiplier + p.offset * 1.3) * (baseAmplitude * p.speedMultiplier);
      final x = (p.startX + floatX) * size.width;
      final y = (p.startY + floatY) * size.height;
      paint.color = p.color.withValues(alpha: p.opacity);
      canvas.drawCircle(Offset(x, y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LabParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _LabFloatingDot {
  final double startX;
  final double startY;
  final double offset;
  final double radius;
  final double opacity;
  final double speedMultiplier;
  final Color color;

  _LabFloatingDot({
    required this.startX,
    required this.startY,
    required this.offset,
    required this.radius,
    required this.opacity,
    required this.speedMultiplier,
    required this.color,
  });
}