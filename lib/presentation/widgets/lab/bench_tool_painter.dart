part of chem_lab;

class BenchToolPainter extends CustomPainter {
  final LabEffect type;
  final double time;
  BenchToolPainter({required this.type, required this.time});
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    switch (type) {
      case LabEffect.heat:
        canvas.drawOval(Rect.fromLTWH(w * 0.1, h * 0.82, w * 0.8, h * 0.15),
          Paint()..color = const Color(0xFF4B5563));
        canvas.drawRect(Rect.fromLTWH(w * 0.42, h * 0.3, w * 0.16, h * 0.5),
          Paint()..color = const Color(0xFF6B7280));
        break;
      case LabEffect.cool:
        canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.35,
          Paint()..color = const Color(0xFF6B92B8).withValues(alpha: 0.7));
        break;
      case LabEffect.stir:
        canvas.drawLine(Offset(w * 0.25, h * 0.85), Offset(w * 0.75, h * 0.15),
          Paint()..color = const Color(0xFFD8E3EC)..strokeWidth = 5..strokeCap = StrokeCap.round);
        break;
      case LabEffect.thermometer:
        canvas.drawRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.42, h * 0.1, w * 0.16, h * 0.7), const Radius.circular(4)),
          Paint()..color = Colors.white);
        canvas.drawCircle(Offset(w * 0.5, h * 0.83), w * 0.13,
          Paint()..color = const Color(0xFFB85450));
        break;
      case LabEffect.dropper:
        canvas.drawCircle(Offset(w * 0.5, h * 0.22), w * 0.2,
          Paint()..color = const Color(0xFF6B7280));
        canvas.drawRect(Rect.fromLTWH(w * 0.42, h * 0.4, w * 0.16, h * 0.4),
          Paint()..color = Colors.white.withValues(alpha: 0.9));
        break;
    }
  }
  @override
  bool shouldRepaint(covariant BenchToolPainter old) => old.time != time;
}

