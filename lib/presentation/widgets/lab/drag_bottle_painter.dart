part of chem_lab;

class DragBottlePainter extends CustomPainter {
  final Color color;
  DragBottlePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.35, 0, w * 0.30, h * 0.12),
      const Radius.circular(2)), Paint()..color = const Color(0xFF8B6A3F));
    canvas.drawRect(Rect.fromLTWH(w * 0.42, h * 0.12, w * 0.16, h * 0.08),
      Paint()..color = color.withValues(alpha: 0.7));
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.20, w * 0.70, h * 0.75), const Radius.circular(4));
    canvas.drawRRect(body, Paint()..shader = LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [color.withValues(alpha: 0.4), color.withValues(alpha: 0.9)])
      .createShader(body.outerRect));
  }
  @override
  bool shouldRepaint(covariant DragBottlePainter old) => old.color != color;
}


