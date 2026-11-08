part of chem_lab;

class MoleculePainter extends CustomPainter {
  final List<MoleculeAtom> atoms;
  final List<MoleculeBond> bonds;
  MoleculePainter({required this.atoms, required this.bonds});

  @override
  void paint(Canvas canvas, Size size) {
    if (atoms.isEmpty) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    
    // Compute bounding box
    double minX = double.infinity, maxX = -double.infinity;
    double minY = double.infinity, maxY = -double.infinity;
    for (var a in atoms) {
      if (a.x - a.radius < minX) minX = a.x - a.radius;
      if (a.x + a.radius > maxX) maxX = a.x + a.radius;
      if (a.y - a.radius < minY) minY = a.y - a.radius;
      if (a.y + a.radius > maxY) maxY = a.y + a.radius;
    }
    final w = (maxX - minX).clamp(0.5, 10.0);
    final h = (maxY - minY).clamp(0.5, 10.0);
    final centerX = (minX + maxX) / 2;
    final centerY = (minY + maxY) / 2;
    
    // Fit into canvas (75% — bigger than before)
    final availableW = size.width * 0.88;
    final availableH = size.height * 0.88;
    final scale = [availableW / w, availableH / h].reduce((a, b) => a < b ? a : b);
    
    // Compute pixel positions
    List<Offset> pixelPos = [];
    List<double> pixelR = [];
    for (var a in atoms) {
      pixelPos.add(Offset(
        cx + (a.x - centerX) * scale,
        cy + (a.y - centerY) * scale,
      ));
      pixelR.add(a.radius * scale * 0.50); // small balls - lots of gap
    }
    
    // â•â•â• DRAW BONDS (behind atoms) â•â•â•
    for (var b in bonds) {
      if (b.from >= atoms.length || b.to >= atoms.length) continue;
      final p1Center = pixelPos[b.from];
      final p2Center = pixelPos[b.to];
      final r1 = pixelR[b.from];
      final r2 = pixelR[b.to];
      
      final dx = p2Center.dx - p1Center.dx;
      final dy = p2Center.dy - p1Center.dy;
      final len = sqrt(dx * dx + dy * dy);
      if (len < 1) continue;
      
      // Direction unit vector
      final ux = dx / len;
      final uy = dy / len;
      // Perpendicular unit vector
      final px = -uy;
      final py = ux;
      
      // Bond start/end at atom edges
      final p1 = Offset(p1Center.dx + ux * r1 * 0.95, p1Center.dy + uy * r1 * 0.95);
      final p2 = Offset(p2Center.dx - ux * r2 * 0.95, p2Center.dy - uy * r2 * 0.95);
      
      final bondPaint = Paint()
        ..color = const Color(0xFF444444)
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      
      if (b.order == 1) {
        bondPaint.strokeWidth = 4;
        canvas.drawLine(p1, p2, bondPaint);
      } else {
        // Double bond — two parallel lines
        final sep = 3.5;
        bondPaint.strokeWidth = 3.5;
        canvas.drawLine(
          Offset(p1.dx + px * sep, p1.dy + py * sep),
          Offset(p2.dx + px * sep, p2.dy + py * sep),
          bondPaint,
        );
        canvas.drawLine(
          Offset(p1.dx - px * sep, p1.dy - py * sep),
          Offset(p2.dx - px * sep, p2.dy - py * sep),
          bondPaint,
        );
      }
    }
    
    // â•â•â• DRAW ATOMS on top â•â•â•
    for (int i = 0; i < atoms.length; i++) {
      final a = atoms[i];
      final pos = pixelPos[i];
      final r = pixelR[i];
      
      // Drop shadow
      canvas.drawCircle(Offset(pos.dx + 2, pos.dy + 4), r,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      
      // Base fill
      canvas.drawCircle(pos, r, Paint()..color = Color(a.color));
      
      // Radial gradient for 3D shine (top-left highlight)
      final shinePaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.45, -0.45),
          radius: 1.4,
          colors: [
            Colors.white.withValues(alpha: 0.85),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.55],
        ).createShader(Rect.fromCircle(center: pos, radius: r));
      canvas.drawCircle(pos, r, shinePaint);
      
      // Darker bottom-right
      final shadowPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.55, 0.55),
          radius: 1.5,
          colors: [
            Color(0xFF94A3B8).withValues(alpha: 0.2),
            Colors.black.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.7],
        ).createShader(Rect.fromCircle(center: pos, radius: r));
      canvas.drawCircle(pos, r, shadowPaint);
      
      // Bold dark outline (matches reference style)
      canvas.drawCircle(pos, r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = Colors.black.withValues(alpha: 0.75));
      
      // Symbol text
      final symbolStyle = TextStyle(
        color: Color(0xFF94A3B8).withValues(alpha: 0.2),
        fontSize: r * 0.88,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
        height: 1.0,
      );
      final tp = TextPainter(
        text: TextSpan(text: a.symbol, style: symbolStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant MoleculePainter old) =>
      old.atoms != atoms || old.bonds != bonds;
}


