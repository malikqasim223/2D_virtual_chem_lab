part of chem_lab;

class IcePainter extends CustomPainter {
  final double time;
  IcePainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    canvas.drawCircle(Offset(cx, cy), w * 0.35,
      Paint()..shader = RadialGradient(colors: [
        const Color(0xFFB3E5FC).withValues(alpha: 0.30), Colors.transparent,
      ]).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: w * 0.5)));

    final cubes = [
      [-w * 0.20, h * 0.15, 0.18, 0.0],
      [w * 0.22, h * 0.25, 0.15, 0.4],
      [0.0, 0.0, 0.20, -0.3],
    ];
    for (int i = 0; i < cubes.length; i++) {
      canvas.save();
      canvas.translate(cx + cubes[i][0], cy + cubes[i][1]);
      canvas.rotate(cubes[i][3] + sin(time * 0.8 + i) * 0.05);
      _drawIceCube(canvas, w * cubes[i][2], h * cubes[i][2]);
      canvas.restore();
    }

    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * pi * 2 + time * 0.3;
      final r = w * 0.4;
      final x = cx + cos(angle) * r;
      final y = cy + sin(angle) * r * 0.7;
      final sp = (sin(time * 3 + i) + 1) / 2;
      canvas.drawCircle(Offset(x, y), 1 + sp * 2,
        Paint()..color = Colors.white.withValues(alpha: sp * 0.8));
    }
  }

  void _drawIceCube(Canvas canvas, double cw, double ch) {
    final top = Path()
      ..moveTo(0, -ch * 0.5)..lineTo(cw * 0.5, -ch * 0.35)
      ..lineTo(0, -ch * 0.15)..lineTo(-cw * 0.5, -ch * 0.35)..close();
    canvas.drawPath(top, Paint()..color = const Color(0xFFE1F5FE).withValues(alpha: 0.9));
    final left = Path()
      ..moveTo(-cw * 0.5, -ch * 0.35)..lineTo(0, -ch * 0.15)
      ..lineTo(0, ch * 0.5)..lineTo(-cw * 0.5, ch * 0.35)..close();
    canvas.drawPath(left, Paint()..color = const Color(0xFF81D4FA).withValues(alpha: 0.8));
    final right = Path()
      ..moveTo(0, -ch * 0.15)..lineTo(cw * 0.5, -ch * 0.35)
      ..lineTo(cw * 0.5, ch * 0.35)..lineTo(0, ch * 0.5)..close();
    canvas.drawPath(right, Paint()..color = const Color(0xFF4FC3F7).withValues(alpha: 0.75));
    canvas.drawLine(Offset(-cw * 0.35, -ch * 0.35), Offset(-cw * 0.1, -ch * 0.2),
      Paint()..color = Colors.white.withValues(alpha: 0.8)
        ..strokeWidth = 1.4..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant IcePainter old) => old.time != time;
}

