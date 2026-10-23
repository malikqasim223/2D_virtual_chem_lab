part of chem_lab;

class MarbleBenchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Clean gradient background (no white/gray lines)
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xCC222D42), // Dark bench color
          Color(0xCC161E2E), // Even darker
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


