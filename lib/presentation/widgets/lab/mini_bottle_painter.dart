part of chem_lab;

class MiniBottlePainter extends CustomPainter {
  final Color color;
  final String state;
  MiniBottlePainter({required this.color, this.state = 'Liquid'});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final isLiquid = state == 'Liquid' || state == 'Indicator';
    final isSolid = state == 'Solid';

    // Cap (brown for liquids, silver for solids)
    final capCol = isLiquid
        ? const Color(0xFF8B6A3F)
        : const Color(0xFF9E9E9E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.30, 0, w * 0.40, h * 0.12),
        const Radius.circular(2)),
      Paint()..color = capCol);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.30, h * 0.02, w * 0.40, h * 0.02),
      Paint()..color = Colors.white.withValues(alpha: 0.25));

    // Neck (narrow)
    canvas.drawRect(
      Rect.fromLTWH(w * 0.38, h * 0.12, w * 0.24, h * 0.08),
      Paint()..color = const Color(0xFFE0E4E8).withValues(alpha: 0.25));

    // Bottle body (rounded shoulders)
    final body = RRect.fromRectAndCorners(
      Rect.fromLTWH(w * 0.14, h * 0.20, w * 0.72, h * 0.76),
      topLeft: const Radius.circular(8),
      topRight: const Radius.circular(8),
      bottomLeft: const Radius.circular(3),
      bottomRight: const Radius.circular(3));
    canvas.drawRRect(body,
      Paint()..color = const Color(0xFFF5F7FA).withValues(alpha: 0.10));

    canvas.save();
    canvas.clipRRect(body);

    if (isLiquid) {
      // Liquid fill (60% from bottom)
      final fillTop = h * 0.20 + h * 0.76 * 0.40;
      final rect = Rect.fromLTWH(w * 0.14, fillTop, w * 0.72, h * 0.76 * 0.60);
      canvas.drawRect(rect, Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.50),
            color.withValues(alpha: 0.75),
            color.withValues(alpha: 0.95),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect));
      // Meniscus curve
      final meniscus = Path()
        ..moveTo(w * 0.14, fillTop)
        ..quadraticBezierTo(w * 0.50, fillTop + 3, w * 0.86, fillTop);
      canvas.drawPath(meniscus, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.7));
      // Small bubbles in liquid
      final rng = Random(color.toARGB32());
      for (int i = 0; i < 4; i++) {
        final bx = w * 0.22 + rng.nextDouble() * w * 0.56;
        final by = fillTop + 4 + rng.nextDouble() * (h * 0.94 - fillTop - 4);
        canvas.drawCircle(Offset(bx, by), 0.6 + rng.nextDouble() * 0.8,
          Paint()..color = Colors.white.withValues(alpha: 0.35));
      }
    } else if (isSolid) {
      // Crystal pile (polygonal shapes)
      final pileTop = h * 0.68;
      final rng = Random(color.toARGB32());
      // Base mound
      final mound = Path()
        ..moveTo(w * 0.14, h * 0.96)
        ..quadraticBezierTo(w * 0.30, pileTop - 4, w * 0.50, pileTop)
        ..quadraticBezierTo(w * 0.70, pileTop - 4, w * 0.86, h * 0.96)
        ..lineTo(w * 0.14, h * 0.96)
        ..close();
      canvas.drawPath(mound, Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.70),
            color.withValues(alpha: 1.0),
          ]).createShader(Rect.fromLTWH(0, pileTop - 4, w, h - pileTop + 4)));
      // Individual crystal shapes (diamonds/squares)
      for (int i = 0; i < 10; i++) {
        final cx = w * 0.20 + rng.nextDouble() * w * 0.60;
        final distFromCenter = ((cx - w * 0.5).abs() / (w * 0.36)).clamp(0.0, 1.0);
        final topY = pileTop + distFromCenter * 6;
        final cy = topY + rng.nextDouble() * (h * 0.94 - topY);
        final cs = 1.2 + rng.nextDouble() * 1.8;
        // Diamond shape
        final crystal = Path()
          ..moveTo(cx, cy - cs)
          ..lineTo(cx + cs * 0.7, cy)
          ..lineTo(cx, cy + cs)
          ..lineTo(cx - cs * 0.7, cy)
          ..close();
        canvas.drawPath(crystal, Paint()
          ..color = color.withValues(alpha: 0.85 + rng.nextDouble() * 0.15));
        canvas.drawPath(crystal, Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.3
          ..color = Colors.white.withValues(alpha: 0.5));
      }
      // Sparkle highlights
      for (int i = 0; i < 4; i++) {
        final sx = w * 0.22 + rng.nextDouble() * w * 0.56;
        final sy = pileTop + rng.nextDouble() * (h * 0.94 - pileTop);
        canvas.drawCircle(Offset(sx, sy), 0.6,
          Paint()..color = Colors.white.withValues(alpha: 0.9));
      }
    }
    canvas.restore();

    // Bottle glass outline
    canvas.drawRRect(body, Paint()
      ..color = const Color(0xFF6B7280).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9);

    // Glass shine (left)
    canvas.drawRect(
      Rect.fromLTWH(w * 0.20, h * 0.26, w * 0.04, h * 0.60),
      Paint()..color = Colors.white.withValues(alpha: 0.35));
    canvas.drawRect(
      Rect.fromLTWH(w * 0.19, h * 0.26, w * 0.015, h * 0.60),
      Paint()..color = Colors.white.withValues(alpha: 0.55));

    // Label band (small, for solid bottles)
    if (isSolid) {
      canvas.drawRect(
        Rect.fromLTWH(w * 0.20, h * 0.44, w * 0.60, h * 0.10),
        Paint()..color = Colors.white.withValues(alpha: 0.55));
      canvas.drawRect(
        Rect.fromLTWH(w * 0.22, h * 0.46, w * 0.56, h * 0.02),
        Paint()..color = color.withValues(alpha: 0.7));
    }
  }

  @override
  bool shouldRepaint(covariant MiniBottlePainter old) =>
      old.color != color || old.state != state;
}

