part of chem_lab;

class RealisticEquipPainter extends CustomPainter {
  final EquipShape shape;
  final EquipItem item;
  final bool isHovered;
  final double time;
  final ReactionInfo? reaction;
  RealisticEquipPainter({required this.shape, required this.item,
    required this.isHovered, required this.time, required this.reaction});

  @override
  void paint(Canvas canvas, Size size) {
    final w = shape.size.width, h = shape.size.height;
    final ox = (size.width - w) / 2, oy = (size.height - h) / 2;
    canvas.save();
    canvas.translate(ox, oy);
    final path = _buildPath(w, h);

    canvas.drawOval(Rect.fromLTWH(w * 0.15, h * 0.96, w * 0.7, h * 0.05),
      Paint()..color = Color(0xFF94A3B8).withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));

    canvas.drawPath(path, Paint()..shader = LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [LC.glassTint.withValues(alpha: 0.12),
        LC.glassFill.withValues(alpha: 0.06),
        LC.glassTint.withValues(alpha: 0.10)]).createShader(Rect.fromLTWH(0, 0, w, h)));
    // GLASS OUTLINE Ã¢â‚¬â€ visible border
    canvas.drawPath(path, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = LC.glassEdge.withValues(alpha: 0.6));
    // Shine handled by gradients inside glass

    canvas.save();
    canvas.clipPath(path);
    if (item.layers.isNotEmpty) {
      // Strips BEHIND liquid (submerged look)
      if (item.hasLitmus) _paintLitmusStrip(canvas, w, h);
      if (item.hasPhPaper) _paintPhPaperStrip(canvas, w, h);
      _paintLayers(canvas, w, h);
      _paintSolidPile(canvas, w, h); // AFTER layers Ã¢â‚¬â€ residue on top
      _paintWave(canvas, w, h);
      if (reaction?.bubbles == true) _paintBubbles(canvas, w, h);
      _paintHeatingEffect(canvas, w, h);
      _paintGasEvolution(canvas, w, h);
      _paintSmoke(canvas, w, h);
      _paintFireBlast(canvas, w, h);
    // Skip for displacement Ã¢â‚¬â€ already drawn in _paintLayers
    if (reaction?.precipitate == true && !(reaction!.type.toLowerCase().contains('displacement'))) {
      _paintPrecipitate(canvas, w, h, reaction!.precipitateColor ?? reaction!.colorChange ?? LC.glassFill);
    }
      if (item.isStirring) _paintStir(canvas, w, h);
      if (item.isCold) _paintFrost(canvas, w, h);
    }
    canvas.restore();
    // Tools OUTSIDE glass clip so they are visible
    if (item.hasThermo) _paintThermometer(canvas, w, h);
    if (item.hasDropper) _paintDropper(canvas, w, h);
    if (reaction?.foam == true) _paintFoam(canvas, w, h);

    canvas.drawPath(path, Paint()..style = PaintingStyle.stroke
      ..strokeWidth = isHovered ? 2 : 1.3..strokeJoin = StrokeJoin.round
      ..color = isHovered ? LC.success : Colors.black.withValues(alpha: 0.6));

    _paintPour(canvas, w, h);
    _paintMarks(canvas, w, h); // With translate + after pour = on top
    canvas.restore();
  }

  Path _buildPath(double w, double h) {
    final path = Path();
    switch (shape) {
      case EquipShape.beaker:
        path.moveTo(w * 0.08, h * 0.10);
        path.lineTo(w * 0.85, h * 0.10);
        path.lineTo(w * 0.95, h * 0.13);
        path.lineTo(w * 0.87, h * 0.16);
        path.lineTo(w * 0.91, h * 0.16);
        path.lineTo(w * 0.91, h * 0.90);
        path.quadraticBezierTo(w * 0.91, h * 0.95, w * 0.82, h * 0.95);
        path.lineTo(w * 0.18, h * 0.95);
        path.quadraticBezierTo(w * 0.09, h * 0.95, w * 0.09, h * 0.90);
        path.close();
        break;
      case EquipShape.flask:
        path.moveTo(w * 0.40, h * 0.06);
        path.lineTo(w * 0.60, h * 0.06);
        path.lineTo(w * 0.60, h * 0.30);
        path.quadraticBezierTo(w * 0.97, h * 0.58, w * 0.97, h * 0.85);
        path.quadraticBezierTo(w * 0.97, h * 0.95, w * 0.85, h * 0.95);
        path.lineTo(w * 0.15, h * 0.95);
        path.quadraticBezierTo(w * 0.03, h * 0.95, w * 0.03, h * 0.85);
        path.quadraticBezierTo(w * 0.03, h * 0.58, w * 0.40, h * 0.30);
        path.close();
        break;
      case EquipShape.testTube:
        path.moveTo(w * 0.20, h * 0.06);
        path.lineTo(w * 0.80, h * 0.06);
        path.lineTo(w * 0.83, h * 0.09);
        path.lineTo(w * 0.80, h * 0.10);
        path.lineTo(w * 0.80, h * 0.82);
        path.quadraticBezierTo(w * 0.80, h * 0.95, w * 0.5, h * 0.95);
        path.quadraticBezierTo(w * 0.20, h * 0.95, w * 0.20, h * 0.82);
        path.close();
        break;
      case EquipShape.cylinder:
        path.moveTo(w * 0.30, h * 0.06);
        path.lineTo(w * 0.70, h * 0.06);
        path.lineTo(w * 0.73, h * 0.09);
        path.lineTo(w * 0.70, h * 0.10);
        path.lineTo(w * 0.70, h * 0.85);
        path.lineTo(w * 0.92, h * 0.94);
        path.lineTo(w * 0.92, h * 0.96);
        path.lineTo(w * 0.08, h * 0.96);
        path.lineTo(w * 0.08, h * 0.94);
        path.lineTo(w * 0.30, h * 0.85);
        path.close();
        break;
    }
    return path;
  }

  void _paintLayers(Canvas canvas, double w, double h) {    // Calculate blended color of all layers

    // === Reaction Color Blending (Audit Fix) ===
    Color blendedLayerColor = item.layers.isEmpty ? Colors.transparent : item.layers.first.color;
    if (item.layers.length > 1) {
      for (int i = 1; i < item.layers.length; i++) {
        blendedLayerColor = Color.lerp(blendedLayerColor, item.layers[i].color, 0.5)!;
      }
    }
    
    // If a reaction is in progress, blend towards reaction color
    Color finalLiquidColor = blendedLayerColor;
    if (reaction != null && item.reactionProgress > 0) {
      final Color? targetCol = reaction!.endColor ?? reaction!.colorChange;
      if (targetCol != null) {
        final double prog = item.reactionProgress.clamp(0.0, 1.0);
        finalLiquidColor = Color.lerp(blendedLayerColor, targetCol, prog)!;
      }
    }
    final slosh = sin(item.sloshPhase) * item.sloshAmp;
    final baseTop = _liquidTop(h);

    // === REACTION COMPLETE: separated products ===
    // ONLY precipitate reactions show separated salt bed
    // PRECIPITATE REACTION Ã¢â‚¬â€ liquid tinted, bed drawn by _paintPrecipitate
    if (reaction != null && item.reactionProgress > 0.3 && reaction!.precipitate) {
      Color liquidTint = reaction!.colorChange ?? item.blendedColor;
      final path = Path()
        ..moveTo(0, baseTop - slosh)
        ..lineTo(w, baseTop + slosh)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(path, Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [
            liquidTint.withValues(alpha: 0.40),
            liquidTint.withValues(alpha: 0.60),
            liquidTint.withValues(alpha: 0.75),
          ]).createShader(Rect.fromLTWH(0, baseTop - 2, w, h - baseTop + 2)));
      return;
    }

    // === GAS REACTION (bubbles, no precipitate) ===
    if (reaction != null && reaction!.bubbles && !reaction!.precipitate && item.reactionProgress > 0.3) {
      // Liquid stays same color, just agitated
      Color gasLiquid = item.blendedColor;
      if (reaction!.colorChange != null) {
        final _t = (item.reactionProgress * 1.5).clamp(0.0, 1.0);
        gasLiquid = Color.lerp(gasLiquid, reaction!.colorChange!, _t * 0.5)!; // subtle tint
      }
      final gasPath = Path()
        ..moveTo(0, baseTop - slosh)
        ..lineTo(w, baseTop + slosh)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(gasPath, Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [
            gasLiquid.withValues(alpha: 0.55),
            gasLiquid.withValues(alpha: 0.75),
            gasLiquid.withValues(alpha: 0.9),
          ]).createShader(Rect.fromLTWH(0, baseTop - 2, w, h - baseTop + 2)));
      return;
    }
    
    // === NORMAL: mixed liquid ===
    Color blended = item.blendedColor;
    if (reaction?.colorChange != null) {
      final _target = reaction!.colorChange!;
      final _t = (item.reactionProgress * 1.5).clamp(0.0, 1.0); // smooth 0->1 over 66% progress
      blended = Color.lerp(blended, _target, _t)!;
    }
    // Heat transform: CuSO4 (blue) -> anhydrous (white) at high temp
    if (item.isHeatedTransform && item.layers.any((l) => l.chemId == 'cuso4')) {
      blended = Color.lerp(blended, const Color(0xFFE8EDEF), ((item.temperature - 60) / 90).clamp(0.0, 0.9))!;
    }
    final path = Path()
      ..moveTo(0, baseTop - slosh)
      ..lineTo(w, baseTop + slosh)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [
          blended.withValues(alpha: 0.5),
          blended.withValues(alpha: 0.75),
          blended.withValues(alpha: 0.9),
        ],
      ).createShader(Rect.fromLTWH(0, baseTop - 2, w, h - baseTop + 2)));
  }

  // Shape-specific liquid top Ã¢â‚¬â€ matches markings exactly
  double _liquidTop(double h) {
    if (shape == EquipShape.flask) {
      return h * 0.92 - item.fillRatio * h * 0.50; // flask body (0.42-0.92)
    }
    return h * 0.95 - item.fillRatio * h * 0.83; // beaker/tube/cylinder
  }

  void _paintMarks(Canvas canvas, double w, double h) {
    // Shape-specific: major ticks (with numbers) + minor subdivisions
    final List<int> major;
    final List<int> minor;
    double yTop, yBot, rightX;
    int minorStep;

    switch (shape) {
      case EquipShape.beaker:
        major = [50, 100, 150, 200, 250];
        minorStep = 10;
        yTop = h * 0.12; yBot = h * 0.95; rightX = w * 0.86;
        break;
      case EquipShape.flask:
        major = [50, 100, 150, 200, 250];
        minorStep = 10;
        yTop = h * 0.42; yBot = h * 0.92; rightX = w * 0.55; // flask body only
        break;
      case EquipShape.testTube:
        major = [10, 20, 30, 40, 50];
        minorStep = 2;
        yTop = h * 0.18; yBot = h * 0.88; rightX = w * 0.76; // tube: inside body
        break;
      case EquipShape.cylinder:
        major = [20, 40, 60, 80, 100];
        minorStep = 5;
        yTop = h * 0.12; yBot = h * 0.95; rightX = w * 0.70;
        break;
    }

    final maxVol = major.last;
    final span = yBot - yTop;

    // Build minor list
    minor = <int>[];
    for (int v = minorStep; v < maxVol; v += minorStep) {
      if (!major.contains(v)) minor.add(v);
    }

    // === Minor ticks (thin, short) ===
    final minorPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    for (final v in minor) {
      final y = yBot - (v / maxVol) * span;
      canvas.drawLine(Offset(rightX - w * 0.045, y), Offset(rightX, y), minorPaint);
    }

    // === Major ticks (thick, long, with numbers) ===
    final majorPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    for (final v in major) {
      final y = yBot - (v / maxVol) * span;
      canvas.drawLine(Offset(rightX - w * 0.10, y), Offset(rightX, y), majorPaint);

      final tp = TextPainter(
        text: TextSpan(
          text: '$v',
          style: TextStyle(
            fontSize: 7.5,
            color: Colors.white.withValues(alpha: 0.92),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(rightX - w * 0.10 - tp.width - 4, y - 4));
    }

    // Small "mL" label at bottom of scale (except test tube which uses mL too)
    final unitTp = TextPainter(
      text: TextSpan(
        text: 'mL',
        style: TextStyle(
          fontSize: 6,
          color: Colors.white.withValues(alpha: 0.65),
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    unitTp.paint(canvas, Offset(rightX - unitTp.width - 2, yBot + 4));
  }



  void _paintWave(Canvas canvas, double w, double h) {
    final slosh = sin(item.sloshPhase) * item.sloshAmp;
    final baseTop = _liquidTop(h);
    final amp = 1.5 + item.fillRatio * 1.5;
    final wavePath = Path()..moveTo(0, baseTop - slosh);
    for (double x = 0; x <= w; x += 2) {
      final tilt = ((x / w) - 0.5) * 2 * slosh;
      wavePath.lineTo(x, baseTop + tilt + sin((x / w) * pi * 3 + time * 3) * amp);
    }
    canvas.drawPath(wavePath, Paint()
      ..style = PaintingStyle.stroke..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.5));
  }

  // REAL gas colors Ã¢â‚¬â€ based on chemistry
  Color _gasColor(String? gas) {
    switch (gas) {
      case 'NO2': return const Color(0xFF8B4513); // Brown (red-brown)
      case 'Cl2': return const Color(0xFFA5D6A7); // Pale greenish-yellow
      case 'Br2': return const Color(0xFF8B0000); // Red-brown vapor
      case 'I2':  return const Color(0xFF9C27B0); // Purple vapor
      case 'H2':  return const Color(0xFFE0E0E0); // Colorless (light gray for visibility)
      case 'O2':  return const Color(0xFFF0F0F0); // Colorless
      case 'CO2': return const Color(0xFFF5F5F5); // Colorless
      case 'NH3': return const Color(0xFFF5F5F5); // Colorless (pungent)
      case 'SO2': return const Color(0xFFF5F5F5); // Colorless
      case 'H2S': return const Color(0xFFF5F5F5); // Colorless (rotten egg)
      case 'HCl': return const Color(0xFFF5F5DC); // Pale yellow fumes
      // duplicate I2 removed
      case 'H2':  return const Color(0xFFE0E0E0); // Colorless (gray for visibility)
      case 'O2':  return const Color(0xFFF0F0F0); // Colorless
      case 'N2':  return const Color(0xFFF0F0F0); // Colorless
      default:    return const Color(0xFFF0F0F0); // Colorless
    }
  }
  
  void _paintBubbles(Canvas canvas, double w, double h) {
    final top = _liquidTop(h);
    final gasCol = _gasColor(reaction?.gasEvolution);
    final rng = Random(42);
    // === RISING BUBBLES (grow + burst) ===
    for (int i = 0; i < 16; i++) {
      final bx = rng.nextDouble() * w;
      final speed = 0.3 + rng.nextDouble() * 0.5;
      final progress = (time * speed + rng.nextDouble()) % 1.0;
      final by = h - progress * (h - top);
      final baseR = 1.5 + rng.nextDouble() * 2.5;
      final r = baseR * (0.5 + progress * 0.8); // grow as they rise
      final bRect = Rect.fromCircle(center: Offset(bx, by), radius: r);
      // Radial gradient fill (hollow center look)
      canvas.drawCircle(Offset(bx, by), r, Paint()
        ..shader = RadialGradient(colors: [
          gasCol.withValues(alpha: 0.12),
          gasCol.withValues(alpha: 0.45),
          gasCol.withValues(alpha: 0.72),
        ], stops: const [0.0, 0.6, 1.0]).createShader(bRect));
      // White shine (light source top-left)
      canvas.drawCircle(Offset(bx - r * 0.32, by - r * 0.32), r * 0.32,
        Paint()..color = Colors.white.withValues(alpha: 0.75));
      // Outline rim
      canvas.drawCircle(Offset(bx, by), r, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7
        ..color = gasCol.withValues(alpha: 0.85));
      // Burst effect at surface
      if (progress > 0.85) {
        final bt = (progress - 0.85) / 0.15;
        canvas.drawCircle(Offset(bx, by), r * (1 + bt * 1.6), Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = (1 - bt) * 1.4
          ..color = gasCol.withValues(alpha: (1 - bt) * 0.65));
      }
    }
    // === FOAM LAYER AT SURFACE (cluster of small bubbles) ===
    final foamRng = Random(73);
    for (int i = 0; i < 14; i++) {
      final fx = foamRng.nextDouble() * w;
      final fy = top + foamRng.nextDouble() * 7 - 3;
      final fr = 1.0 + foamRng.nextDouble() * 2.2;
      canvas.drawCircle(Offset(fx, fy), fr,
        Paint()..color = gasCol.withValues(alpha: 0.55));
      canvas.drawCircle(Offset(fx, fy), fr, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = Colors.white.withValues(alpha: 0.65));
    }
  }
  // Precipitate style Ã¢â‚¬â€ unique per precipitate type (real chemistry)
  String _precipStyle() {
    final rxn = reaction;
    if (rxn == null) return 'default';
    final products = rxn.products.join(' ').toLowerCase();
    final key = (rxn.name + ' ' + rxn.equation).toLowerCase();
    // CURDY Ã¢â‚¬â€ white clumpy (AgCl, Ag2SO4)
    if (products.contains('agcl')) return 'curdy-white';
    if (products.contains('ag2so4')) return 'curdy-white';
    // GELATINOUS Ã¢â‚¬â€ blobby, slow settle (Cu(OH)2, Fe(OH)3, Al(OH)3)
    if (products.contains('cu(oh)2')) return 'gel-blue';
    if (products.contains('fe(oh)3')) return 'gel-brown';
    if (products.contains('fe(oh)2')) return 'gel-green';
    if (products.contains('al(oh)3')) return 'gel-white';
    if (products.contains('zn(oh)2')) return 'gel-white';
    if (products.contains('mg(oh)2')) return 'gel-white';
    // GRANULAR Ã¢â‚¬â€ small particles, fast settle (PbI2, BaSO4)
    if (products.contains('pbi2')) return 'granular-gold';
    if (products.contains('baso4')) return 'granular-white';
    if (products.contains('caco3')) return 'granular-white';
    if (products.contains('cac2o4')) return 'granular-white';
    if (products.contains('ag3po4')) return 'granular-yellow';
    // METAL DEPOSIT Ã¢â‚¬â€ coating on metal (Cu, Ag)
    if (rxn.type.toLowerCase().contains('single displacement')) return 'metal-deposit'; // ONLY single
    // MILKY Ã¢â‚¬â€ clouded throughout (limewater)
    if (key.contains('limewater') || key.contains('milky')) return 'milky';
    // AG2O Ã¢â‚¬â€ brown heavy
    if (products.contains('ag2o')) return 'heavy-brown';
    // IODOFORM Ã¢â‚¬â€ bright yellow crystalline
    if (products.contains('chi3')) return 'granular-yellow';
    // TRIBROMOPHENOL Ã¢â‚¬â€ white crystalline
    if (products.contains('c6h2br3oh')) return 'granular-white';
    return 'default';
  }

  // Precipitate density (particle count multiplier)
  double _precipDensity() {
    switch (_precipStyle()) {
      case 'curdy-white': return 1.3;
      case 'gel-blue': return 1.1;
      case 'gel-brown': return 1.4;
      case 'gel-green': return 1.2;
      case 'gel-white': return 1.0;
      case 'granular-gold': return 1.5;
      case 'granular-white': return 1.1;
      case 'granular-yellow': return 1.4;
      case 'metal-deposit': return 0.7;
      case 'milky': return 2.0;
      case 'heavy-brown': return 1.6;
      default: return 1.25;
    }
  }

  // Precipitate settling rate (0.5 = slow, 2.0 = fast)
  double _precipSettleRate() {
    switch (_precipStyle()) {
      case 'curdy-white': return 1.0;   // clumpy
      case 'gel-blue': return 0.9;      // gelatinous
      case 'gel-brown': return 0.9;
      case 'gel-green': return 0.9;
      case 'gel-white': return 0.9;
      case 'granular-gold': return 1.5; // fast
      case 'granular-white': return 1.8; // very fast
      case 'granular-yellow': return 1.5;
      case 'metal-deposit': return 2.0;
      case 'milky': return 0.8;
      case 'heavy-brown': return 1.0;
      default: return 1.25;
    }
  }

  // Particle size (1.0 = normal)
  double _precipParticleSize() {
    switch (_precipStyle()) {
      case 'curdy-white': return 1.4;   // big clumps
      case 'gel-blue': return 1.6;      // blobby
      case 'gel-brown': return 1.8;
      case 'gel-green': return 1.5;
      case 'granular-gold': return 0.8; // fine crystals
      case 'granular-white': return 0.7;
      case 'granular-yellow': return 0.9;
      case 'metal-deposit': return 1.2;
      case 'milky': return 0.5;         // very fine
      default: return 1.25;
    }
  }

  void _paintPrecipitate(Canvas canvas, double w, double h, Color color) {
    final progress = item.reactionProgress.clamp(0.0, 1.0);
    final style = _precipStyle();
    final density = _precipDensity();
    final settleRate = _precipSettleRate();
    final particleSize = _precipParticleSize();
    final settleT = (progress * 2.0 * settleRate).clamp(0.0, 1.0); // faster settle
    if (settleT <= 0.0) return;
    
    // METAL DEPOSIT Ã¢â‚¬â€ coating on metal, no settling bed
    if (style == 'metal-deposit') {
      final rng = Random(item.id.length * 11 + 7);
      // Particles form on side/bottom (attached to metal)
      final depositCount = (35 * (item.totalVolume / 50.0).clamp(0.5, 2.0)).toInt();
      for (int i = 0; i < depositCount; i++) {
        final px = w * 0.15 + rng.nextDouble() * w * 0.7;
        final py = h * 0.55 + rng.nextDouble() * h * 0.4;
        final r = (1.5 + rng.nextDouble() * 2.5) * particleSize;
        canvas.drawCircle(Offset(px, py), r, Paint()..color = color.withValues(alpha: 0.85 * settleT));
        canvas.drawCircle(Offset(px - r * 0.3, py - r * 0.3), r * 0.35, Paint()..color = Colors.white.withValues(alpha: 0.6 * settleT));
      }
      return;
    }
    
    // MILKY Ã¢â‚¬â€ clouded throughout (no distinct bed)
    if (style == 'milky') {
      final rng = Random(item.id.length * 23 + 13);
      for (int i = 0; i < (80 * density).toInt(); i++) {
        final px = rng.nextDouble() * w;
        final py = h * 0.25 + rng.nextDouble() * h * 0.75;
        final r = (0.8 + rng.nextDouble() * 1.8) * particleSize;
        canvas.drawCircle(Offset(px, py), r, Paint()..color = color.withValues(alpha: 0.35 * settleT));
      }
      return;
    }
    
    // BED STYLES Ã¢â‚¬â€ granular, curdy, gel, heavy
    // Bed height SCALES with amount Ã¢â‚¬â€ more reactant = more precipitate
    final totalVol = item.totalVolume;
    final amountFactor = (totalVol / 100.0).clamp(0.3, 1.5); // 50=0.5, 100=1.0, 150=1.5
    final maxH = h * 0.45 * amountFactor; // scales with amount
    final pHeight = maxH * settleT;
    final pTop = h - pHeight;
    
    // === CLOUDY TOP LAYER (turbid diffusion) ===
    final cloudH = style.contains('granular') ? 6.0 : 14.0;
    final cloudRect = Rect.fromLTWH(0, pTop - cloudH, w, cloudH * 1.8);
    canvas.drawRect(cloudRect, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.0), color.withValues(alpha: 0.30 * settleT)]
      ).createShader(cloudRect));
    
    // === MAIN BED ===    
    final bedRect = Rect.fromLTWH(0, pTop, w, pHeight);
    canvas.drawRect(bedRect, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.55 * settleT),  // stronger top
          color.withValues(alpha: 0.85 * settleT),
          color.withValues(alpha: 1.00 * settleT),  // full bottom
        ], stops: const [0.0, 0.55, 1.0]).createShader(bedRect));
    
    // === STYLE-SPECIFIC PARTICLES ===
    final rng = Random(item.id.length * 13 + 17);
    final amountScale = (item.totalVolume / 100.0).clamp(0.4, 1.5);
    final particleCount = (45 * density * amountScale).toInt(); // scales with amount
    
    for (int i = 0; i < particleCount; i++) {
      final px = w * 0.05 + rng.nextDouble() * w * 0.9;
      final py = pTop + rng.nextDouble() * pHeight * 0.85;
      final r = (1.2 + rng.nextDouble() * 2.0) * particleSize;
      
      if (style.contains('curdy')) {
        // Big clumpy blobs
        final blobPath = Path()
          ..moveTo(px - r * 1.2, py)
          ..quadraticBezierTo(px - r * 0.8, py - r * 1.3, px, py - r)
          ..quadraticBezierTo(px + r * 0.8, py - r * 1.3, px + r * 1.2, py)
          ..quadraticBezierTo(px + r * 0.6, py + r * 0.8, px, py + r * 0.5)
          ..quadraticBezierTo(px - r * 0.6, py + r * 0.8, px - r * 1.2, py)
          ..close();
        canvas.drawPath(blobPath, Paint()..color = color.withValues(alpha: 0.85));
        canvas.drawCircle(Offset(px - r * 0.4, py - r * 0.4), r * 0.4, Paint()..color = Colors.white.withValues(alpha: 0.55));
      } else if (style.contains('gel')) {
        // Gelatinous semi-transparent blobs
        canvas.drawCircle(Offset(px, py), r * 1.3, Paint()
          ..color = color.withValues(alpha: 0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5));
        canvas.drawCircle(Offset(px, py), r * 0.9, Paint()..color = color.withValues(alpha: 0.85));
        canvas.drawCircle(Offset(px - r * 0.3, py - r * 0.4), r * 0.35, Paint()..color = Colors.white.withValues(alpha: 0.55));
      } else if (style.contains('granular')) {
        // Small sharp crystals
        canvas.drawCircle(Offset(px, py), r * 0.7, Paint()..color = color.withValues(alpha: 0.92));
        canvas.drawCircle(Offset(px - r * 0.25, py - r * 0.25), r * 0.25, Paint()..color = Colors.white.withValues(alpha: 0.7));
      } else {
        canvas.drawCircle(Offset(px, py), r, Paint()..color = color.withValues(alpha: 0.85));
        canvas.drawCircle(Offset(px - r * 0.3, py - r * 0.3), r * 0.4, Paint()..color = Colors.white.withValues(alpha: 0.5));
      }
    }
    
    // === EDGE GLOW (only for light precipitates) ===
    final isLightPpt = color.r > 0.75 && color.g > 0.75 && color.b > 0.75;
    if (isLightPpt) {
      canvas.drawLine(Offset(0, pTop), Offset(w, pTop), Paint()
        ..strokeWidth = 1.2
        ..color = Colors.black.withValues(alpha: 0.75 * settleT)); // stronger
      canvas.drawRect(bedRect, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.black.withValues(alpha: 0.65 * settleT)); // stronger
    }
  }
  void _paintStir(Canvas canvas, double w, double h) {
    // Rotating stirrer rod
    final cx = w * 0.5 + sin(time * 5) * w * 0.12;
    final cy = h * 0.50;

    // Rotation ripple circles
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(cx, cy),
        w * (0.10 + i * 0.06),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = Colors.white.withValues(alpha: 0.35 - i * 0.08));
    }

    // Glass rod
    final rodTop = Offset(cx + sin(time * 2) * w * 0.02, h * 0.05);
    final rodBot = Offset(cx + sin(time * 4) * w * 0.05, h * 0.88);
    canvas.drawLine(rodTop, rodBot,
      Paint()
        ..color = LC.glassEdge
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round);

    // Highlight on rod
    canvas.drawLine(
      Offset(rodTop.dx - 0.8, rodTop.dy),
      Offset(rodBot.dx - 0.8, rodBot.dy),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round);

    // Bottom paddle
    canvas.drawOval(
      Rect.fromCenter(center: rodBot, width: 18, height: 6),
      Paint()..color = LC.glassEdge.withValues(alpha: 0.6));
  }

  void _paintLitmusStrip(Canvas canvas, double w, double h) {
    final stripW = w * 0.14;
    final stripH = h * 0.58;
    final fillRatio = item.fillRatio;
    final liquidTop = h * (1 - fillRatio);
    final stripTop = (liquidTop - stripH * 0.50).clamp(h * 0.05, h * 0.85);
    // Float physics â€” subtle movement like real liquid
    final floatY = sin(time * 2.8) * h * 0.005;
    final floatX = sin(time * 2.2 + 0.5) * w * 0.008;
    final floatTilt = sin(time * 1.8) * 0.04;
    canvas.save();
    canvas.translate((w - stripW) / 2 + floatX, stripTop + floatY);
    canvas.rotate(floatTilt);
    canvas.translate(-(w - stripW) / 2, -stripTop);
    final strip = Rect.fromLTWH((w - stripW) / 2, stripTop, stripW, stripH);

    // Drop shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(strip.shift(const Offset(1.5, 2.5)), const Radius.circular(2)),
      Paint()..color = Color(0xFF94A3B8).withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    // DRY LITMUS BASE â€” purple/blue color (real litmus paper)
    const dryColor = Color(0xFF8E6BB0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(strip, const Radius.circular(2)),
      Paint()..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF9B7BC0),
          dryColor,
          const Color(0xFF7A5A9A),
        ],
      ).createShader(strip),
    );

    // Paper texture
    final rng = Random(42);
    for (int i = 0; i < 20; i++) {
      final y = strip.top + rng.nextDouble() * strip.height;
      canvas.drawLine(
        Offset(strip.left + 1, y),
        Offset(strip.right - 1, y),
        Paint()..color = Colors.black.withValues(alpha: 0.04)..strokeWidth = 0.3,
      );
    }

    // COLOR DEVELOP â€” from tip upward (submerged in liquid)
    final ph = LabPhService.calculatePh(item);
    if (ph != null && item.layers.isNotEmpty) {
      final color = PhCalculator.litmusColor(ph);
      // Color the WHOLE strip (capillary action rises through paper)
      final colorH = strip.height * item.stripColorProgress;
      final submergedH = colorH;
      if (submergedH > 0) {
        final developRect = Rect.fromLTWH(
          strip.left, strip.bottom - submergedH, strip.width, submergedH);

        // Gradient color â€” strong at tip, fade upward
        canvas.drawRect(
          developRect,
          Paint()..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              color,
              Color.lerp(color, dryColor, 0.05)!,
              Color.lerp(color, dryColor, 0.20)!,
            ],
            stops: const [0.0, 0.6, 1.0],
          ).createShader(developRect),
        );

        // Wet shine
        canvas.drawRect(
          developRect,
          Paint()..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.white.withValues(alpha: 0.0),
              Colors.white.withValues(alpha: 0.3),
              Colors.white.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.4, 1.0],
          ).createShader(developRect),
        );

        // Meniscus
        canvas.drawLine(
          Offset(strip.left, liquidTop),
          Offset(strip.right, liquidTop),
          Paint()
            ..color = color.withValues(alpha: 0.7)
            ..strokeWidth = 1.2,
        );
        canvas.drawLine(
          Offset(strip.left, liquidTop - 1),
          Offset(strip.right, liquidTop - 1),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.4)
            ..strokeWidth = 0.6,
        );
      }
    }

    // White label at top (like real litmus book)
    canvas.drawRect(
      Rect.fromLTWH(strip.left + 2, strip.top + 2, strip.width - 4, 5),
      Paint()..color = LC.glassEdge,
    );
    // "LITMUS" text bars
    canvas.drawRect(
      Rect.fromLTWH(strip.left + 4, strip.top + 3.5, strip.width - 8, 1.2),
      Paint()..color = const Color(0xFF5E35B1),
    );
    canvas.drawRect(
      Rect.fromLTWH(strip.left + 5, strip.top + 5.5, strip.width - 10, 0.8),
      Paint()..color = const Color(0xFF5E35B1).withValues(alpha: 0.6),
    );

    // Outer border
    canvas.drawRRect(
      RRect.fromRectAndRadius(strip, const Radius.circular(2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.black.withValues(alpha: 0.35),
    );
    canvas.restore();
  }

  void _paintPhPaperStrip(Canvas canvas, double w, double h) {
    final stripW = w * 0.14;
    final stripH = h * 0.58;
    final fillRatio = item.fillRatio;
    final liquidTop = h * (1 - fillRatio);
    // Strip hangs from above â€” top portion out of liquid
    final stripTop = (liquidTop - stripH * 0.50).clamp(h * 0.05, h * 0.85);
    // Float physics â€” subtle movement like real liquid
    final floatY = sin(time * 2.8 + 0.3) * h * 0.005;
    final floatX = sin(time * 2.2 + 0.8) * w * 0.008;
    final floatTilt = sin(time * 1.8 + 0.2) * 0.04;
    canvas.save();
    canvas.translate((w - stripW) / 2 + floatX, stripTop + floatY);
    canvas.rotate(floatTilt);
    canvas.translate(-(w - stripW) / 2, -stripTop);
    final strip = Rect.fromLTWH((w - stripW) / 2, stripTop, stripW, stripH);

    // Drop shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(strip.shift(const Offset(1.5, 2.5)), const Radius.circular(2)),
      Paint()..color = Color(0xFF94A3B8).withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    // WHITE BASE (dry pH paper is always white)
    canvas.drawRRect(
      RRect.fromRectAndRadius(strip, const Radius.circular(2)),
      Paint()..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFFFEF8),
          const Color(0xFFF8F8EC),
          const Color(0xFFF0EBD8),
        ],
      ).createShader(strip),
    );

    // Paper texture â€” subtle horizontal fibers
    final rng = Random(42);
    for (int i = 0; i < 20; i++) {
      final y = strip.top + rng.nextDouble() * strip.height;
      canvas.drawLine(
        Offset(strip.left + 1, y),
        Offset(strip.right - 1, y),
        Paint()..color = Colors.black.withValues(alpha: 0.03)..strokeWidth = 0.3,
      );
    }

    // COLOR DEVELOP â€” from TIP upward (like real capillary action)
    final ph = LabPhService.calculatePh(item);
    if (ph != null && item.layers.isNotEmpty) {
      final color = PhCalculator.colorForPh(ph);
      // Only submerged portion gets colored
      // Color the WHOLE strip (capillary action rises through paper)
      final colorH = strip.height * item.stripColorProgress;
      final submergedH = colorH;
      if (submergedH > 0) {
        final developRect = Rect.fromLTWH(
          strip.left, strip.bottom - submergedH, strip.width, submergedH);

        // Main color with gradient (strong at tip, fade upward)
        canvas.drawRect(
          developRect,
          Paint()..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              color,
              Color.lerp(color, const Color(0xFFFAFAF5), 0.05)!,
              Color.lerp(color, const Color(0xFFFAFAF5), 0.20)!,
            ],
            stops: const [0.0, 0.6, 1.0],
          ).createShader(developRect),
        );

        // Wet shine (submerged portion is wet & glossy)
        canvas.drawRect(
          developRect,
          Paint()..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.white.withValues(alpha: 0.0),
              Colors.white.withValues(alpha: 0.35),
              Colors.white.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.4, 1.0],
          ).createShader(developRect),
        );

        // Meniscus line â€” where paper meets liquid
        canvas.drawLine(
          Offset(strip.left, liquidTop),
          Offset(strip.right, liquidTop),
          Paint()
            ..color = color.withValues(alpha: 0.7)
            ..strokeWidth = 1.2,
        );
        canvas.drawLine(
          Offset(strip.left, liquidTop - 1),
          Offset(strip.right, liquidTop - 1),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.4)
            ..strokeWidth = 0.6,
        );
      }
    }

    // Top white reference band
    canvas.drawRect(
      Rect.fromLTWH(strip.left + 1, strip.top + 2, strip.width - 2, 3),
      Paint()..color = LC.glassEdge.withValues(alpha: 0.8),
    );

    // Outer border
    canvas.drawRRect(
      RRect.fromRectAndRadius(strip, const Radius.circular(2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.black.withValues(alpha: 0.35),
    );
    canvas.restore();
  }

  void _paintFrost(Canvas canvas, double w, double h) {
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.60, w, h * 0.40),
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFFB3E5FC).withValues(alpha: 0.35),
          const Color(0xFF81D4FA).withValues(alpha: 0.60),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, h * 0.60, w, h * 0.40)));
    final rng = Random(42);
    for (int i = 0; i < 18; i++) {
      final x = rng.nextDouble() * w;
      final y = h - rng.nextDouble() * h * 0.25;
      final r = 1.5 + rng.nextDouble() * 3.0;
      canvas.drawCircle(Offset(x, y), r,
        Paint()..color = Colors.white.withValues(alpha: 0.8));
      canvas.drawCircle(Offset(x, y), r * 2.2,
        Paint()..style = PaintingStyle.stroke..strokeWidth = 0.5
          ..color = const Color(0xFFB3E5FC).withValues(alpha: 0.75));
    }
    for (int i = 0; i < 30; i++) {
      final x = rng.nextDouble() * w;
      final y = rng.nextDouble() * h * 0.4;
      canvas.drawCircle(Offset(x, y), 0.5 + rng.nextDouble() * 1.3,
        Paint()..color = Colors.white.withValues(alpha: 0.65));
    }
  }

  // Reaction-specific fire colors (real chemistry)
  List<Color> _fireColors() {
    final rxn = reaction;
    if (rxn == null) return [const Color(0xFFFFEB3B), const Color(0xFFE53935), const Color(0xFF4A0000)];
    final name = rxn.name.toUpperCase();
    final eq = rxn.equation.toUpperCase();
    // Potassium Ã¢â€ â€™ lilac/purple
    if (eq.contains('K ') || name.contains('POTASSIUM')) {
      return [const Color(0xFFE1BEE7), const Color(0xFF9C27B0), const Color(0xFF4A148C)];
    }
    // Sodium Ã¢â€ â€™ orange-yellow (classic)
    if (eq.contains('NA ') || name.contains('SODIUM')) {
      return [const Color(0xFFFFF176), const Color(0xFFFF6F00), const Color(0xFF8B0000)]; // sodium: orange-yellow
    }
    // Magnesium Ã¢â€ â€™ bright white-blue
    if (name.contains('MAGNESIUM') || eq.contains('MG ')) {
      return [const Color(0xFFFFFFFF), const Color(0xFFB0E0E6), const Color(0xFF4682B4)];
    }
    // Calcium Ã¢â€ â€™ pale yellow
    if (name.contains('CALCIUM') || eq.contains('CA ')) {
      return [const Color(0xFFFFF9C4), const Color(0xFFFFEB3B), const Color(0xFFF57F17)];
    }
    // Default Ã¢â€ â€™ orange-red
    return [const Color(0xFFFFEB3B), const Color(0xFFE53935), const Color(0xFF4A0000)];
  }
  
  // Fire animation style Ã¢â‚¬â€ unique per reaction
  String _fireStyle() {
    final rxn = reaction;
    if (rxn == null) return 'default';
    final name = rxn.name.toUpperCase();
    final eq = rxn.equation.toUpperCase();
    final k = rxn.equation.toLowerCase();
    // K + H2O Ã¢â€ â€™ dancing lilac flame (metal moves on surface)
    if (k.contains('2k + 2h2o') || (eq.contains('K ') && eq.contains('H2O'))) return 'dancing-lilac';
    // Na + H2O Ã¢â€ â€™ dancing orange (sodium skitters)
    if (k.contains('2na + 2h2o')) return 'dancing-orange';
    // Na + HCl Ã¢â€ â€™ white-hot explosion (instant)
    if (k.contains('2na + 2hcl')) return 'explosion-white';
    // Na + H2SO4 Ã¢â€ â€™ intense white-hot explosion
    if (k.contains('2na + h2so4')) return 'explosion-intense';
    // Mg + HCl Ã¢â€ â€™ bright white glow (no flame, just heat)
    if (name.contains('MAGNESIUM') && k.contains('hcl')) return 'glow-white';
    // Ca + water Ã¢â€ â€™ pale yellow gentle
    if (name.contains('CALCIUM')) return 'gentle-yellow';
    return 'default';
  }

  // Intensity multiplier (0.5 = weak, 1.0 = normal, 1.3 = intense)
  double _fireIntensity() {
    final style = _fireStyle();
    switch (style) {
      case 'dancing-lilac': return 1.40;   // K more vigorous than Na
      case 'dancing-orange': return 1.25;   // Na = baseline
      case 'explosion-white': return 1.45;  // HCl more violent
      case 'explosion-intense': return 1.55;// H2SO4 most violent
      case 'glow-white': return 0.85;       // Mg = steady glow
      case 'gentle-yellow': return 0.75;    // Ca = mild
      default: return 1.25;
    }
  }

  // Flame wobble amount (dancing reactions wobble more)
  double _fireWobble() {
    final style = _fireStyle();
    if (style.contains('dancing')) return 2.4;
    if (style.contains('explosion')) return 0.45;
    if (style.contains('glow')) return 0.1;
    return 1.0;
  }

  // Horizontal drift (metal moves across water surface)
  double _fireDrift() {
    final style = _fireStyle();
    if (style == 'dancing-lilac') return 0.85;
    if (style == 'dancing-orange') return 0.65;
    return 0.0;
  }

  void _paintFireBlast(Canvas canvas, double w, double h) {
    if (reaction == null || !reaction!.isViolent) return;
    // === PERSISTENT STATE (after reaction complete) ===
    // Only bubbles + smoke Ã¢â‚¬â€ no fire
    if (item.reactionComplete && item.reactionProgress >= 1.0) {
      final rng = Random(42);
      final cx = w * 0.5;
      final baseY = h * 0.90;

      // === BOILING BUBBLES (inside liquid) ===
      for (int i = 0; i < 18; i++) {
        final seed = rng.nextDouble();
        final bx = cx + (rng.nextDouble() - 0.5) * w * 0.7;
        final prog = ((time * 0.8 + seed) % 1.0);
        final by = baseY - prog * h * 0.5;
        final bs = 2 + (1 - prog) * 4;
        final ba = (1 - prog) * 0.7;
        canvas.drawCircle(Offset(bx, by), bs, Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = _fireColors()[0].withValues(alpha: ba));
        canvas.drawCircle(Offset(bx, by), bs * 0.4, Paint()
          ..color = Colors.white.withValues(alpha: ba * 0.8));
      }

      // === LIGHT SMOKE (thin, rising) ===
      for (int i = 0; i < 10; i++) {
        final seed = rng.nextDouble();
        final sx = cx + (rng.nextDouble() - 0.5) * w * 0.7;
        final prog = ((time * 0.35 + seed) % 1.0);
        final sy = h * 0.4 - prog * h * 0.5;
        final ss = 18 + prog * 30;
        final sa = sin(prog * 3.14159) * 0.35;
        final sway = sin(time * 1.2 + seed * 6) * 8;
        canvas.drawCircle(Offset(sx + sway, sy), ss, Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFF5A5A5A).withValues(alpha: sa),
            const Color(0xFF3A3A3A).withValues(alpha: sa * 0.5),
            Colors.transparent,
          ]).createShader(Rect.fromCircle(center: Offset(sx + sway, sy), radius: ss))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
      }

      return;
    }

    final rng = Random(42);
    final progress = item.reactionProgress;
    final cx = w * 0.5;
    final cy = _liquidTop(h); // liquid top level
    
    // UNIQUE FIRE STYLE per reaction
    final fireStyle = _fireStyle();
    final fireIntensity = _fireIntensity();
    final fireWobble = _fireWobble();
    final fireDrift = _fireDrift();
    // Dancing: horizontal sway | Explosion: still | Glow: steady
    final flameOffsetX = fireDrift * w * 0.07 * sin(time * 3.5);
    final flameX = cx + flameOffsetX;
    // Explosion: 1.5x bigger | Dancing: normal | Glow: moderate
    final isExplosion = fireStyle.contains('explosion');
    final burstMult = isExplosion ? 1.5 : 1.0;

    // PHASE 1 (0.0-0.25): REALISTIC EXPLOSION (gradient blobs)
    if (progress < 0.35) {
      final p = progress / 0.35;
      final shockP = ((p - 0.15) / 0.35).clamp(0.0, 1.0);
      if (shockP > 0.0 && shockP < 1.0) {
        final ringR = w * 0.15 + shockP * w * 0.35;
        canvas.drawCircle(Offset(cx, cy), ringR, Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = (3.5 * (1 - shockP)).clamp(0.5, 3.5)
          ..color = Colors.white.withValues(alpha: 0.85 * (1 - shockP))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0));
      }
      if (p < 0.15) {
        final pp = p / 0.2;
        final r = w * 0.04 + pp * w * 0.04;
        canvas.drawCircle(Offset(flameX, cy), r * 6 * fireIntensity * burstMult, Paint()
          ..color = _fireColors()[0].withValues(alpha: 0.5 * pp)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));
        canvas.drawCircle(Offset(flameX, cy), r * 2.5 * fireIntensity * burstMult, Paint()
          ..color = _fireColors()[0].withValues(alpha: 0.9 * pp));
        canvas.drawCircle(Offset(flameX, cy), r * 1.2 * fireIntensity * burstMult, Paint()..color = Colors.white);
      } else if (p < 0.45) {
        final pp = (p - 0.15) / 0.30;
        final baseR = w * 0.08 + pp * w * 0.18;

        // [SMOKE REMOVED]
        // [SMOKE REMOVED]
        // [SMOKE REMOVED]
        // [SMOKE REMOVED]
        // [SMOKE REMOVED]
        // [SMOKE REMOVED]
        // [SMOKE REMOVED]
        // [SMOKE REMOVED]
        // [SMOKE REMOVED]
        // [SMOKE REMOVED]
        // [SMOKE REMOVED]
        // [SMOKE REMOVED]
        // [SMOKE REMOVED]
        // [SMOKE REMOVED]
        // [SMOKE REMOVED]
        // [SMOKE REMOVED]
        // [SMOKE REMOVED]
        // [SMOKE REMOVED]
        // [SMOKE REMOVED]
        // [SMOKE REMOVED]
        // [SMOKE REMOVED]
        // [SMOKE REMOVED]

        // LAYER 2: Deep red (gradient + highlight)
        for (int i = 0; i < 16; i++) {
          final seed = i * 0.723;
          final ang = i * 3.14159 * 2 / 16 + 0.3;
          final distMult = 0.85 + (seed % 1) * 0.4;
          final dist = baseR * distMult;
          final bx = cx + cos(ang) * dist;
          final by = cy + sin(ang) * dist * 0.9;
          final puffR = baseR * (0.42 + (seed % 1) * 0.3);
          canvas.drawCircle(Offset(bx, by), puffR, Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.3, -0.4),
              colors: [
                _fireColors()[1].withValues(alpha: 0.95),
                _fireColors()[2].withValues(alpha: 0.95),
                _fireColors()[2].withValues(alpha: 0.7),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(Rect.fromCircle(center: Offset(bx, by), radius: puffR)));
        }

        // LAYER 3: Bright red (with top highlight)
        for (int i = 0; i < 13; i++) {
          final seed = i * 0.517;
          final ang = i * 3.14159 * 2 / 13 + 0.6;
          final distMult = 0.65 + (seed % 1) * 0.35;
          final dist = baseR * distMult;
          final bx = cx + cos(ang) * dist;
          final by = cy + sin(ang) * dist * 0.88;
          final puffR = baseR * (0.4 + (seed % 1) * 0.25);
          canvas.drawCircle(Offset(bx, by), puffR, Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.4, -0.5),
              colors: [
                _fireColors()[1].withValues(alpha: 0.95),
                _fireColors()[1].withValues(alpha: 0.95),
                _fireColors()[2].withValues(alpha: 0.6),
              ],
              stops: const [0.0, 0.55, 1.0],
            ).createShader(Rect.fromCircle(center: Offset(bx, by), radius: puffR)));
        }

        // LAYER 4: Orange (gradient with glow)
        for (int i = 0; i < 11; i++) {
          final seed = i * 0.412;
          final ang = i * 3.14159 * 2 / 11 + 1.0;
          final distMult = 0.5 + (seed % 1) * 0.3;
          final dist = baseR * distMult;
          final bx = cx + cos(ang) * dist;
          final by = cy + sin(ang) * dist * 0.85;
          final puffR = baseR * (0.38 + (seed % 1) * 0.22);
          canvas.drawCircle(Offset(bx, by), puffR, Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.3, -0.4),
              colors: [
                _fireColors()[1].withValues(alpha: 0.98),
                _fireColors()[1].withValues(alpha: 0.95),
                _fireColors()[2].withValues(alpha: 0.7),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(Rect.fromCircle(center: Offset(bx, by), radius: puffR))
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1));
        }

        // LAYER 5: Yellow-orange (bright center highlight)
        for (int i = 0; i < 9; i++) {
          final seed = i * 0.318;
          final ang = i * 3.14159 * 2 / 9 + 1.4;
          final distMult = 0.35 + (seed % 1) * 0.25;
          final dist = baseR * distMult;
          final bx = cx + cos(ang) * dist;
          final by = cy + sin(ang) * dist * 0.82;
          final puffR = baseR * (0.35 + (seed % 1) * 0.2);
          canvas.drawCircle(Offset(bx, by), puffR, Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.3, -0.5),
              colors: [
                _fireColors()[0],
                _fireColors()[1],
                _fireColors()[1],
              ],
              stops: const [0.0, 0.6, 1.0],
            ).createShader(Rect.fromCircle(center: Offset(bx, by), radius: puffR)));
        }

        // LAYER 6: Bright yellow (inner core puffs)
        for (int i = 0; i < 7; i++) {
          final seed = i * 0.227;
          final ang = i * 3.14159 * 2 / 7 + 1.8;
          final distMult = 0.22 + (seed % 1) * 0.2;
          final dist = baseR * distMult;
          final bx = cx + cos(ang) * dist;
          final by = cy + sin(ang) * dist * 0.8;
          final puffR = baseR * (0.3 + (seed % 1) * 0.15);
          canvas.drawCircle(Offset(bx, by), puffR, Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.2, -0.4),
              colors: [
                _fireColors()[0],
                _fireColors()[1],
                _fireColors()[0],
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(Rect.fromCircle(center: Offset(bx, by), radius: puffR)));
        }

        // LAYER 7: White hot core (jagged + glow)
        final coreR = baseR * 0.4;
        // Outer glow
        canvas.drawCircle(Offset(cx, cy), coreR * 1.4, Paint()
          ..shader = RadialGradient(colors: [
            _fireColors()[0].withValues(alpha: 0.6),
            _fireColors()[1].withValues(alpha: 0.3),
            Colors.transparent,
          ], stops: const [0.0, 0.6, 1.0])
            .createShader(Rect.fromCircle(center: Offset(cx, cy), radius: coreR * 1.4))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
        // Jagged core
        final corePath = Path();
        for (int i = 0; i <= 16; i++) {
          final ang = i * 3.14159 * 2 / 16;
          final spike = (i % 2 == 0) ? 1.0 : 0.7;
          final jitter = ((i * 7) % 10) / 100.0;
          final r = coreR * (spike + jitter);
          final x = cx + cos(ang) * r;
          final y = cy + sin(ang) * r;
          if (i == 0) { corePath.moveTo(x, y); } else { corePath.lineTo(x, y); }
        }
        corePath.close();
        canvas.drawPath(corePath, Paint()
          ..shader = RadialGradient(colors: [
            Colors.white,
            _fireColors()[0],
            _fireColors()[1].withValues(alpha: 0.8),
            Colors.transparent,
          ], stops: const [0.0, 0.4, 0.75, 1.0])
            .createShader(Rect.fromCircle(center: Offset(cx, cy), radius: coreR))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
        canvas.drawCircle(Offset(cx, cy), coreR * 0.5, Paint()..color = Colors.white);

        // LAYER 8: Sparks with glow
        for (int i = 0; i < 45; i++) {
          final seed = rng.nextDouble();
          final ang = rng.nextDouble() * 6.28;
          final dist = baseR * (0.9 + rng.nextDouble() * 1.0);
          final sx = cx + cos(ang) * dist;
          final sy = cy + sin(ang) * dist * 0.85;
          final ss = 1.5 + rng.nextDouble() * 3;
          final sa = (1 - pp * 0.5) * 0.95;
          canvas.drawCircle(Offset(sx, sy), ss * 2.5, Paint()
            ..color = _fireColors()[1].withValues(alpha: sa * 0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
          canvas.drawCircle(Offset(sx, sy), ss, Paint()
            ..shader = RadialGradient(colors: [
              Colors.white,
              _fireColors()[0],
              _fireColors()[1].withValues(alpha: 0.6),
            ]).createShader(Rect.fromCircle(center: Offset(sx, sy), radius: ss)));
        }
      } else {
        final pp = (p - 0.35) / 0.65;
        final baseR = w * 0.26 + pp * w * 0.08;
        final fade = 1 - pp * 0.6;
        // Dissolving smoke (gradient)
        for (int i = 0; i < 18; i++) {
          final seed = i * 0.71;
          final ang = i * 3.14159 * 2 / 18;
          final dist = baseR * (1.0 + (seed % 1) * 0.4);
          final bx = cx + cos(ang) * dist;
          final by = cy + sin(ang) * dist * 0.9;
          final puffR = baseR * (0.5 + (seed % 1) * 0.3) * (1 + pp * 0.3);
          canvas.drawCircle(Offset(bx, by), puffR, Paint()
            ..shader = RadialGradient(
              center: const Alignment(0.0, 0.3),
              colors: [
                const Color(0xFF4A4A4A).withValues(alpha: 0.75 * fade),
                const Color(0xFF1A1A1A).withValues(alpha: 0.6 * fade),
                Colors.transparent,
              ],
            ).createShader(Rect.fromCircle(center: Offset(bx, by), radius: puffR))
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
        }
        // Fading red
        for (int i = 0; i < 12; i++) {
          final seed = i * 0.53;
          final ang = i * 3.14159 * 2 / 12 + 0.3;
          final dist = baseR * (0.7 + (seed % 1) * 0.35);
          final bx = cx + cos(ang) * dist;
          final by = cy + sin(ang) * dist * 0.88;
          canvas.drawCircle(Offset(bx, by), baseR * 0.45, Paint()
            ..shader = RadialGradient(colors: [
              _fireColors()[2].withValues(alpha: 0.85 * fade),
              _fireColors()[2].withValues(alpha: 0.6 * fade),
            ]).createShader(Rect.fromCircle(center: Offset(bx, by), radius: baseR * 0.45)));
        }
        // Fading orange
        for (int i = 0; i < 9; i++) {
          final seed = i * 0.41;
          final ang = i * 3.14159 * 2 / 9 + 0.7;
          final dist = baseR * (0.45 + (seed % 1) * 0.3);
          final bx = cx + cos(ang) * dist;
          final by = cy + sin(ang) * dist * 0.85;
          canvas.drawCircle(Offset(bx, by), baseR * 0.4, Paint()
            ..shader = RadialGradient(colors: [
              _fireColors()[1].withValues(alpha: 0.8 * fade),
              _fireColors()[1].withValues(alpha: 0.6 * fade),
            ]).createShader(Rect.fromCircle(center: Offset(bx, by), radius: baseR * 0.4)));
        }
      }
    }
    // PHASE 2 (0.35-0.80): SUSTAINED RISING FIRE
    if (progress >= 0.15 && progress < 1.0) {
      final p = (progress - 0.15) / 0.85;
      final fadeIn = p < 0.25 ? p / 0.25 : 1.0;
      final fadeOut = p > 0.75 ? (1 - p) / 0.25 : 1.0;
      final intensity = fadeIn * fadeOut;
      final baseY = h * 0.90;
      final maxHeight = h * 0.75;
      _drawRealFlame(canvas, cx, baseY, w * 0.34, maxHeight * 1.25 * intensity, intensity, rng, time);
      _drawRealFlame(canvas, cx - w * 0.22, baseY, w * 0.20, maxHeight * 0.95 * intensity, intensity * 0.9, rng, time + 1.3);
      _drawRealFlame(canvas, cx + w * 0.22, baseY, w * 0.20, maxHeight * 0.95 * intensity, intensity * 0.9, rng, time + 2.7);
      _drawRealFlame(canvas, cx - w * 0.36, baseY, w * 0.14, maxHeight * 0.70 * intensity, intensity * 0.7, rng, time + 4.1);
      _drawRealFlame(canvas, cx + w * 0.36, baseY, w * 0.14, maxHeight * 0.70 * intensity, intensity * 0.7, rng, time + 5.5);
      for (int i = 0; i < 25; i++) {
        final seed = rng.nextDouble();
        final ex = cx + (rng.nextDouble() - 0.5) * w * 0.7;
        final prog = ((time * 1.5 + seed) % 1.0);
        final ey = baseY - prog * maxHeight;
        final es = 1.5 + (1 - prog) * 2.5;
        final ea = (1 - prog) * intensity;
        canvas.drawCircle(Offset(ex, ey), es * 2.5, Paint()
          ..color = _fireColors()[1].withValues(alpha: ea * 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
        canvas.drawCircle(Offset(ex, ey), es, Paint()
          ..color = _fireColors()[0].withValues(alpha: ea));
        if (es > 2.5) {
          canvas.drawCircle(Offset(ex, ey), es * 0.4, Paint()
            ..color = Colors.white.withValues(alpha: ea * 0.9));
        }
      }
      canvas.drawCircle(Offset(cx, baseY), w * 0.28, Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFF6B00).withValues(alpha: 0.8 * intensity),
          _fireColors()[1].withValues(alpha: 0.4 * intensity),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(center: Offset(cx, baseY), radius: w * 0.28))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));
    }
  }
  void _paintFoam(Canvas canvas, double w, double h) {
    // FOAM GATE: no foam during pour Ã¢â‚¬â€ appears after pour completes
    if (item.pourAnim > 0.0) return;
    if (reaction == null || !reaction!.foam) return;
    final progress = item.reactionProgress; // Full progress (no ramp)
    final t = time;
    final cx = w * 0.5;
    final surfaceY = _liquidTop(h);
    final mouthY = h * 0.10;
    final benchY = h * 1.05;
    final beakerPath = _buildPath(w, h);
    final insideHeight = surfaceY - mouthY;
    
    // AUTO WIDTH Ã¢â‚¬â€ foam width matches equipment mouth
    double mouthW;
    switch (item.shape) {
      case EquipShape.beaker: mouthW = 0.83; break;
      case EquipShape.flask: mouthW = 0.20; break;
      case EquipShape.testTube: mouthW = 0.60; break;
      case EquipShape.cylinder: mouthW = 0.40; break;
      default: mouthW = 0.60;
    }
    // AUTO WIDTH Ã¢â‚¬â€ top width limit
    double topWFactor;
    switch (item.shape) {
      case EquipShape.beaker: topWFactor = 1.15; break; // Slight widen
      case EquipShape.flask: topWFactor = 2.2; break; // Moderate expand
      case EquipShape.testTube: topWFactor = 1.8; break;
      case EquipShape.cylinder: topWFactor = 1.5; break;
      default: topWFactor = 1.5;
    }
    
    final darkGreen = const Color(0xFF558B2F);
    final midGreen = const Color(0xFF9CCC65);
    final lightGreen = const Color(0xFFDCEDC8);
    final foamWhite = const Color(0xFFF1F8E9);
    
    // Draw a wavy blob path (single cloud shape, no circles)
    Path wavyBlob(double bx, double by, double bw, double bh, double seed) {
      final path = Path();
      final brng = Random(seed.toInt());
      final points = 20;
      final pts = <Offset>[];
      // Generate points around ellipse with wobble
      for (int i = 0; i < points; i++) {
        final ang = i * 3.14159 * 2 / points;
        final wobble = 0.75 + brng.nextDouble() * 0.4;
        final px = bx + cos(ang) * bw * 0.5 * wobble;
        final py = by + sin(ang) * bh * 0.5 * wobble;
        pts.add(Offset(px, py));
      }
      // Draw smooth curve through points
      path.moveTo(pts[0].dx, pts[0].dy);
      for (int i = 0; i < points; i++) {
        final p1 = pts[i];
        final p2 = pts[(i + 1) % points];
        final midX = (p1.dx + p2.dx) / 2;
        final midY = (p1.dy + p2.dy) / 2;
        path.quadraticBezierTo(p1.dx, p1.dy, midX, midY);
      }
      path.close();
      return path;
    }
    
    // Draw wavy foam blob with gradient
    void drawWavyBlob(double bx, double by, double bw, double bh, double seed, double alpha) {
      final path = wavyBlob(bx, by, bw, bh, seed);
      // Main fill
      canvas.drawPath(path, Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lightGreen.withValues(alpha: alpha),
            midGreen.withValues(alpha: alpha),
            darkGreen.withValues(alpha: 0.85 * alpha),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(bx - bw * 0.6, by - bh * 0.6, bw * 1.2, bh * 1.2)));
      // Soft inner white (top highlight)
      canvas.drawPath(path, Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.0, -0.6),
          radius: 1.0,
          colors: [
            Colors.white.withValues(alpha: 0.5 * alpha),
            foamWhite.withValues(alpha: 0.2 * alpha),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(bx - bw * 0.6, by - bh * 0.6, bw * 1.2, bh * 1.2)));
    }
    
    final boostedProgress = (progress * 2.5).clamp(0.0, 1.0); // Faster fill
    final totalFoamHeight = h * 2.10 * boostedProgress * item.foamRamp; // Smooth rise
    final insideFoamH = totalFoamHeight.clamp(0.0, insideHeight);
    final overflowH = (totalFoamHeight - insideHeight * 0.75).clamp(0.0, h * 0.85);
    
    // ============ INSIDE FOAM (clipped, wavy blobs stacked) ============
    canvas.save();
    canvas.clipPath(beakerPath);
    
    if (insideFoamH > 3) {
      final layers = (insideFoamH / (h * 0.018)).round().clamp(12, 110); // Fuller rows
      for (int r = 0; r < layers; r++) {
        final rowP = r / (layers - 1).toDouble().clamp(1.0, 100.0);
        final rowY = surfaceY - rowP * insideFoamH;
        
        double widthFactor = 1.0;
        if (rowP > 0.90) widthFactor = 1.0 - (rowP - 0.90) * 2.0; // Minimal narrowing
        widthFactor = widthFactor.clamp(0.4, 1.0);
        
        // Equipment profile at this height Ã¢â‚¬â€ flask: body wide, neck narrow
        double localW;
        if (item.shape == EquipShape.flask && rowP < 0.90) {
          if (rowP < 0.35) { // Body stays wide longer
            localW = 0.84; // Flask body
          } else {
            final t = (rowP - 0.35) / 0.55; // Wider transition
            final s = t * t * (3 - 2 * t); // smoothstep
            localW = 0.84 + (0.20 - 0.84) * s;
          }
        } else {
          localW = mouthW;
        }
        final blobW = w * localW * widthFactor * (0.35 + 0.65 * item.foamRamp); // Bubble grow
        final blobH = h * 0.24; // Balanced
        // Wobble animation
        final wobbleY = sin(t * 1.5 + r * 0.5) * h * 0.005;
        drawWavyBlob(cx, rowY + wobbleY, blobW, blobH, (100 + r).toDouble(), 0.95);
      }
      // Rising bubbles REMOVED (were appearing outside flask)
      // for (int i = 0; i < 6; i++) {
      // final seed = i * 0.37 + 0.15;
      // final bx = 15 + ((seed * 7.3) % 1) * (w - 30);
      // final speed = 0.3 + (seed * 3.7 % 1) * 0.3;
      // final bp = ((t * speed + seed) % 1.0);
      // final by = surfaceY - bp * insideFoamH;
      // final br = 1.5 + (1 - bp) * 2.5;
      // canvas.drawCircle(Offset(bx, by), br, Paint()
      // ..color = Colors.white.withValues(alpha: 0.5));
      // }
    }
    canvas.restore();
    
    // ============ OVERFLOW (wavy column + mushroom cloud) ============
    if (overflowH > 5) {
      final overflowTopY = mouthY - overflowH;
      final layers = (overflowH / (h * 0.016)).round().clamp(12, 90); // Smoother rows
      
      for (int r = 0; r < layers; r++) {
        final rowP = r / (layers - 1).toDouble().clamp(1.0, 100.0);
        final rowY = mouthY - rowP * overflowH;
        
        double widthFactor;
        // CONTINUOUS WIDTH Ã¢â‚¬â€ 0.85 (minor) Ã¢â€ â€™ 1.25 (wider)
        // HOLD neck width first 25%, then smoothstep expand
        final p = rowP < 0.40 ? 0.0 : (rowP - 0.40) / 0.60; // Longer neck hold
        final ss = p * p * (3 - 2 * p); // smoothstep (no jump)
        widthFactor = 1.0 + ss * (topWFactor - 1.0);
        widthFactor = widthFactor.clamp(1.0, topWFactor).toDouble(); // Equipment-specific
        
        final blobW = w * mouthW * widthFactor * (0.35 + 0.65 * item.foamRamp); // Bubble grow
        final blobH = h * 0.20; // FIXED Ã¢â‚¬â€ no jump as width grows
        final wobbleY = sin(t * 1.2 + r * 0.4) * h * 0.008;
        drawWavyBlob(cx, rowY + wobbleY, blobW, blobH, (500 + r).toDouble(), 0.96);
      }
      
    }
    // ============ DRIPS ============
    if (overflowH > h * 0.05) {
      final dripIntensity = (overflowH / h * 2).clamp(0.0, 1.0);
      // AUTO EDGE Ã¢â‚¬â€ drops fall from foam column edges (equipment width)
      final dripHalfW = w * mouthW * 0.5 + w * 0.02;
      final leftEdgeX = cx - dripHalfW;
      final rightEdgeX = cx + dripHalfW;
      
      // Flask: drops slide along outer contour | Beaker: vertical
      double dripX(double y, double sgn) {
        if (item.shape != EquipShape.flask) {
          return cx + sgn * dripHalfW;
        }
        final yFrac = ((y - mouthY) / (benchY - mouthY)).clamp(0.0, 1.0);
        double halfW;
        if (yFrac < 0.20) {
          halfW = w * 0.10; // Neck (narrow)
        } else if (yFrac > 0.65) {
          halfW = w * 0.44; // Body (wide)
        } else {
          final tt = (yFrac - 0.20) / 0.45;
          final ss = tt * tt * (3 - 2 * tt);
          halfW = w * (0.10 + (0.44 - 0.10) * ss);
        }
        return cx + sgn * halfW;
      }
      
      for (int i = 0; i < 8; i++) {
        final side = (i < 4) ? -1.0 : 1.0;
        final edgeX = (i < 4) ? leftEdgeX : rightEdgeX;
        final staggerSeed = (i % 4) * 0.25;
        final dripProg = ((t * 0.4 + staggerSeed) % 1.0);
        final dripY = mouthY + dripProg * (benchY - mouthY - h * 0.08);
        final dropSize = (5 + sin(dripProg * 3.14159) * 3) * dripIntensity;
        
        // Trail wavy blobs
        for (int trail = 1; trail <= 3; trail++) {
          final trailProg = dripProg - trail * 0.09;
          if (trailProg > 0) {
            final trailY = mouthY + trailProg * (benchY - mouthY - h * 0.08);
            final trailR = dropSize * (0.8 - trail * 0.18);
            if (trailR > 2) {
              drawWavyBlob(dripX(trailY, side), trailY, trailR * 2, trailR * 1.6, (i * 900 + trail).toDouble(), dripIntensity * (0.6 - trail * 0.12));
            }
          }
        }
        
        if (dropSize > 2) {
          canvas.save();
          canvas.translate(dripX(dripY, side), dripY);
          canvas.scale(1.0, 1.0 + dripProg * 0.6);
          drawWavyBlob(0, 0, dropSize * 2.2, dropSize * 1.8, (i * 100).toDouble(), dripIntensity);
          canvas.restore();
        }
      }
      
      // Foam pile at base
      for (int i = 0; i < 8; i++) {
        final brng = Random(i * 9973 + 41);
        final side = (i % 2 == 0) ? -1.0 : 1.0;
        final baseX = (side < 0) ? w * 0.08 : w * 0.92;
        final pileX = baseX + (brng.nextDouble() - 0.5) * w * 0.08;
        final pileY = benchY - h * 0.02 - brng.nextDouble() * h * 0.04;
        final pileR = w * (0.06 + brng.nextDouble() * 0.05) * (overflowH / (h * 0.5)).clamp(0.0, 1.0);
        if (pileR > 2) {
          drawWavyBlob(pileX, pileY, pileR * 2.5, pileR * 1.8, (i * 200).toDouble(), 0.92);
        }
      }
    }
    
    // ============ BENCH PUDDLE ============
    if (overflowH > h * 0.05) {
      final puddleP = ((overflowH - h * 0.05) / (h * 0.45)).clamp(0.0, 1.0);
      final leftEdge = w * 0.05;
      final rightEdge = w * 0.95;
      
      for (int i = 0; i < 12; i++) {
        final brng = Random(i * 7919 + 13);
        final relPos = brng.nextDouble();
        final bx = leftEdge + relPos * (rightEdge - leftEdge);
        final by = benchY - brng.nextDouble() * h * 0.02;
        final edgeDist = (relPos - 0.5).abs() * 2;
        final edgeFactor = (1.0 - edgeDist * 0.55).clamp(0.4, 1.0);
        final br = w * (0.10 + brng.nextDouble() * 0.08) * puddleP * edgeFactor;
        if (br > 2) {
          drawWavyBlob(bx, by, br * 2.5, br * 1.5, (i * 500).toDouble(), 0.9);
        }
      }
    }
  }
















  void _drawRealFlame(Canvas canvas, double baseX, double baseY, double baseW, double height, double intensity, Random rng, double t) {
    if (intensity <= 0.01 || height <= 1) return;
    for (int layer = 0; layer < 4; layer++) {
      final layerH = height * (1 - layer * 0.18);
      final layerW = baseW * (1 - layer * 0.15);
      final alpha = (0.85 - layer * 0.15) * intensity;
      final color = layer == 0
          ? const Color(0xFFD32F2F)
          : layer == 1
              ? const Color(0xFFFF6B00)
              : layer == 2
                  ? _fireColors()[0]
                  : Colors.white;
      final wobble1 = sin(t * 5 + layer * 1.3) * baseW * 0.4;
      final wobble2 = cos(t * 6.5 + layer * 2.1) * baseW * 0.25;
      final path = Path();
      path.moveTo(baseX - layerW, baseY);
      path.quadraticBezierTo(
        baseX - layerW * 0.8 + wobble1,
        baseY - layerH * 0.4,
        baseX - layerW * 0.3 + wobble2,
        baseY - layerH * 0.7,
      );
      path.quadraticBezierTo(
        baseX + wobble1,
        baseY - layerH * 1.05,
        baseX + layerW * 0.15 + wobble2,
        baseY - layerH * 0.95,
      );
      path.quadraticBezierTo(
        baseX + layerW * 0.8 + wobble1,
        baseY - layerH * 0.4,
        baseX + layerW,
        baseY,
      );
      path.close();
      canvas.drawPath(path, Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            color.withValues(alpha: alpha),
            color.withValues(alpha: alpha * 0.5),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(baseX - layerW, baseY - layerH, layerW * 2, layerH))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5));
    }
  }

  void _paintGasEvolution(Canvas canvas, double w, double h) {
    if (reaction == null || reaction!.gasEvolution == null) return;
    final top = _liquidTop(h);
    final rng = Random(23);
    for (int i = 0; i < 10; i++) {
      final bx = rng.nextDouble() * w;
      final speed = 0.4 + rng.nextDouble() * 0.5;
      final progress = (time * speed + rng.nextDouble()) % 1.0;
      final by = h - progress * h * 1.2;
      if (by > top + 5) continue;
      final r = 2 + rng.nextDouble() * 3.5;
      canvas.drawCircle(Offset(bx, by), r,
        Paint()..color = _gasColor(reaction!.gasEvolution).withValues(alpha: 0.7 * (1 - progress)));
      canvas.drawCircle(Offset(bx, by), r,
        Paint()..style = PaintingStyle.stroke..strokeWidth = 0.8
          ..color = _gasColor(reaction!.gasEvolution).withValues(alpha: 0.95 * (1 - progress)));
    }
  }

  void _paintSmoke(Canvas canvas, double w, double h) {
    if (reaction == null || !reaction!.producesSmoke) return;
    final rng = Random(31);
    for (int i = 0; i < 6; i++) {
      final bx = w * 0.4 + rng.nextDouble() * w * 0.2;
      final progress = (time * 0.35 + rng.nextDouble()) % 1.0;
      final by = -20 - progress * h * 0.6;
      final r = 6 + progress * 20;
      canvas.drawCircle(Offset(bx, by), r,
        Paint()
          ..color = _gasColor(reaction?.gasEvolution).withValues(alpha: (1 - progress) * 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    }
  }
  void _paintHeatingEffect(Canvas canvas, double w, double h) {
    final he = item.activeHeatingEffect;
    if (he == null) return;
    final top = _liquidTop(h);
    final rng = Random(37);

    if (he.bubbles) {
      for (int i = 0; i < 14; i++) {
        final bx = rng.nextDouble() * w;
        final speed = 0.5 + rng.nextDouble() * 0.6;
        final progress = (time * speed + rng.nextDouble()) % 1.0;
        final by = h - progress * (h - top);
        final r = 2 + rng.nextDouble() * 3.5;
        canvas.drawCircle(Offset(bx, by), r,
          Paint()..color = Colors.white.withValues(alpha: 0.55 * (1 - progress * 0.5)));
        canvas.drawCircle(Offset(bx, by), r,
          Paint()..style = PaintingStyle.stroke..strokeWidth = 0.7
            ..color = Colors.white.withValues(alpha: 0.85 * (1 - progress * 0.5)));
      }
    }

    if (he.smoke || he.brownFumes) {
      final smokeCol = he.brownFumes ? const Color(0xFF8D6E63) : Colors.white;
      for (int i = 0; i < 8; i++) {
        final bx = w * 0.35 + rng.nextDouble() * w * 0.3;
        final progress = (time * 0.4 + rng.nextDouble()) % 1.0;
        final by = -10 - progress * h * 0.8;
        final r = 5 + progress * 22;
        canvas.drawCircle(Offset(bx, by), r,
          Paint()
            ..color = smokeCol.withValues(alpha: (1 - progress) * 0.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      }
    }
  }
  void _paintThermometer(Canvas canvas, double w, double h) {
    final tx = w * 0.98;
    final ty = h * 0.30;
    const tw = 6.0;
    final th = h * 0.55;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tx, ty, tw, th),
        const Radius.circular(5)),
      Paint()..color = LC.glassEdge.withValues(alpha: 0.8));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tx, ty, tw, th),
        const Radius.circular(5)),
      Paint()
        ..color = const Color(0xFF37474F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2);

    final level = ((item.temperature - 0) / 150).clamp(0.05, 1.0);
    final mercuryH = th * 0.78 * level;
    final mercuryColor = item.temperature >= 60
        ? _fireColors()[2]
        : item.temperature <= 10
            ? const Color(0xFF1E88E5)
            : const Color(0xFFB85450);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tx + 2, ty + th - mercuryH - 1, tw - 4, mercuryH),
        const Radius.circular(2)),
      Paint()..color = mercuryColor);

    canvas.drawCircle(Offset(tx + tw / 2, ty + th + 6), 7,
      Paint()..color = mercuryColor);
    canvas.drawCircle(Offset(tx + tw / 2, ty + th + 6), 7,
      Paint()
        ..color = const Color(0xFF37474F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);

    for (int i = 0; i < 6; i++) {
      final y = ty + th * 0.1 + (th * 0.78 * i / 5);
      final isMajor = i == 0 || i == 5;
      canvas.drawLine(
        Offset(tx - (isMajor ? 5 : 3), y),
        Offset(tx, y),
        Paint()
          ..color = const Color(0xFF37474F).withValues(alpha: 0.8)
          ..strokeWidth = isMajor ? 1.2 : 0.7);
    }

    final tempTp = TextPainter(
      text: TextSpan(
        text: '${item.temperature.toInt()}Ã‚Â°C',
        style: const TextStyle(
          fontSize: 10, color: Colors.white,
          fontWeight: FontWeight.w800, letterSpacing: 0.3)),
      textDirection: TextDirection.ltr,
    )..layout();
    final pillW = tempTp.width + 8;
    final pillH = tempTp.height + 4;
    final pillX = tx + tw / 2 - pillW / 2;
    final pillY = ty - pillH - 4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pillX, pillY, pillW, pillH),
        const Radius.circular(4)),
      Paint()..color = item.temperature >= 60
          ? _fireColors()[2]
          : item.temperature <= 10
              ? const Color(0xFF1E88E5)
              : const Color(0xFF37474F));
    tempTp.paint(canvas, Offset(pillX + 4, pillY + 2));
  }

  void _paintDropper(Canvas canvas, double w, double h) {
    final dx = w * 0.10;
    final dy = h * 0.20;

    canvas.drawCircle(Offset(dx, dy), 11,
      Paint()..color = const Color(0xFF6B7280));
    canvas.drawCircle(Offset(dx, dy), 11,
      Paint()
        ..color = const Color(0xFF37474F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(dx - 4, dy + 11, 8, h * 0.28),
        const Radius.circular(2)),
      Paint()..color = LC.glassEdge);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(dx - 4, dy + 11, 8, h * 0.28),
        const Radius.circular(2)),
      Paint()
        ..color = const Color(0xFF37474F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(dx - 2, dy + 12, 4, h * 0.14),
        const Radius.circular(1)),
      Paint()..color = const Color(0xFF8B7BA8).withValues(alpha: 0.8));

    final dropP = (time * 0.7) % 1.0;
    final dropY = dy + h * 0.30 + dropP * h * 0.25;
    canvas.drawCircle(Offset(dx, dropY),
      2.5 - dropP * 1.5,
      Paint()..color = const Color(0xFF8B7BA8).withValues(alpha: 1 - dropP));
  }

  void _paintPour(Canvas canvas, double w, double h) {
    if (item.pourAnim <= 0) return;
    final p = item.pourAnim;
    final cx = w * 0.5;

    double bottleX, bottleY, tilt;
    // Bottle floats ABOVE equipment Ã¢â‚¬â€ stream visible from mouth to surface
    const bottleAbove = 55.0; // Bottle sits ~55px above equipment mouth
    final pourTargetX = cx - 18.5; // Bottle shifted left so MOUTH lands at center
    final pourTargetY = -bottleAbove;
    
    if (p > 0.85) {
      final t = (1.0 - p) / 0.15;
      bottleX = pourTargetX + 50 * (1 - t); // Fly-in from further right
      bottleY = pourTargetY - 20 * (1 - t); // Fly-in from higher
      tilt = 1.0 * t;
    } else if (p > 0.20) {
      bottleX = pourTargetX;
      bottleY = pourTargetY;
      tilt = 1.0;
    } else {
      final t = p / 0.20;
      bottleX = pourTargetX + 50 * (1 - t);
      bottleY = pourTargetY - 20 * (1 - t);
      tilt = 1.0 * t;
    }
    
    final wobble = (p > 0.20 && p < 0.85) ? sin(time * 6) * 0.028 : 0.0;
    final aTilt = tilt + wobble;

    const mouthDist = 22.0; // Visible tilt offset
    final mouthX = bottleX + sin(aTilt) * mouthDist;
    final mouthY = bottleY + cos(aTilt) * mouthDist;

    final surfaceY = _liquidTop(h);
    final col = item.pourColor.a == 0
        ? const Color(0xFF9CB9D0) : item.pourColor;
    final sa = (p > 0.85 ? (1.0 - p) / 0.15 : (p < 0.20 ? p / 0.20 : 1.0))
        .clamp(0.0, 1.0);

    if (aTilt > 0.35 && sa > 0.05) {
      if (item.pourIsLiquid) {
        final dy = surfaceY - mouthY; // Full stream to liquid surface
        final streamPath = Path()..moveTo(mouthX, mouthY);
        for (double t = 0.0; t <= 1.0; t += 0.04) {
          final px = mouthX + t * 2 + sin(t * 6 + time * 7) * 1.0; // Straighter Ã¢â‚¬â€ stays in tube
          final py = mouthY + t * t * dy;
          streamPath.lineTo(px, py);
        }
        canvas.drawPath(streamPath, Paint()
          ..color = col.withValues(alpha: 0.45 * sa)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round);
        canvas.drawPath(streamPath, Paint()
          ..color = col.withValues(alpha: 0.95 * sa)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round);
        canvas.drawPath(streamPath, Paint()
          ..color = Colors.white.withValues(alpha: 0.4 * sa)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9
          ..strokeCap = StrokeCap.round);

        final impactX = mouthX + 2 + sin(6 + time * 7) * 1.0; // Aligned with stream

        final rng = Random(7);
        for (int i = 0; i < 12; i++) {
          final s = rng.nextDouble();
          final spread = (s - 0.5) * 38;
          final rise = sin(s * pi) * 18 * sa;
          canvas.drawCircle(
            Offset(impactX + spread, surfaceY - rise),
            1.4 + s * 2.5,
            Paint()..color = col.withValues(alpha: 0.85 * sa));
          canvas.drawCircle(
            Offset(impactX + spread * 0.9, surfaceY - rise * 0.55),
            0.7 + s * 1.2,
            Paint()..color = col.withValues(alpha: 0.4 * sa));
        }

        for (int r = 0; r < 3; r++) {
          final rp = ((1.0 - p) * 1.6 + r * 0.33) % 1.0;
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(impactX, surfaceY),
              width: 12 + rp * 70,
              height: 4 + rp * 22),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.2 * (1 - rp)
              ..color = Colors.white.withValues(alpha: (1 - rp) * 0.7 * sa));
        }

        for (int i = 0; i < 10; i++) {
          final s = ((i * 0.41 + p * 2.5) % 1.0);
          final fx = impactX + (s - 0.5) * 44;
          final fy = surfaceY - (1 - (i % 3) * 0.3) - s * 3;
          canvas.drawCircle(
            Offset(fx, fy),
            1.3 + s * 2.2,
            Paint()..color = Colors.white.withValues(alpha: 0.6 * sa));
        }
      } else {
        final rng = Random(11);
        final totalFall = surfaceY - mouthY;
        for (int i = 0; i < 26; i++) {
          final s = rng.nextDouble();
          final t = ((p * 2.8 + s * 1.6) % 1.0);
          final py = mouthY + (0.12 * t + 0.88 * t * t) * totalFall;
          final px = mouthX + (s - 0.5) * 18 + t * t * 8;
          final rad = 1.0 + rng.nextDouble() * 1.4 + t * 0.7;
          canvas.drawCircle(Offset(px, py), rad,
            Paint()..color = col.withValues(alpha: 0.92 * sa));
          canvas.drawCircle(
            Offset(px - rad * 0.3, py - rad * 0.3), rad * 0.35,
            Paint()..color = Colors.white.withValues(alpha: 0.6 * sa));
        }
        final prng = Random(21);
        for (int i = 0; i < 8; i++) {
          final px = mouthX + (prng.nextDouble() - 0.5) * 24;
          final py = surfaceY - prng.nextDouble() * 6;
          canvas.drawCircle(Offset(px, py),
            1.2 + prng.nextDouble() * 1.4,
            Paint()..color = col.withValues(alpha: 0.9 * sa));
        }
      }
    }

    canvas.save();
    canvas.translate(bottleX + 2.5, bottleY + 3);
    canvas.rotate(aTilt);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 24, height: 38),
        const Radius.circular(3)),
      Paint()..color = Colors.black.withValues(alpha: 0.28));
    canvas.restore();

    canvas.save();
    canvas.translate(bottleX, bottleY);
    canvas.rotate(aTilt);

    const bw = 24.0;
    const bh = 38.0;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: bw, height: bh),
      const Radius.circular(3));

    canvas.drawRRect(bodyRect, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          col.withValues(alpha: 0.55),
          col.withValues(alpha: 0.9),
          col.withValues(alpha: 0.75),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(bodyRect.outerRect));

    canvas.save();
    canvas.clipRRect(bodyRect);
    canvas.drawRect(
      Rect.fromLTWH(-bw * 0.7, -bh * 0.05, bw * 1.4, bh * 0.8),
      Paint()..color = col.withValues(alpha: 0.95));
    canvas.restore();

    canvas.drawRect(
      Rect.fromLTWH(-bw * 0.42, -bh * 0.42, bw * 0.1, bh * 0.78),
      Paint()..color = Colors.white.withValues(alpha: 0.55));
    canvas.drawRect(
      Rect.fromLTWH(-bw * 0.40, -bh * 0.42, bw * 0.04, bh * 0.78),
      Paint()..color = LC.glassEdge);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: bw * 0.8, height: bh * 0.35),
        const Radius.circular(1.5)),
      Paint()..color = LC.glassEdge);
    canvas.drawRect(
      Rect.fromCenter(center: const Offset(0, -2.5), width: bw * 0.58, height: 1.2),
      Paint()..color = col.withValues(alpha: 0.75));
    canvas.drawRect(
      Rect.fromCenter(center: const Offset(0, 2.5), width: bw * 0.48, height: 1.2),
      Paint()..color = col.withValues(alpha: 0.55));

    canvas.drawRect(
      Rect.fromCenter(center: const Offset(0, -bh * 0.62),
        width: bw * 0.32, height: bh * 0.26),
      Paint()..color = col.withValues(alpha: 0.75));
    canvas.drawRect(
      Rect.fromLTWH(-bw * 0.14, -bh * 0.72, bw * 0.05, bh * 0.22),
      Paint()..color = Colors.white.withValues(alpha: 0.55));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, -bh * 0.85),
          width: bw * 0.4, height: bh * 0.16),
        const Radius.circular(1.5)),
      Paint()..color = const Color(0xFF8B6A3F));
    canvas.drawRect(
      Rect.fromLTWH(-bw * 0.16, -bh * 0.88, bw * 0.04, bh * 0.06),
      Paint()..color = const Color(0xFFA98556));

    canvas.restore();

    if (aTilt > 0.35 && sa > 0.05) {
      canvas.drawCircle(Offset(mouthX, mouthY), 3.5,
        Paint()..color = col.withValues(alpha: 0.95 * sa));
      canvas.drawCircle(Offset(mouthX, mouthY), 1.5,
        Paint()..color = Colors.white.withValues(alpha: 0.7 * sa));
    }
  }
  void _paintSolidPile(Canvas canvas, double w, double h) {
    // PRODUCT RESIDUE Ã¢â‚¬â€ decomposition reactions leave solid product
    if (item.reactionComplete && reaction != null && reaction!.type == 'Decomposition') {
      final products = reaction!.products.join(' ').toLowerCase();
      Color productCol = const Color(0xFFBDBDBD); // default gray
      if (products.contains('cao')) { productCol = const Color(0xFFF5F5F0); } // CaO white
      if (products.contains('na2co3')) { productCol = const Color(0xFFFAFAF5); } // Na2CO3 white
      if (products.contains('kno2')) { productCol = const Color(0xFFF5F5E8); } // KNO2 pale
      if (products.contains('ag')) { productCol = const Color(0xFFD0D0D0); } // Ag silver
      final beakerBottom = h * 0.95; // where beaker bottom sits
      final beakerTop = h * 0.12; // where liquid starts
      final usableH = beakerBottom - beakerTop;
      final ph = usableH * 0.85; // 85% of usable Ã¢â‚¬â€ ~50ml+ residue
      // final ptY = beakerBottom - ph;
      // (old ptY below)
      final ptY = beakerBottom - ph; // top of residue
      // Surface: WAVE during heating, FLAT when complete
      if (item.reactionComplete) {
        // FLAT Ã¢â‚¬â€ reaction done, solid residue
        canvas.drawLine(Offset(0, ptY + 2), Offset(w, ptY + 2), Paint()
          ..strokeWidth = 2.0
          ..color = Colors.white.withValues(alpha: 0.7));
      } else {
        // WAVY Ã¢â‚¬â€ still reacting (fire below)
        final wavePath = Path()..moveTo(0, ptY + 2);
        final waveAmp = 3.0 + sin(time * 2) * 1.5;
        final waveFreq = 6.0;
        for (double x = 0; x <= w; x += 4) {
          final y = ptY + 2 + sin(x / w * waveFreq + time * 3) * waveAmp;
          wavePath.lineTo(x, y);
        }
        canvas.drawPath(wavePath, Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..color = Colors.white.withValues(alpha: 0.75));
        // Bubble shimmer on wave
        for (int b = 0; b < 5; b++) {
          final bx = (b * 17.0 + time * 8) % w;
          final by = ptY + 2 + sin(bx / w * waveFreq + time * 3) * waveAmp - 2;
          canvas.drawCircle(Offset(bx, by), 1.5, Paint()
            ..color = productCol.withValues(alpha: 0.85));
        }
      }
      // Base solid bed Ã¢â‚¬â€ gives structure to residue
      final bedRect = Rect.fromLTWH(0, ptY, w, h - ptY); // full to bottom
      canvas.drawRect(bedRect, Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [
            productCol.withValues(alpha: 0.55),
            productCol.withValues(alpha: 0.85),
            productCol.withValues(alpha: 0.95),
          ], stops: const [0.0, 0.5, 1.0]
        ).createShader(bedRect));
      final prng = Random(item.id.length * 19 + 53);
      for (int i = 0; i < 30; i++) {
        final px = prng.nextDouble() * w;
        final py = beakerBottom - prng.nextDouble() * ph; // above beaker bottom
        final r = 1.8 + prng.nextDouble() * 2.7; // bigger particles
        canvas.drawCircle(Offset(px, py), r, Paint()..color = productCol.withValues(alpha: 0.85));
        canvas.drawCircle(Offset(px - r * 0.3, py - r * 0.3), r * 0.4, Paint()..color = Colors.white.withValues(alpha: 0.5));
      }
      return; // skip normal dissolve logic
    }
    final solids = item.layers.where((l) => l.isSolid && l.dissolveProgress < 1.0).toList();
    if (solids.isEmpty) return;

    final solidVol = item.solidVolume;
    if (solidVol <= 0.2) return;

    // Pile height proportional to solid amount
    final pileRatio = (solidVol / 50.0).clamp(0.0, 1.0);
    final pileH = h * 0.14 * pileRatio;

    final baseY = h * 0.94;
    final col = solids.first.color;
    final rng = Random(item.id.length * 7 + 13);

    // Main pile shape (mound)
    final pilePath = Path()
      ..moveTo(w * 0.18, baseY)
      ..quadraticBezierTo(w * 0.32, baseY - pileH * 1.15, w * 0.50, baseY - pileH * 1.3)
      ..quadraticBezierTo(w * 0.68, baseY - pileH * 1.15, w * 0.82, baseY)
      ..lineTo(w * 0.18, baseY)
      ..close();

    canvas.drawPath(pilePath, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          col.withValues(alpha: 0.55),
          col.withValues(alpha: 0.85),
          col.withValues(alpha: 1.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, baseY - pileH * 1.3, w, pileH * 1.3)));

    // Powder texture particles
    final count = (solidVol * 1.2).toInt().clamp(12, 60);
    for (int i = 0; i < count; i++) {
      final px = w * 0.22 + rng.nextDouble() * w * 0.56;
      final distFromCenter = ((px - w * 0.5).abs() / (w * 0.32)).clamp(0.0, 1.0);
      final topY = baseY - pileH * 1.25 * (1 - distFromCenter);
      final py = topY + rng.nextDouble() * (baseY - topY) * 0.9;
      if (py > baseY) continue;
      canvas.drawCircle(
        Offset(px, py),
        0.7 + rng.nextDouble() * 1.4,
        Paint()..color = col.withValues(alpha: 0.85 + rng.nextDouble() * 0.15));
    }

    // Sparkle highlights (crystalline look)
    for (int i = 0; i < 6; i++) {
      final px = w * 0.28 + rng.nextDouble() * w * 0.44;
      final topY = baseY - pileH * 1.2;
      final py = topY + rng.nextDouble() * (baseY - topY) * 0.8;
      canvas.drawCircle(
        Offset(px, py),
        0.5 + rng.nextDouble() * 0.7,
        Paint()..color = Colors.white.withValues(alpha: 0.75));
    }

    // Dissolving particles rising up (jab dissolve chal raha ho)
    final dissolving = solids.first.dissolveProgress;
    if (dissolving > 0.05 && dissolving < 0.95) {
      final dissolveIntensity = sin(dissolving * pi);
      for (int i = 0; i < 6; i++) {
        final s = rng.nextDouble();
        final px = w * 0.28 + rng.nextDouble() * w * 0.44;
        final baseYY = baseY - pileH * 0.5;
        final riseP = ((time * 0.6 + s) % 1.0);
        final py = baseYY - riseP * pileH * 1.3;
        canvas.drawCircle(
          Offset(px, py),
          0.8 + (1 - riseP) * 1.2,
          Paint()..color = col.withValues(alpha: dissolveIntensity * (1 - riseP) * 0.85));
      }
      for (int i = 0; i < 3; i++) {
        final s = rng.nextDouble();
        final px = w * 0.3 + rng.nextDouble() * w * 0.4;
        final baseYY = baseY - pileH * 0.7;
        final riseP = ((time * 0.4 + s * 0.7) % 1.0);
        final py = baseYY - riseP * pileH * 1.8;
        canvas.drawCircle(
          Offset(px, py),
          0.6 + (1 - riseP) * 0.9,
          Paint()..color = Colors.white.withValues(alpha: dissolveIntensity * (1 - riseP) * 0.7));
      }
    }

    // Top surface highlight
    final topHighlight = Path()
      ..moveTo(w * 0.32, baseY - pileH * 0.95)
      ..quadraticBezierTo(w * 0.42, baseY - pileH * 1.25, w * 0.5, baseY - pileH * 1.28)
      ..quadraticBezierTo(w * 0.58, baseY - pileH * 1.25, w * 0.68, baseY - pileH * 0.95);
    canvas.drawPath(topHighlight, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = LC.glassEdge.withValues(alpha: 0.6));
  }

  @override
  bool shouldRepaint(covariant RealisticEquipPainter old) => true;
}




