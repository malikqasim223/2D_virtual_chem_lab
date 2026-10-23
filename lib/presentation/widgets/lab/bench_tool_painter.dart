part of chem_lab;

class BenchToolPainter extends CustomPainter {
  final LabEffect type;
  final double time;
  final double wetness;
  final double colorProgress;
  final Color? developedColor;

  BenchToolPainter({
    required this.type,
    required this.time,
    this.wetness = 0.0,
    this.colorProgress = 0.0,
    this.developedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    switch (type) {
      case LabEffect.heat: _bunsen(canvas, w, h); break;
      case LabEffect.cool: _iceBath(canvas, w, h); break;
      case LabEffect.stir: _stirrer(canvas, w, h); break;
      case LabEffect.thermometer: _thermometer(canvas, w, h); break;
      case LabEffect.dropper: _dropper(canvas, w, h); break;
      
      case LabEffect.phPaper: _phPaper(canvas, w, h); break;
    }
  }

  void _bunsen(Canvas canvas, double w, double h) {
    canvas.drawOval(Rect.fromLTWH(w * 0.15, h * 0.85, w * 0.7, h * 0.12),
        Paint()..color = const Color(0xFF2D3748));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.42, h * 0.42, w * 0.16, h * 0.45),
        const Radius.circular(3)),
      Paint()..color = const Color(0xFF4B5563));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.37, h * 0.58, w * 0.26, h * 0.08),
        const Radius.circular(2)),
      Paint()..color = const Color(0xFF6B7280));
    final flame = Path()
      ..moveTo(w * 0.5, h * 0.08)
      ..quadraticBezierTo(w * 0.38, h * 0.3, w * 0.44, h * 0.42)
      ..lineTo(w * 0.56, h * 0.42)
      ..quadraticBezierTo(w * 0.62, h * 0.3, w * 0.5, h * 0.08)
      ..close();
    canvas.drawPath(flame, Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFFFFEB3B), Color(0xFFFF6B35)],
      ).createShader(Rect.fromLTWH(w * 0.35, h * 0.08, w * 0.3, h * 0.35)));
    canvas.drawOval(
      Rect.fromLTWH(w * 0.46, h * 0.22, w * 0.08, h * 0.14),
      Paint()..color = const Color(0xFF64B5F6).withValues(alpha: 0.7));
  }

  void _iceBath(Canvas canvas, double w, double h) {
    final bowl = Path()
      ..moveTo(w * 0.15, h * 0.4)
      ..quadraticBezierTo(w * 0.15, h * 0.85, w * 0.5, h * 0.85)
      ..quadraticBezierTo(w * 0.85, h * 0.85, w * 0.85, h * 0.4)
      ..close();
    canvas.drawPath(bowl, Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF6B92B8), Color(0xFF4A6B8A)],
      ).createShader(Rect.fromLTWH(w * 0.15, h * 0.4, w * 0.7, h * 0.45)));
    canvas.drawOval(
      Rect.fromLTWH(w * 0.18, h * 0.37, w * 0.64, h * 0.1),
      Paint()..color = const Color(0xFF90CAF9).withValues(alpha: 0.5));
    for (final p in [[0.25, 0.45, 0.3], [0.55, 0.48, -0.2], [0.4, 0.6, 0.5]]) {
      canvas.save();
      canvas.translate(w * p[0], h * p[1]);
      canvas.rotate(p[2]);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 12, 10),
            const Radius.circular(2)),
        Paint()..color = Colors.white.withValues(alpha: 0.85));
      canvas.restore();
    }
  }

  void _stirrer(Canvas canvas, double w, double h) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.46, h * 0.12, w * 0.08, h * 0.7),
        const Radius.circular(2)),
      Paint()..color = const Color(0xFFB0BEC5));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.32, h * 0.06, w * 0.36, h * 0.09),
        const Radius.circular(4)),
      Paint()..color = const Color(0xFF546E7A));
    canvas.drawOval(Rect.fromLTWH(w * 0.36, h * 0.82, w * 0.28, h * 0.08),
        Paint()..color = const Color(0xFF90A4AE));
  }

  void _thermometer(Canvas canvas, double w, double h) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.42, h * 0.08, w * 0.16, h * 0.74),
        const Radius.circular(8)),
      Paint()..color = const Color(0xFFE0E0E0));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.46, h * 0.34, w * 0.08, h * 0.48),
        const Radius.circular(4)),
      Paint()..color = const Color(0xFFE53935));
    canvas.drawCircle(Offset(w * 0.5, h * 0.85), w * 0.13,
        Paint()..color = const Color(0xFFE53935));
    for (int i = 0; i < 5; i++) {
      final y = h * (0.15 + i * 0.13);
      canvas.drawLine(Offset(w * 0.6, y), Offset(w * 0.68, y),
          Paint()..color = const Color(0xFF757575)..strokeWidth = 0.8);
    }
  }

  void _dropper(Canvas canvas, double w, double h) {
    canvas.drawOval(Rect.fromLTWH(w * 0.36, h * 0.05, w * 0.28, h * 0.28),
        Paint()..color = const Color(0xFF8B7BA8));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.44, h * 0.3, w * 0.12, h * 0.55),
        const Radius.circular(3)),
      Paint()..color = const Color(0xFFCFD8DC));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.47, h * 0.5, w * 0.06, h * 0.32),
        const Radius.circular(2)),
      Paint()..color = const Color(0xFF8B7BA8).withValues(alpha: 0.8));
    final tip = Path()
      ..moveTo(w * 0.44, h * 0.85)
      ..lineTo(w * 0.5, h * 0.96)
      ..lineTo(w * 0.56, h * 0.85)
      ..close();
    canvas.drawPath(tip, Paint()..color = const Color(0xFF90A4AE));
  }

  // === REALISTIC LITMUS PAPER ===
  void _litmus(Canvas canvas, double w, double h) {
    // Paper strip area — narrow, long
    final stripW = w * 0.28;
    final stripH = h * 0.92;
    final strip = Rect.fromLTWH((w - stripW) / 2, h * 0.05, stripW, stripH);

    // Drop shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(strip.shift(const Offset(1.5, 2.5)),
          const Radius.circular(2.5)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Dry base color (purple/beige tint)
    const dryColor = Color(0xFF8E6BB0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(strip, const Radius.circular(2.5)),
      Paint()..color = dryColor,
    );

    // Paper texture — horizontal fibers
    final rng = Random(42);
    for (int i = 0; i < 40; i++) {
      final y = strip.top + rng.nextDouble() * strip.height;
      final x1 = strip.left + 1;
      final x2 = strip.right - 1;
      canvas.drawLine(
        Offset(x1, y),
        Offset(x2, y),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.04)
          ..strokeWidth = 0.4,
      );
    }

    // Developed color — from BOTTOM tip upward
    if (colorProgress > 0.0 && developedColor != null) {
      final developH = strip.height * colorProgress;
      final devRect = Rect.fromLTWH(
          strip.left, strip.bottom - developH, strip.width, developH);

      canvas.save();
      canvas.clipRRect(
          RRect.fromRectAndRadius(strip, const Radius.circular(2.5)));

      // Solid developed color
      canvas.drawRect(
        devRect,
        Paint()..color = developedColor!,
      );

      // Slight gradient for realism
      canvas.drawRect(
        devRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.0),
              Colors.black.withValues(alpha: 0.15),
            ],
          ).createShader(devRect),
      );

      // Wet shine on submerged part
      if (wetness > 0.2) {
        canvas.drawRect(
          devRect,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.55 * wetness),
                Colors.white.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.35, 1.0],
            ).createShader(devRect),
        );
      }

      // Wet boundary — meniscus
      if (colorProgress > 0.01 && colorProgress < 0.99) {
        canvas.drawLine(
          Offset(strip.left, strip.bottom - developH),
          Offset(strip.right, strip.bottom - developH),
          Paint()
            ..color = developedColor!.withValues(alpha: 0.85)
            ..strokeWidth = 1.6,
        );
        canvas.drawLine(
          Offset(strip.left, strip.bottom - developH - 1),
          Offset(strip.right, strip.bottom - developH - 1),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.4)
            ..strokeWidth = 0.8,
        );
      }

      canvas.restore();
    }

    // White label at TOP with "LITMUS" text
    final labelRect = Rect.fromLTWH(
        strip.left + 2, strip.top + 3, strip.width - 4, strip.height * 0.16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(1.5)),
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );

    // Red/purple text bars
    canvas.drawRect(
      Rect.fromLTWH(labelRect.left + 3, labelRect.top + 4,
          labelRect.width - 6, 1.8),
      Paint()..color = const Color(0xFF5E35B1),
    );
    canvas.drawRect(
      Rect.fromLTWH(labelRect.left + 5, labelRect.top + 8,
          labelRect.width - 10, 1.2),
      Paint()..color = const Color(0xFF5E35B1).withValues(alpha: 0.6),
    );


    // Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(strip, const Radius.circular(2.5)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = Colors.black.withValues(alpha: 0.35),
    );
  }

  // === REALISTIC pH PAPER ===
  void _phPaper(Canvas canvas, double w, double h) {
    final stripW = w * 0.28;
    final stripH = h * 0.92;
    final strip = Rect.fromLTWH((w - stripW) / 2, h * 0.05, stripW, stripH);

    // Drop shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(strip.shift(const Offset(1.5, 2.5)),
          const Radius.circular(2.5)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // WHITE base paper (real pH paper is white/cream)
    canvas.drawRRect(
      RRect.fromRectAndRadius(strip, const Radius.circular(2.5)),
      Paint()..color = const Color(0xFFFAFAF5),
    );

    // Slight cream tint at edges
    canvas.drawRRect(
      RRect.fromRectAndRadius(strip, const Radius.circular(2.5)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF5F0E0).withValues(alpha: 0.5),
            Colors.transparent,
            const Color(0xFFF5F0E0).withValues(alpha: 0.5),
          ],
        ).createShader(strip),
    );

    // Paper texture — subtle fibers
    final rng = Random(42);
    for (int i = 0; i < 25; i++) {
      final y = strip.top + rng.nextDouble() * strip.height;
      canvas.drawLine(
        Offset(strip.left + 1, y),
        Offset(strip.right - 1, y),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.03)
          ..strokeWidth = 0.4,
      );
    }

    // Developed color — from BOTTOM tip upward (after dip)
    if (colorProgress > 0.0 && developedColor != null) {
      final developH = strip.height * colorProgress;
      final devRect = Rect.fromLTWH(
          strip.left, strip.bottom - developH, strip.width, developH);

      canvas.save();
      canvas.clipRRect(
          RRect.fromRectAndRadius(strip, const Radius.circular(2.5)));

      // Solid developed color
      canvas.drawRect(devRect, Paint()..color = developedColor!);

      // Darken slightly at bottom edge
      canvas.drawRect(
        devRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.0),
              Colors.black.withValues(alpha: 0.12),
            ],
          ).createShader(devRect),
      );

      // Wet shine on submerged part
      if (wetness > 0.2) {
        canvas.drawRect(
          devRect,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.5 * wetness),
                Colors.white.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.35, 1.0],
            ).createShader(devRect),
        );
      }

      // Wet boundary — meniscus
      if (colorProgress > 0.01 && colorProgress < 0.99) {
        canvas.drawLine(
          Offset(strip.left, strip.bottom - developH),
          Offset(strip.right, strip.bottom - developH),
          Paint()
            ..color = developedColor!.withValues(alpha: 0.6)
            ..strokeWidth = 1.5,
        );
      }

      canvas.restore();
    }

    // Small white reference square at top (marker)
    canvas.drawRect(
      Rect.fromLTWH(strip.left + 2, strip.top + 3, strip.width - 4, 4),
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawRect(
      Rect.fromLTWH(strip.left + 2, strip.top + 3, strip.width - 4, 4),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = Colors.black.withValues(alpha: 0.15),
    );


    // Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(strip, const Radius.circular(2.5)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = Color(0xFF94A3B8).withValues(alpha: 0.2),
    );
  }

  @override
  bool shouldRepaint(covariant BenchToolPainter old) =>
      old.time != time ||
      old.wetness != wetness ||
      old.colorProgress != colorProgress ||
      old.developedColor != developedColor;
}




