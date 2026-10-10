part of chem_lab;

class HeatingSetupPainter extends CustomPainter {
  final double time;
  HeatingSetupPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final ringY = h * 0.08;
    final ringW = w * 0.9;
    final ringH = h * 0.08;
    final benchY = h * 0.98;

    final legPaint = Paint()
      ..color = const Color(0xFF37474F)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final legSpread = ringW * 0.42;
    canvas.drawLine(Offset(cx - legSpread, ringY + ringH * 0.4), Offset(cx - legSpread - w * 0.04, benchY), legPaint);
    canvas.drawLine(Offset(cx + legSpread, ringY + ringH * 0.4), Offset(cx + legSpread + w * 0.04, benchY), legPaint);
    canvas.drawLine(Offset(cx, ringY + ringH * 0.4), Offset(cx, benchY), legPaint);

    canvas.drawCircle(Offset(cx - legSpread - w * 0.04, benchY), 6, Paint()..color = const Color(0xFF263238));
    canvas.drawCircle(Offset(cx + legSpread + w * 0.04, benchY), 6, Paint()..color = const Color(0xFF263238));
    canvas.drawCircle(Offset(cx, benchY), 6, Paint()..color = const Color(0xFF263238));

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, ringY + ringH / 2), width: ringW, height: ringH),
      Paint()
        ..color = const Color(0xFF37474F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9,
    );

    final gY1 = ringY + ringH * 0.25;
    final gY2 = ringY + ringH * 0.75;
    final gauzePaint = Paint()
      ..color = const Color(0xFFB0BEC5)
      ..strokeWidth = 1.0;
    for (int i = 0; i < 3; i++) {
      final y = gY1 + (gY2 - gY1) * i / 2;
      canvas.drawLine(Offset(cx - ringW * 0.42, y), Offset(cx + ringW * 0.42, y), gauzePaint);
    }
    for (int i = 0; i < 10; i++) {
      final x = cx - ringW * 0.42 + (ringW * 0.84) * i / 9;
      canvas.drawLine(Offset(x, gY1), Offset(x, gY2), gauzePaint);
    }

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.93), width: w * 0.42, height: h * 0.07),
      Paint()..color = const Color(0xFF2C3E50),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, h * 0.88), width: w * 0.36, height: h * 0.10),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF455A64),
    );

    final tubeTop = h * 0.48;
    final tubeBot = h * 0.84;
    canvas.drawRect(
      Rect.fromLTRB(cx - w * 0.055, tubeTop, cx + w * 0.055, tubeBot),
      Paint()..color = const Color(0xFFB0BEC5),
    );
    canvas.drawRect(
      Rect.fromLTRB(cx - w * 0.045, tubeTop, cx - w * 0.02, tubeBot),
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(cx - w * 0.09, h * 0.58, cx + w * 0.09, h * 0.66),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF263238),
    );

    canvas.drawCircle(Offset(cx + w * 0.16, h * 0.63), w * 0.04, Paint()..color = const Color(0xFF546E7A));
    canvas.drawCircle(Offset(cx + w * 0.16, h * 0.63), w * 0.018, Paint()..color = const Color(0xFF263238));

    final hose = Path()
      ..moveTo(cx + w * 0.16, h * 0.63)
      ..cubicTo(cx + w * 0.40, h * 0.68, cx + w * 0.46, h * 0.94, cx + w * 0.18, h * 0.96);
    canvas.drawPath(hose, Paint()
      ..color = const Color(0xFFB71C1C)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(cx - w * 0.065, h * 0.44, cx + w * 0.065, h * 0.50),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF78909C),
    );

    final fy = h * 0.45;
    final fh = h * 0.30;
    final f1 = sin(time * 6) * 1.0;
    final f2 = sin(time * 9 + 1.3) * 0.8;

    final outer = Path()
      ..moveTo(cx - w * 0.075, fy)
      ..quadraticBezierTo(cx - w * 0.10 + f1, fy - fh * 0.5, cx + f2, fy - fh)
      ..quadraticBezierTo(cx + w * 0.10 + f1, fy - fh * 0.5, cx + w * 0.075, fy)
      ..close();
    canvas.drawPath(outer, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0xFFFFF8E1),
          Color(0xFFFFD54F),
          Color(0xFFFF9800),
          Color(0xFFE64A19),
        ],
        stops: const [0.0, 0.35, 0.7, 1.0],
      ).createShader(Rect.fromLTRB(cx - w*0.12, fy - fh, cx + w*0.12, fy)));

    final core = Path()
      ..moveTo(cx - w * 0.032, fy - fh * 0.02)
      ..quadraticBezierTo(cx - w * 0.042, fy - fh * 0.35, cx, fy - fh * 0.55)
      ..quadraticBezierTo(cx + w * 0.042, fy - fh * 0.35, cx + w * 0.032, fy - fh * 0.02)
      ..close();
    canvas.drawPath(core, Paint()..color = const Color(0xFF81D4FA));
  }

  @override
  bool shouldRepaint(covariant HeatingSetupPainter old) => old.time != time;
}


