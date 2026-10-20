part of chem_lab;

class MarbleBenchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()
      ..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [LC.marbleHighlight, LC.marbleBase]).createShader(Offset.zero & size));
    final rng = Random(42);
    for (int i = 0; i < 60; i++) {
      final start = Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height);
      final len = 50 + rng.nextDouble() * 200;
      final angle = rng.nextDouble() * pi;
      canvas.drawLine(start, Offset(start.dx + cos(angle) * len, start.dy + sin(angle) * len),
        Paint()..color = Colors.white.withValues(alpha: 0.08)..strokeWidth = 0.8);
    }
    for (int i = 0; i < 400; i++) {
      canvas.drawCircle(Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        0.3 + rng.nextDouble() * 0.6,
        Paint()..color = (rng.nextBool() ? Colors.white : Colors.black).withValues(alpha: 0.04));
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


