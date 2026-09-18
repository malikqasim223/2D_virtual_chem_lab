import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models/chemical.dart';
import '../data/models/reaction.dart';
import '../logic/reaction_engine.dart';

// ═══════════════════════════════════════════════════════
// THEME
// ═══════════════════════════════════════════════════════
class K {
  static const bgDeep = Color(0xFF050D1A);
  static const bg = Color(0xFF0A1424);
  static const panel = Color(0xFF0F1B2E);
  static const panelElev = Color(0xFF152238);
  static const panelTop = Color(0xFF1A2942);
  static const border = Color(0xFF1F2E48);
  static const cyan = Color(0xFF22D3EE);
  static const blue = Color(0xFF3B82F6);
  static const blueBright = Color(0xFF60A5FA);
  static const blueSoft = Color(0xFF1E3A5F);
  static const green = Color(0xFF10B981);
  static const amber = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);
  static const text = Color(0xFFF1F5F9);
  static const textSub = Color(0xFF94A3B8);
  static const textDim = Color(0xFF64748B);
  static const textMute = Color(0xFF475569);
}

// ═══════════════════════════════════════════════════════
// ENUMS
// ═══════════════════════════════════════════════════════
enum EquipmentType { beaker, flask, testTube, cylinder }

extension EqX on EquipmentType {
  String get label => const ['Beaker', 'Flask', 'Test Tube', 'Cylinder'][index];
  IconData get icon => const [Icons.coffee, Icons.science, Icons.biotech, Icons.straighten][index];
  double get maxVolume => const [250.0, 250.0, 50.0, 100.0][index];
  Size get size => const [Size(140.0, 180.0), Size(160.0, 210.0), Size(60.0, 220.0), Size(80.0, 240.0)][index];
  EqShape get shape => const [EqShape.beaker, EqShape.flask, EqShape.testTube, EqShape.cylinder][index];
}

enum ToolType { bunsenBurner, thermometer, stirrer, balance, dropper, filtration }

extension ToolX on ToolType {
  String get label => const ['Bunsen Burner', 'Thermometer', 'Stirrer', 'Balance', 'Dropper', 'Funnel'][index];
  IconData get icon => const [Icons.local_fire_department, Icons.thermostat, Icons.rotate_right, Icons.scale, Icons.water_drop, Icons.grid_on, Icons.filter_alt][index];
  Size get size => const [Size(70.0, 130.0), Size(45.0, 200.0), Size(60.0, 220.0), Size(160.0, 100.0), Size(45.0, 150.0), Size(180.0, 90.0), Size(120.0, 220.0)][index];
  ToolShape get shape => const [ToolShape.bunsenBurner, ToolShape.thermometer, ToolShape.stirrer, ToolShape.balance, ToolShape.dropper, ToolShape.filtration][index];
}

enum EqShape { beaker, flask, testTube, cylinder }
enum ToolShape { bunsenBurner, thermometer, stirrer, balance, dropper, filtration }

// ═══════════════════════════════════════════════════════
// PHYSICS: Liquid Particle
// ═══════════════════════════════════════════════════════
class LiquidParticle {
  double x;      // 0..1 within container width
  double y;      // 0..1 within liquid height (0 = top)
  double vx;
  double vy;
  double size;
  Color color;

  LiquidParticle({
    required this.x,
    required this.y,
    this.vx = 0,
    this.vy = 0,
    this.size = 1.0,
    required this.color,
  });
}

// ═══════════════════════════════════════════════════════
// PHYSICS: Bubble Particle (with buoyancy)
// ═══════════════════════════════════════════════════════
class BubbleParticle {
  double x;
  double y;
  double vy;      // negative = upward
  double size;
  double wobble;
  double age;
  double life;

  BubbleParticle({
    required this.x,
    required this.y,
    required this.vy,
    required this.size,
    required this.wobble,
    this.age = 0,
    this.life = 1.0,
  });
}

// ═══════════════════════════════════════════════════════
// PHYSICS: Steam Particle
// ═══════════════════════════════════════════════════════
class SteamParticle {
  double x;
  double y;
  double vy;
  double vx;
  double size;
  double age;
  double life;

  SteamParticle({
    required this.x,
    required this.y,
    required this.vy,
    required this.vx,
    required this.size,
    this.age = 0,
    this.life = 1.0,
  });
}

// ═══════════════════════════════════════════════════════
// PHYSICS: Spark Particle (gravity)
// ═══════════════════════════════════════════════════════
class SparkParticle {
  double x;
  double y;
  double vx;
  double vy;
  double age;
  double life;

  SparkParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    this.age = 0,
    this.life = 1.0,
  });
}

// ═══════════════════════════════════════════════════════
// PHYSICS: Precipitate Particle (gravity settling)
// ═══════════════════════════════════════════════════════
class PrecipitateParticle {
  double x;
  double y;
  double vy;
  double size;
  Color color;

  PrecipitateParticle({
    required this.x,
    required this.y,
    this.vy = 0.2,
    required this.size,
    required this.color,
  });
}

// ═══════════════════════════════════════════════════════
// EQUIPMENT DATA (with physics)
// ═══════════════════════════════════════════════════════
class EquipmentData {
  final EquipmentType type;
  final Map<String, double> chemicalVolumes = {};
  double temperature = 25.0;
  bool isHeating = false;
  bool isCooling = false;
  bool isStirring = false;
  double stirAngle = 0;
  double shakeIntensity = 0;

  // Physics particles
  final List<LiquidParticle> liquidParticles = [];
  final List<BubbleParticle> bubbles = [];
  final List<SteamParticle> steamParticles = [];
  final List<SparkParticle> sparks = [];
  final List<PrecipitateParticle> precipitateParticles = [];

  Offset position = Offset.zero;
  int id = 0;

  EquipmentData(this.type);

  double get totalVolume => chemicalVolumes.values.fold(0.0, (a, b) => a + b);
  List<String> get chemicalIds => chemicalVolumes.keys.toList();

  void addChemical(String id, double mL) {
    chemicalVolumes[id] = (chemicalVolumes[id] ?? 0.0) + mL;
    if (chemicalVolumes[id]! > type.maxVolume) chemicalVolumes[id] = type.maxVolume;
  }

  void clear() {
    chemicalVolumes.clear();
    temperature = 25.0;
    isHeating = false;
    isCooling = false;
    isStirring = false;
    shakeIntensity = 0;
    liquidParticles.clear();
    bubbles.clear();
    steamParticles.clear();
    sparks.clear();
    precipitateParticles.clear();
  }

  // Physics step
  void tick(double dt, Random rng, double viewW, double viewH) {
    // Temperature physics
    if (isHeating) {
      temperature = (temperature + 30 * dt).clamp(25.0, 150.0);
    } else if (isCooling) {
      temperature = (temperature - 20 * dt).clamp(5.0, 150.0);
    } else {
      // Natural cooling toward 25°C
      if (temperature > 25.0) {
        temperature = (temperature - 3 * dt).clamp(25.0, 150.0);
      }
    }

    // Shake decay
    if (shakeIntensity > 0) {
      shakeIntensity = (shakeIntensity - dt * 3).clamp(0.0, 1.0);
    }

    // Stir angle
    if (isStirring) {
      stirAngle += dt * 15;
    }

    // Spawn bubbles if heating or gas reaction
    final hasLiquid = totalVolume > 0;
    if (hasLiquid && temperature > 60 && rng.nextDouble() < dt * 15) {
      bubbles.add(BubbleParticle(
        x: rng.nextDouble(),
        y: 1.0,
        vy: -0.2 - rng.nextDouble() * 0.3,
        size: 2 + rng.nextDouble() * 4,
        wobble: rng.nextDouble() * pi * 2,
      ));
    }

    // Update bubbles (buoyancy)
    for (int i = bubbles.length - 1; i >= 0; i--) {
      final b = bubbles[i];
      b.y += b.vy * dt * 3;
      b.x += sin(b.wobble + b.age * 6) * 0.002;
      b.age += dt;
      b.life -= dt * 0.8;
      if (b.y < -0.05 || b.life <= 0) bubbles.removeAt(i);
    }

    // Spawn steam if very hot
    if (hasLiquid && temperature > 80 && rng.nextDouble() < dt * 8) {
      steamParticles.add(SteamParticle(
        x: 0.3 + rng.nextDouble() * 0.4,
        y: 0.0,
        vy: -0.15 - rng.nextDouble() * 0.2,
        vx: (rng.nextDouble() - 0.5) * 0.1,
        size: 6 + rng.nextDouble() * 10,
      ));
    }

    // Update steam
    for (int i = steamParticles.length - 1; i >= 0; i--) {
      final s = steamParticles[i];
      s.y += s.vy * dt * 3;
      s.x += s.vx * dt * 3;
      s.size += dt * 8;
      s.age += dt;
      s.life -= dt * 0.5;
      if (s.life <= 0) steamParticles.removeAt(i);
    }

    // Update sparks (gravity)
    for (int i = sparks.length - 1; i >= 0; i--) {
      final sp = sparks[i];
      sp.x += sp.vx * dt;
      sp.y += sp.vy * dt;
      sp.vy += 300 * dt; // gravity
      sp.age += dt;
      sp.life -= dt * 1.5;
      if (sp.life <= 0) sparks.removeAt(i);
    }

    // Update precipitate (settling)
    for (int i = precipitateParticles.length - 1; i >= 0; i--) {
      final pp = precipitateParticles[i];
      if (pp.y < 0.95) {
        pp.y += pp.vy * dt * 5;
      } else {
        pp.y = 0.95;
      }
      if (rng.nextDouble() < dt * 0.5) {
        pp.x += (rng.nextDouble() - 0.5) * 0.005;
      }
    }
  }

  void spawnSparks(Random rng) {
    sparks.clear();
    for (int i = 0; i < 30; i++) {
      final angle = rng.nextDouble() * pi * 2;
      final speed = 80 + rng.nextDouble() * 150;
      sparks.add(SparkParticle(
        x: 0.5,
        y: 0.5,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
      ));
    }
  }

  void spawnPrecipitate(Random rng, Color color) {
    precipitateParticles.clear();
    for (int i = 0; i < 40; i++) {
      precipitateParticles.add(PrecipitateParticle(
        x: rng.nextDouble(),
        y: rng.nextDouble() * 0.3,
        vy: 0.2 + rng.nextDouble() * 0.3,
        size: 1.5 + rng.nextDouble() * 2.5,
        color: color,
      ));
    }
  }
}

class ToolData {
  final ToolType type;
  bool isActive = false;
  Offset position = Offset.zero;
  int id = 0;

  ToolData(this.type);
}

// ═══════════════════════════════════════════════════════
// MAIN SCREEN
// ═══════════════════════════════════════════════════════
class LabScreen extends StatefulWidget {
  const LabScreen({super.key});
  @override
  State<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends State<LabScreen> with TickerProviderStateMixin {
  static const List<Chemical> _chemicals = [
    Chemical(id: 'hcl', name: 'Hydrochloric Acid', formula: 'HCl', state: 'Liquid', color: Color(0xFFB8E1F5), safetyInfo: 'Corrosive'),
    Chemical(id: 'naoh', name: 'Sodium Hydroxide', formula: 'NaOH', state: 'Solid', color: Color(0xFFF0F4F8), safetyInfo: 'Strong base'),
    Chemical(id: 'cuso4', name: 'Copper(II) Sulfate', formula: 'CuSO4', state: 'Solid', color: Color(0xFF1A8FE3), safetyInfo: 'Harmful'),
    Chemical(id: 'agno3', name: 'Silver Nitrate', formula: 'AgNO3', state: 'Solid', color: Color(0xFFEDEDED), safetyInfo: 'Stains skin'),
    Chemical(id: 'ethanol', name: 'Ethanol', formula: 'C2H5OH', state: 'Liquid', color: Color(0xFFE8F0F8), safetyInfo: 'Flammable'),
    Chemical(id: 'phenolphthalein', name: 'Phenolphthalein', formula: 'C20H12O4', state: 'Indicator', color: Color(0xFFEC4899), safetyInfo: 'Indicator'),
    Chemical(id: 'nacl', name: 'Sodium Chloride', formula: 'NaCl', state: 'Solid', color: Color(0xFFF5F5F5), safetyInfo: 'Common salt'),
    Chemical(id: 'h2so4', name: 'Sulfuric Acid', formula: 'H2SO4', state: 'Liquid', color: Color(0xFFF3C87A), safetyInfo: 'Corrosive'),
  ];

  static const List<double> _measurements = [5.0, 10.0, 25.0, 50.0];

  final List<EquipmentData> _equipment = [];
  final List<ToolData> _tools = [];
  final List<ReactionResult?> _results = [];

  final Random _rng = Random();
  Timer? _physicsTimer;
  DateTime _lastTick = DateTime.now();

  double _selectedVolume = 10.0;
  int _activeNavIndex = 1;
  int _nextEquipId = 1;
  int _nextToolId = 1;

  // Drag state
  Chemical? _draggingChemical;
  ToolType? _draggingTool;
  Offset _dragPos = Offset.zero;
  OverlayEntry? _dragOverlay;

  // Bench area
  final GlobalKey _benchKey = GlobalKey();
  Size _benchSize = const Size(800, 600);

  @override
  void initState() {
    super.initState();

    // Start with 2 equipment
    _addEquipmentAt(EquipmentType.beaker, const Offset(200, 200));
    _addEquipmentAt(EquipmentType.flask, const Offset(420, 200));

    // Physics loop at 60 FPS
    _physicsTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _physicsTick();
    });
  }

  @override
  void dispose() {
    _physicsTimer?.cancel();
    _dragOverlay?.remove();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════
  // PHYSICS LOOP
  // ═══════════════════════════════════════════════════════
  void _physicsTick() {
    if (!mounted) return;
    final now = DateTime.now();
    final dt = now.difference(_lastTick).inMicroseconds / 1000000.0;
    _lastTick = now;

    if (dt <= 0 || dt > 0.1) return;

    bool needsRebuild = false;

    for (final eq in _equipment) {
      if (eq.isHeating ||
          eq.isCooling ||
          eq.isStirring ||
          eq.shakeIntensity > 0 ||
          eq.bubbles.isNotEmpty ||
          eq.steamParticles.isNotEmpty ||
          eq.sparks.isNotEmpty ||
          eq.precipitateParticles.isNotEmpty ||
          eq.temperature > 26) {
        eq.tick(dt, _rng, _benchSize.width, _benchSize.height);
        needsRebuild = true;
      }
    }

    if (needsRebuild || _tools.any((t) => t.isActive)) setState(() {});
  }

  // ═══════════════════════════════════════════════════════
  // ADD EQUIPMENT
  // ═══════════════════════════════════════════════════════
  void _addEquipmentAt(EquipmentType type, Offset pos) {
    SystemSound.play(SystemSoundType.click);
    final eq = EquipmentData(type)
      ..position = pos
      ..id = _nextEquipId++;
    setState(() {
      _equipment.add(eq);
      _results.add(null);
    });
  }

  void _removeEquipment(int i) {
    SystemSound.play(SystemSoundType.click);
    setState(() {
      if (_equipment.isEmpty) return;
      _equipment.removeAt(i);
      if (i < _results.length) _results.removeAt(i);
    });
  }

  // ═══════════════════════════════════════════════════════
  // ADD TOOL (dragged onto bench)
  // ═══════════════════════════════════════════════════════
  void _addToolAt(ToolType type, Offset pos) {
    SystemSound.play(SystemSoundType.click);
    final tool = ToolData(type)
      ..position = pos
      ..id = _nextToolId++;
    setState(() => _tools.add(tool));
  }

  void _removeTool(int i) {
    SystemSound.play(SystemSoundType.click);
    setState(() {
      if (i < _tools.length) _tools.removeAt(i);
    });
  }

  // ═══════════════════════════════════════════════════════
  // TOGGLE TOOL (when tapped - activate / deactivate)
  // ═══════════════════════════════════════════════════════
  void _toggleTool(int i) {
    SystemSound.play(SystemSoundType.click);
    final tool = _tools[i];
    setState(() {
      tool.isActive = !tool.isActive;

      // Apply effects to equipment
      if (tool.type == ToolType.bunsenBurner) {
        for (final eq in _equipment) {
          eq.isHeating = tool.isActive;
          if (tool.isActive) eq.isCooling = false;
        }
      } else if (tool.type == ToolType.stirrer) {
        for (final eq in _equipment) {
          eq.isStirring = tool.isActive;
        }
      }
    });
  }

  // ═══════════════════════════════════════════════════════
  // COOL ACTION
  // ═══════════════════════════════════════════════════════
  void _coolAll() {
    SystemSound.play(SystemSoundType.click);
    setState(() {
      for (final eq in _equipment) {
        eq.isHeating = false;
        eq.isCooling = true;
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => eq.isCooling = false);
        });
      }
    });
  }

  // ═══════════════════════════════════════════════════════
  // SHAKE / MIX
  // ═══════════════════════════════════════════════════════
  void _shakeAll() {
    SystemSound.play(SystemSoundType.alert);
    setState(() {
      for (final eq in _equipment) {
        eq.shakeIntensity = 1.0;
      }
    });
  }

  // ═══════════════════════════════════════════════════════
  // RESET
  // ═══════════════════════════════════════════════════════
  void _reset() {
    SystemSound.play(SystemSoundType.click);
    setState(() {
      for (final eq in _equipment) {
        eq.clear();
      }
      for (int i = 0; i < _results.length; i++) {
        _results[i] = null;
      }
    });
  }

  // ═══════════════════════════════════════════════════════
  // CHEMICAL DRAG - START
  // ═══════════════════════════════════════════════════════
  void _startChemicalDrag(Chemical c, Offset pos) {
    _draggingChemical = c;
    _dragPos = pos;
    _dragOverlay?.remove();
    _dragOverlay = OverlayEntry(
      builder: (_) => Positioned(
        left: _dragPos.dx - 50,
        top: _dragPos.dy - 70,
        child: IgnorePointer(
          child: Material(
            color: Colors.transparent,
            child: _dragChemicalBottle(c),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_dragOverlay!);
    setState(() {});
  }

  void _updateChemicalDrag(Offset pos) {
    if (_dragOverlay == null) return;
    _dragPos = pos;
    _dragOverlay!.markNeedsBuild();
    setState(() {});
  }

  void _endChemicalDrag() {
    _dragOverlay?.remove();
    _dragOverlay = null;

    // Check if dropped on equipment
    final idx = _equipmentAtPoint(_dragPos, _draggingChemical);
    if (idx != null && _draggingChemical != null) {
      _pourInto(idx, _draggingChemical!);
    }

    setState(() {
      _draggingChemical = null;
    });
  }

  // ═══════════════════════════════════════════════════════
  // TOOL DRAG - START
  // ═══════════════════════════════════════════════════════
  void _startToolDrag(ToolType type, Offset pos) {
    _draggingTool = type;
    _dragPos = pos;
    _dragOverlay?.remove();
    _dragOverlay = OverlayEntry(
      builder: (_) => Positioned(
        left: _dragPos.dx - 40,
        top: _dragPos.dy - 40,
        child: IgnorePointer(
          child: Material(
            color: Colors.transparent,
            child: _dragToolPreview(type),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_dragOverlay!);
    setState(() {});
  }

  void _updateToolDrag(Offset pos) {
    if (_dragOverlay == null) return;
    _dragPos = pos;
    _dragOverlay!.markNeedsBuild();
  }

  void _endToolDrag() {
    _dragOverlay?.remove();
    _dragOverlay = null;
    if (_draggingTool != null) {
      _addToolAt(_draggingTool!, _dragPos);
    }
    setState(() {
      _draggingTool = null;
    });
  }

  // ═══════════════════════════════════════════════════════
  // FIND EQUIPMENT AT POINT
  // ═══════════════════════════════════════════════════════
  int? _equipmentAtPoint(Offset globalPos, Chemical? chem) {
    if (chem == null) return null;
    final benchCtx = _benchKey.currentContext;
    if (benchCtx == null) return null;
    final benchBox = benchCtx.findRenderObject() as RenderBox?;
    if (benchBox == null) return null;
    final local = benchBox.globalToLocal(globalPos);

    for (int i = 0; i < _equipment.length; i++) {
      final eq = _equipment[i];
      final s = eq.type.size;
      final r = Rect.fromLTWH(eq.position.dx, eq.position.dy, s.width, s.height);
      if (r.inflate(20).contains(local)) return i;
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════
  // POUR CHEMICAL INTO EQUIPMENT
  // ═══════════════════════════════════════════════════════
  void _pourInto(int i, Chemical c) {
    SystemSound.play(SystemSoundType.click);
    setState(() {
      final eq = _equipment[i];
      eq.addChemical(c.id, _selectedVolume);
      final prev = _results[i];
      final next = ReactionEngine.verify(eq.chemicalIds);
      _results[i] = next;

      // Visual effects based on reaction
      if (next.matched && (prev == null || !prev.matched)) {
        // Reaction triggered!
        eq.shakeIntensity = 1.0;
        eq.spawnSparks(_rng);
        SystemSound.play(SystemSoundType.alert);

        // Precipitate effect
        if (next.reaction?.precipitate == true) {
          eq.spawnPrecipitate(_rng, next.reaction?.colorChange ?? const Color(0xFF60A5FA));
        }

        // Gas / bubbles
        if (next.reaction?.bubbles == true) {
          for (int j = 0; j < 20; j++) {
            eq.bubbles.add(BubbleParticle(
              x: _rng.nextDouble(),
              y: 1.0,
              vy: -0.3 - _rng.nextDouble() * 0.4,
              size: 2 + _rng.nextDouble() * 5,
              wobble: _rng.nextDouble() * pi * 2,
            ));
          }
        }
      }

      // Always add some liquid particles (mixing)
      for (int j = 0; j < 20; j++) {
        eq.liquidParticles.add(LiquidParticle(
          x: _rng.nextDouble(),
          y: _rng.nextDouble(),
          vx: (_rng.nextDouble() - 0.5) * 0.02,
          vy: (_rng.nextDouble() - 0.5) * 0.02,
          size: 1 + _rng.nextDouble() * 2,
          color: c.color,
        ));
      }
    });
  }

  Color _liquidColor(int i) {
    if (i >= _results.length) return Colors.transparent;
    final r = _results[i];
    if (r?.matched == true && r?.reaction?.colorChange != null) {
      return r!.reaction!.colorChange!;
    }
    final eq = _equipment[i];
    if (eq.chemicalIds.isEmpty) return Colors.transparent;
    return _chemicals.firstWhere((c) => c.id == eq.chemicalIds.last).color;
  }

  // ═══════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: K.bgDeep,
      body: Column(
        children: [
          _topBar(),
          Expanded(
            child: Row(
              children: [
                _leftNav(),
                _chemicalInventoryPanel(),
                Expanded(child: _mainLabArea()),
                _rightToolboxPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // TOP BAR
  // ═══════════════════════════════════════════════════════
  Widget _topBar() {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: K.bg,
        border: Border(bottom: BorderSide(color: K.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [K.cyan, K.blue]),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: K.cyan.withValues(alpha: 0.4), blurRadius: 12)],
            ),
            child: const Icon(Icons.science, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  children: [
                    TextSpan(text: 'Virtual '),
                    TextSpan(text: 'Chemistry', style: TextStyle(color: K.cyan)),
                    TextSpan(text: ' Lab'),
                  ],
                ),
              ),
              const Text('Explore - Experiment - Learn',
                style: TextStyle(color: K.textDim, fontSize: 10)),
            ],
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: K.panel,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: K.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  Icon(Icons.search, color: K.textDim, size: 16),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('Search chemicals, experiments or keywords...',
                      style: TextStyle(color: K.textDim, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          _topIcon(Icons.brightness_6, () {}),
          const SizedBox(width: 6),
          _topIcon(Icons.notifications_none, () {}),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: K.panel,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: K.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [K.cyan, K.blue]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Student',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    Text('University Student',
                      style: TextStyle(color: K.textDim, fontSize: 9)),
                  ],
                ),
                const SizedBox(width: 6),
                const Icon(Icons.keyboard_arrow_down, color: K.textDim, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topIcon(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: K.panel,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: K.border),
          ),
          child: Icon(icon, color: K.textSub, size: 16),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // LEFT NAV
  // ═══════════════════════════════════════════════════════
  Widget _leftNav() {
    final items = [
      (Icons.home_outlined, 'Home'),
      (Icons.science_outlined, 'Virtual Lab'),
      (Icons.biotech_outlined, 'Experiments'),
      (Icons.inventory_2_outlined, 'Chemical\nInventory'),
      (Icons.history, 'History'),
      (Icons.settings_outlined, 'Settings'),
    ];

    return Container(
      width: 170,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [K.panel, K.bg],
        ),
        border: Border(right: BorderSide(color: K.border)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          ...items.asMap().entries.map((e) {
            final active = _activeNavIndex == e.key;
            return GestureDetector(
              onTap: () => setState(() => _activeNavIndex = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: active ? K.blueSoft.withValues(alpha: 0.6) : null,
                  borderRadius: BorderRadius.circular(10),
                  border: active ? Border.all(color: K.cyan.withValues(alpha: 0.4)) : null,
                  boxShadow: active
                      ? [BoxShadow(color: K.cyan.withValues(alpha: 0.15), blurRadius: 12)]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(e.value.$1, size: 18, color: active ? K.cyan : K.textSub),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        e.value.$2,
                        style: TextStyle(
                          color: active ? Colors.white : K.textSub,
                          fontSize: 12,
                          fontWeight: active ? FontWeight.bold : FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const Spacer(),
          Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [K.blueSoft.withValues(alpha: 0.5), K.panel],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: K.cyan.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: K.cyan.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.science, color: K.cyan, size: 24),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Small\nExperiments\nMake Big\nDiscoveries',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: K.textSub, fontSize: 10, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // CHEMICAL INVENTORY PANEL
  // ═══════════════════════════════════════════════════════
  Widget _chemicalInventoryPanel() {
    return Container(
      width: 290,
      decoration: const BoxDecoration(
        color: K.panel,
        border: Border(right: BorderSide(color: K.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: K.cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.science, size: 12, color: K.cyan),
                ),
                const SizedBox(width: 10),
                const Text('Chemical Inventory',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _catChip('All', true),
                const SizedBox(width: 4),
                _catChip('Acids', false),
                const SizedBox(width: 4),
                _catChip('Bases', false),
                const SizedBox(width: 4),
                _catChip('Salts', false),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            height: 34,
            decoration: BoxDecoration(
              color: K.bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: K.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: const [
                Icon(Icons.search, color: K.textDim, size: 13),
                SizedBox(width: 8),
                Text('Search chemicals...', style: TextStyle(color: K.textDim, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _chemicals.length,
              itemBuilder: (_, i) => _chemRow(_chemicals[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _catChip(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: active ? const LinearGradient(colors: [K.cyan, K.blue]) : null,
        color: active ? null : K.bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: active ? K.cyan : K.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : K.textSub,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _chemRow(Chemical c) {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (d) => _startChemicalDrag(c, d.globalPosition),
        onPanUpdate: (d) => _updateChemicalDrag(d.globalPosition),
        onPanEnd: (_) => _endChemicalDrag(),
        onPanCancel: _endChemicalDrag,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: K.panelElev,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: K.border.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 32, height: 40,
                decoration: BoxDecoration(
                  color: K.bg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: K.border),
                ),
                child: Center(
                  child: Container(
                    width: 16, height: 24,
                    decoration: BoxDecoration(
                      color: c.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(c.formula,
                          style: const TextStyle(color: K.cyan, fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: K.blueSoft.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(c.state,
                            style: const TextStyle(color: K.blueBright, fontSize: 8, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: K.cyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: K.cyan.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.drag_indicator, size: 14, color: K.cyan),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // RIGHT TOOLBOX PANEL (Tools draggable!)
  // ═══════════════════════════════════════════════════════
  Widget _rightToolboxPanel() {
    return Container(
      width: 290,
      decoration: const BoxDecoration(
        color: K.panel,
        border: Border(left: BorderSide(color: K.border)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _toolboxHeader(),
            _toolboxSectionDraggable('Lab Equipment', EquipmentType.values
                .map((t) => (t.icon, t.label, () => _addEquipmentAt(t, const Offset(200, 200)), t))
                .toList()),
            _toolboxSectionDraggable('Tools (Drag to bench)', ToolType.values
                .map((t) => (t.icon, t.label, () => _addToolAt(t, const Offset(300, 300)), t))
                .toList()),
            _actionsSection(),
            _reactionInfoPanel(),
            _instructionsPanel(),
            _historyPanel(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _toolboxHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: K.cyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.build_circle_outlined, size: 12, color: K.cyan),
          ),
          const SizedBox(width: 10),
          const Text('Chemistry Toolbox',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Draggable toolbox section
  Widget _toolboxSectionDraggable(String title, List<(IconData, String, VoidCallback, dynamic)> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Text(title,
            style: const TextStyle(
              color: K.textSub, fontSize: 10,
              fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 6, runSpacing: 6,
            children: items.map((item) {
              final (icon, label, onTap, type) = item;
              if (type is ToolType) {
                // Draggable tool
                return _draggableToolTile(icon, label, type);
              } else if (type is EquipmentType) {
                // Equipment tile (tap to add at default position)
                return _toolboxTile(icon, label, onTap);
              }
              return const SizedBox.shrink();
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _toolboxTile(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 78,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: K.panelElev,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: K.border.withValues(alpha: 0.6)),
          ),
          child: Column(
            children: [
              Icon(icon, color: K.cyan, size: 18),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: K.textSub, fontSize: 9, fontWeight: FontWeight.w600, height: 1.15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Draggable tool tile
  Widget _draggableToolTile(IconData icon, String label, ToolType type) {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (d) => _startToolDrag(type, d.globalPosition),
        onPanUpdate: (d) => _updateToolDrag(d.globalPosition),
        onPanEnd: (_) => _endToolDrag(),
        onPanCancel: _endToolDrag,
        child: Container(
          width: 78,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                K.cyan.withValues(alpha: 0.12),
                K.blue.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: K.cyan.withValues(alpha: 0.35)),
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Icon(icon, color: K.cyan, size: 18),
                  Container(
                    padding: const EdgeInsets.all(1),
                    decoration: const BoxDecoration(
                      color: K.cyan,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.drag_indicator,
                        color: Colors.white, size: 8),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: K.cyan, fontSize: 9, fontWeight: FontWeight.w700, height: 1.15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ACTIONS SECTION — tap to perform action
  // ═══════════════════════════════════════════════════════
  Widget _actionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Text('Quick Actions',
            style: TextStyle(
              color: K.textSub, fontSize: 10,
              fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 6, runSpacing: 6,
            children: [
              _actionTile(Icons.local_fire_department, 'Heat All', () {
                setState(() {
                  for (final eq in _equipment) {
                    eq.isHeating = true;
                    eq.isCooling = false;
                  }
                });
              }),
              _actionTile(Icons.ac_unit, 'Cool All', _coolAll),
              _actionTile(Icons.rotate_right, 'Stir All', () {
                setState(() {
                  for (final eq in _equipment) {
                    eq.isStirring = !eq.isStirring;
                  }
                });
              }),
              _actionTile(Icons.vibration, 'Shake All', _shakeAll),
              _actionTile(Icons.cleaning_services, 'Clear', _reset),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionTile(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 78,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: K.panelElev,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: K.amber.withValues(alpha: 0.35)),
          ),
          child: Column(
            children: [
              Icon(icon, color: K.amber, size: 18),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: K.amber, fontSize: 9, fontWeight: FontWeight.w600, height: 1.15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // REACTION INFO PANEL
  // ═══════════════════════════════════════════════════════
  Widget _reactionInfoPanel() {
    int idx = -1;
    for (var k = _results.length - 1; k >= 0; k--) {
      if (_results[k] != null) { idx = k; break; }
    }

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: K.panelElev,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: K.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: K.cyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.info_outline, size: 10, color: K.cyan),
              ),
              const SizedBox(width: 8),
              const Text('Reaction Information',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          if (idx == -1 || !_results[idx]!.matched)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: K.bg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Add chemicals to see reaction info',
                style: TextStyle(color: K.textDim, fontSize: 10)),
            )
          else
            _reactionContent(idx),
        ],
      ),
    );
  }

  Widget _reactionContent(int idx) {
    final rxn = _results[idx]!.reaction!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow('Name', rxn.name),
        _infoRow('Type', rxn.type),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: K.blueSoft.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: K.cyan.withValues(alpha: 0.3)),
          ),
          child: Text(
            rxn.equation,
            style: const TextStyle(color: K.cyan, fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Text(rxn.description,
          style: const TextStyle(color: K.textSub, fontSize: 10, height: 1.4)),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: 44,
            child: Text('$label:',
              style: const TextStyle(color: K.textDim, fontSize: 10))),
          Expanded(
            child: Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // INSTRUCTIONS
  // ═══════════════════════════════════════════════════════
  Widget _instructionsPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: K.panelElev,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: K.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: K.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.lightbulb_outline, size: 10, color: K.amber),
              ),
              const SizedBox(width: 8),
              const Text('Instructions',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          _instructionStep('1', 'Drag chemicals from inventory to equipment.'),
          _instructionStep('2', 'Drag tools (Bunsen, Stirrer) onto bench.'),
          _instructionStep('3', 'Tap tools to activate them.'),
          _instructionStep('4', 'Watch physics: bubbles, steam, sparks!'),
        ],
      ),
    );
  }

  Widget _instructionStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16, height: 16,
            decoration: BoxDecoration(
              color: K.cyan.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: K.cyan.withValues(alpha: 0.5)),
            ),
            child: Center(
              child: Text(num,
                style: const TextStyle(color: K.cyan, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
              style: const TextStyle(color: K.textSub, fontSize: 10, height: 1.3)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // HISTORY
  // ═══════════════════════════════════════════════════════
  Widget _historyPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: K.panelElev,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: K.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: K.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.history, size: 10, color: K.green),
              ),
              const SizedBox(width: 8),
              const Text('Experiment History',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              const Spacer(),
              const Text('View All', style: TextStyle(color: K.cyan, fontSize: 9)),
            ],
          ),
          const SizedBox(height: 10),
          _historyItem('Neutralization', 'HCl + NaOH', 'Today'),
          _historyItem('Precipitation', 'AgNO3 + NaCl', 'Yesterday'),
          _historyItem('Gas Formation', 'HCl + Na2CO3', '2 days ago'),
        ],
      ),
    );
  }

  Widget _historyItem(String name, String eq, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6, height: 6,
            decoration: const BoxDecoration(color: K.green, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                Text(eq, style: const TextStyle(color: K.textDim, fontSize: 9)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: K.textMute, fontSize: 8)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // MAIN LAB AREA
  // ═══════════════════════════════════════════════════════
  Widget _mainLabArea() {
    return Container(
      color: K.bgDeep,
      child: Column(
        children: [
          _labHeader(),
          Expanded(child: _benchWithPhysics()),
          _bottomPanels(),
        ],
      ),
    );
  }

  Widget _labHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: K.bg,
        border: Border(bottom: BorderSide(color: K.border)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: K.cyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Icon(Icons.science, size: 11, color: K.cyan),
          ),
          const SizedBox(width: 8),
          const Text('Virtual Laboratory',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: K.panelElev,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: K.border),
            ),
            child: const Row(
              children: [
                Text('Experiment: Neutralization Reaction',
                  style: TextStyle(color: K.textSub, fontSize: 10, fontWeight: FontWeight.w600)),
                SizedBox(width: 6),
                Icon(Icons.keyboard_arrow_down, color: K.textSub, size: 14),
              ],
            ),
          ),
          const Spacer(),
          _headerBtn(Icons.refresh, 'Reset', _reset, K.textSub),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                SystemSound.play(SystemSoundType.alert);
                _shakeAll();
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [K.green, Color(0xFF059669)]),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: K.green.withValues(alpha: 0.4), blurRadius: 10)],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.play_arrow, color: Colors.white, size: 13),
                    SizedBox(width: 5),
                    Text('Start Experiment',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerBtn(IconData icon, String label, VoidCallback onTap, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: K.panelElev,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: K.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 13),
              const SizedBox(width: 5),
              Text(label,
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // BENCH WITH PHYSICS-DRIVEN EQUIPMENT
  // ═══════════════════════════════════════════════════════
  Widget _benchWithPhysics() {
    return LayoutBuilder(
      builder: (context, constraints) {
        _benchSize = Size(constraints.maxWidth, constraints.maxHeight);

        return Container(
          key: _benchKey,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A2942), Color(0xFF0A1424)],
            ),
          ),
          child: Stack(
            children: [
              // Bench surface texture
              Positioned.fill(
                child: CustomPaint(painter: BenchSurfacePainter()),
              ),

              // Equipment (physics-driven)
              ..._equipment.asMap().entries.map((e) {
                final eq = e.value;
                return Positioned(
                  left: eq.position.dx,
                  top: eq.position.dy,
                  child: _equipmentPhysicsWidget(e.key),
                );
              }),

              // Tools (physics-driven)
              ..._tools.asMap().entries.map((e) {
                final tool = e.value;
                return Positioned(
                  left: tool.position.dx,
                  top: tool.position.dy,
                  child: _toolPhysicsWidget(e.key),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════
  // EQUIPMENT WIDGET (with physics particles)
  // ═══════════════════════════════════════════════════════
  Widget _equipmentPhysicsWidget(int i) {
    final eq = _equipment[i];
    final color = _liquidColor(i);
    final total = eq.totalVolume;
    final maxV = eq.type.maxVolume;
    final fill = (total / maxV).clamp(0.0, 1.0);
    final size = eq.type.size;

    // Shake offset (physics)
    final shakeX = eq.shakeIntensity > 0
        ? sin(DateTime.now().microsecondsSinceEpoch / 30000) * eq.shakeIntensity * 6
        : 0.0;
    final shakeY = eq.shakeIntensity > 0
        ? cos(DateTime.now().microsecondsSinceEpoch / 25000) * eq.shakeIntensity * 3
        : 0.0;

    return Transform.translate(
      offset: Offset(shakeX, shakeY),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: K.bg.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: K.cyan.withValues(alpha: 0.3)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 8)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(eq.type.icon, size: 9, color: K.cyan),
                    const SizedBox(width: 5),
                    Text(
                      '${total.toInt()}/${maxV.toInt()} mL',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Equipment + particles
              SizedBox(
                width: size.width + 40,
                height: size.height + 80,
                child: CustomPaint(
                  painter: PhysicsEquipmentPainter(
                    shape: eq.type.shape,
                    size: size,
                    liquidColor: color,
                    fillRatio: fill,
                    equipment: eq,
                    isHeating: eq.isHeating,
                    isStirring: eq.isStirring,
                    stirAngle: eq.stirAngle,
                  ),
                ),
              ),
            ],
          ),

          // Remove button
          Positioned(
            top: 30, right: 0,
            child: GestureDetector(
              onTap: () => _removeEquipment(i),
              child: Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  color: K.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.2),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4)],
                ),
                child: const Icon(Icons.close, size: 11, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // TOOL WIDGET (with physics - rotating stirrer, flame, etc)
  // ═══════════════════════════════════════════════════════
  Widget _toolPhysicsWidget(int i) {
    final tool = _tools[i];
    final size = tool.type.size;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => _toggleTool(i),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label - click to activate
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tool.isActive ? K.green : K.bg.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: tool.isActive ? K.green : K.border),
                  boxShadow: [
                    BoxShadow(
                      color: tool.isActive
                          ? K.green.withValues(alpha: 0.5)
                          : Colors.black.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: tool.isActive ? Colors.white : K.textDim,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tool.isActive ? '${tool.type.label} ON' : tool.type.label,
                      style: const TextStyle(
                        color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // Tool painter
              SizedBox(
                width: size.width,
                height: size.height,
                child: CustomPaint(
                  painter: AnimatedToolPainter(
                    shape: tool.type.shape,
                    isActive: tool.isActive,
                    time: DateTime.now().millisecondsSinceEpoch / 1000.0,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Remove button
        Positioned(
          top: -4, right: -4,
          child: GestureDetector(
            onTap: () => _removeTool(i),
            child: Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                color: K.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: const Icon(Icons.close, size: 10, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // DRAG PREVIEWS
  // ═══════════════════════════════════════════════════════
  Widget _dragChemicalBottle(Chemical c) {
    return SizedBox(
      width: 90, height: 120,
      child: Transform.rotate(
        angle: -0.15,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [K.panelTop, K.panelElev],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: K.cyan, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: K.cyan.withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.science, color: c.color, size: 28),
              const SizedBox(height: 6),
              Text(c.formula,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: K.cyan, borderRadius: BorderRadius.circular(8)),
                child: Text('${_selectedVolume.toInt()} mL',
                  style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dragToolPreview(ToolType type) {
    final s = type.size;
    return SizedBox(
      width: s.width,
      height: s.height,
      child: Opacity(
        opacity: 0.85,
        child: CustomPaint(
          painter: AnimatedToolPainter(
            shape: type.shape,
            isActive: false,
            time: DateTime.now().millisecondsSinceEpoch / 1000.0,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // BOTTOM PANELS
  // ═══════════════════════════════════════════════════════
  Widget _bottomPanels() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: K.bg,
        border: Border(top: BorderSide(color: K.border)),
      ),
      child: Row(
        children: [
          Expanded(child: _currentExperimentPanel()),
          const SizedBox(width: 10),
          Expanded(child: _reactionResultPanel()),
        ],
      ),
    );
  }

  Widget _currentExperimentPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: K.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: K.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: K.cyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.play_circle_outline, size: 10, color: K.cyan),
              ),
              const SizedBox(width: 8),
              const Text('Current Experiment',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }



  Widget _reactionResultPanel() {
    int idx = -1;
    for (var k = _results.length - 1; k >= 0; k--) {
      if (_results[k] != null) { idx = k; break; }
    }
    final matched = idx != -1 && _results[idx]!.matched == true;
    final rxn = matched ? _results[idx]!.reaction : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: K.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: matched ? K.green.withValues(alpha: 0.5) : K.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: matched ? K.green.withValues(alpha: 0.15) : K.textDim.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  matched ? Icons.science : Icons.science_outlined,
                  size: 10,
                  color: matched ? K.green : K.textDim,
                ),
              ),
              const SizedBox(width: 8),
              const Text('Reaction Result',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              if (matched) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: K.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('SUCCESS',
                    style: TextStyle(color: K.green, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          if (!matched)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: K.bg,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(Icons.science_outlined, color: K.textDim, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('No reaction yet',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                      SizedBox(height: 2),
                      Text('Drag chemicals to equipment to start.',
                        style: TextStyle(color: K.textDim, fontSize: 9)),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rxn!.equation,
                  style: const TextStyle(color: K.cyan, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(rxn.name,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// BENCH SURFACE PAINTER
// ═══════════════════════════════════════════════════════
class BenchSurfacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Grid pattern
    final gridPaint = Paint()
      ..color = K.border.withValues(alpha: 0.15)
      ..strokeWidth = 0.8;
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Cyan accent line at top
    canvas.drawRect(
      Rect.fromLTWH(0, 40, size.width, 1.5),
      Paint()..color = K.cyan.withValues(alpha: 0.2),
    );

    // Glow below
    canvas.drawRect(
      Rect.fromLTWH(0, 41, size.width, 30),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [K.cyan.withValues(alpha: 0.08), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 41, size.width, 30)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════
// PHYSICS EQUIPMENT PAINTER
// ═══════════════════════════════════════════════════════
class PhysicsEquipmentPainter extends CustomPainter {
  final EqShape shape;
  final Size size;
  final Color liquidColor;
  final double fillRatio;
  final EquipmentData equipment;
  final bool isHeating;
  final bool isStirring;
  final double stirAngle;

  PhysicsEquipmentPainter({
    required this.shape,
    required this.size,
    required this.liquidColor,
    required this.fillRatio,
    required this.equipment,
    required this.isHeating,
    required this.isStirring,
    required this.stirAngle,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    // Center the equipment in the canvas
    final offset = Offset(
      (canvasSize.width - size.width) / 2,
      (canvasSize.height - size.height) / 2 + 20,
    );

    // Translate to equipment position
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final path = _buildPath();

    // 1. Drop shadow (ground)
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.1,
        size.height * 0.96,
        size.width * 0.8,
        size.height * 0.06,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // 2. Glass background
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.04),
          ],
        ).createShader(Offset.zero & size),
    );

    // 3. Liquid + particles inside
    canvas.save();
    canvas.clipPath(path);

    if (fillRatio > 0) {
      _paintLiquid(canvas);
      _paintLiquidParticles(canvas);
      _paintPrecipitateParticles(canvas);
    }

    // Bubbles (buoyancy)
    _paintBubbles(canvas);

    // Steam (rising from top)
    _paintSteam(canvas);

    // Sparks (with gravity)
    _paintSparks(canvas);

    // Stirring rod
    if (isStirring) _paintStirRod(canvas);

    // Heating glow at bottom
    if (isHeating && fillRatio > 0) _paintHeatGlow(canvas);

    canvas.restore();

    // 4. Glass outline
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white.withValues(alpha: 0.8),
    );

    // 5. Glass shine highlights
    _paintGlassShine(canvas);

    // 6. Measurement marks
    _paintMarks(canvas);

    canvas.restore();
  }

  Path _buildPath() {
    final w = size.width;
    final h = size.height;
    final path = Path();

    switch (shape) {
      case EqShape.beaker:
        path.moveTo(w * 0.08, h * 0.06);
        path.lineTo(w * 0.86, h * 0.06);
        path.lineTo(w * 0.94, h * 0.09);
        path.lineTo(w * 0.88, h * 0.12);
        path.lineTo(w * 0.92, h * 0.12);
        path.lineTo(w * 0.92, h * 0.9);
        path.quadraticBezierTo(w * 0.92, h * 0.96, w * 0.82, h * 0.96);
        path.lineTo(w * 0.18, h * 0.96);
        path.quadraticBezierTo(w * 0.08, h * 0.96, w * 0.08, h * 0.9);
        path.close();
        break;
      case EqShape.flask:
        path.moveTo(w * 0.38, h * 0.04);
        path.lineTo(w * 0.62, h * 0.04);
        path.lineTo(w * 0.62, h * 0.24);
        path.quadraticBezierTo(w * 0.98, h * 0.55, w * 0.98, h * 0.84);
        path.quadraticBezierTo(w * 0.98, h * 0.96, w * 0.82, h * 0.96);
        path.lineTo(w * 0.18, h * 0.96);
        path.quadraticBezierTo(w * 0.02, h * 0.96, w * 0.02, h * 0.84);
        path.quadraticBezierTo(w * 0.02, h * 0.55, w * 0.38, h * 0.24);
        path.close();
        break;
      case EqShape.testTube:
        path.moveTo(w * 0.18, h * 0.04);
        path.lineTo(w * 0.82, h * 0.04);
        path.lineTo(w * 0.86, h * 0.07);
        path.lineTo(w * 0.82, h * 0.08);
        path.lineTo(w * 0.82, h * 0.82);
        path.quadraticBezierTo(w * 0.82, h * 0.96, w * 0.5, h * 0.96);
        path.quadraticBezierTo(w * 0.18, h * 0.96, w * 0.18, h * 0.82);
        path.lineTo(w * 0.18, h * 0.08);
        path.close();
        break;
      case EqShape.cylinder:
        path.moveTo(w * 0.3, h * 0.04);
        path.lineTo(w * 0.7, h * 0.04);
        path.lineTo(w * 0.74, h * 0.07);
        path.lineTo(w * 0.7, h * 0.08);
        path.lineTo(w * 0.7, h * 0.85);
        path.lineTo(w * 0.92, h * 0.93);
        path.lineTo(w * 0.92, h * 0.96);
        path.lineTo(w * 0.08, h * 0.96);
        path.lineTo(w * 0.08, h * 0.93);
        path.lineTo(w * 0.3, h * 0.85);
        path.lineTo(w * 0.3, h * 0.08);
        path.close();
        break;
    }
    return path;
  }

  // ═══════════════════════════════════════════════════════
  // LIQUID with realistic meniscus
  // ═══════════════════════════════════════════════════════
  void _paintLiquid(Canvas canvas) {
    final top = size.height * (1 - 0.9 * fillRatio) - size.height * 0.02;
    final rect = Rect.fromLTWH(0, top, size.width, size.height - top);

    // Liquid gradient
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            liquidColor.withValues(alpha: 0.55),
            liquidColor.withValues(alpha: 0.85),
            liquidColor.withValues(alpha: 0.98),
          ],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(rect),
    );

    // Meniscus curve at top (physics!)
    final meniscus = Path()
      ..moveTo(0, top)
      ..quadraticBezierTo(size.width * 0.5, top + 4, size.width, top);
    canvas.drawPath(
      meniscus,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = liquidColor.withValues(alpha: 0.9),
    );

    // Surface highlight
    canvas.drawRect(
      Rect.fromLTWH(0, top, size.width, 2.5),
      Paint()..color = Colors.white.withValues(alpha: 0.6),
    );
  }

  // ═══════════════════════════════════════════════════════
  // LIQUID PARTICLES (swirling motion)
  // ═══════════════════════════════════════════════════════
  void _paintLiquidParticles(Canvas canvas) {
    final top = size.height * (1 - 0.9 * fillRatio) - size.height * 0.02;
    final liquidHeight = size.height - top;

    for (final p in equipment.liquidParticles) {
      final x = p.x * size.width;
      final y = top + p.y * liquidHeight;
      canvas.drawCircle(
        Offset(x, y),
        p.size,
        Paint()..color = p.color.withValues(alpha: 0.5),
      );
    }
  }

  // ═══════════════════════════════════════════════════════
  // BUBBLES with buoyancy (rise + wobble + fade)
  // ═══════════════════════════════════════════════════════
  void _paintBubbles(Canvas canvas) {
    final top = size.height * (1 - 0.9 * fillRatio) - size.height * 0.02;
    final liquidHeight = size.height - top;

    for (final b in equipment.bubbles) {
      final x = b.x * size.width;
      final y = top + b.y * liquidHeight;
      if (y < top - 5 || y > size.height) continue;
      final opacity = b.life.clamp(0.0, 1.0);

      // Bubble fill (transparent)
      canvas.drawCircle(
        Offset(x, y),
        b.size,
        Paint()..color = Colors.white.withValues(alpha: opacity * 0.25),
      );
      // Bubble border
      canvas.drawCircle(
        Offset(x, y),
        b.size,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = Colors.white.withValues(alpha: opacity * 0.9),
      );
      // Highlight dot
      canvas.drawCircle(
        Offset(x - b.size * 0.3, y - b.size * 0.3),
        b.size * 0.25,
        Paint()..color = Colors.white.withValues(alpha: opacity),
      );
    }
  }

  // ═══════════════════════════════════════════════════════
  // STEAM (rising particles, blur)
  // ═══════════════════════════════════════════════════════
  void _paintSteam(Canvas canvas) {
    for (final s in equipment.steamParticles) {
      final x = s.x * size.width;
      final y = s.y * size.height * 0.6 - 20;
      final opacity = s.life.clamp(0.0, 1.0) * 0.4;

      canvas.drawCircle(
        Offset(x, y),
        s.size,
        Paint()
          ..color = Colors.white.withValues(alpha: opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
  }

  // ═══════════════════════════════════════════════════════
  // SPARKS (with gravity)
  // ═══════════════════════════════════════════════════════
  void _paintSparks(Canvas canvas) {
    for (final s in equipment.sparks) {
      final x = s.x * size.width;
      final y = s.y * size.height;
      final opacity = s.life.clamp(0.0, 1.0);

      // Glow
      canvas.drawCircle(
        Offset(x, y),
        5,
        Paint()
          ..color = K.amber.withValues(alpha: opacity * 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      // Core
      canvas.drawCircle(
        Offset(x, y),
        2,
        Paint()..color = Colors.white.withValues(alpha: opacity),
      );
    }
  }

  // ═══════════════════════════════════════════════════════
  // PRECIPITATE (gravity settling at bottom)
  // ═══════════════════════════════════════════════════════
  void _paintPrecipitateParticles(Canvas canvas) {
    final top = size.height * (1 - 0.9 * fillRatio) - size.height * 0.02;
    final liquidHeight = size.height - top;

    for (final p in equipment.precipitateParticles) {
      final x = p.x * size.width;
      final y = top + p.y * liquidHeight;
      canvas.drawCircle(
        Offset(x, y),
        p.size,
        Paint()..color = p.color.withValues(alpha: 0.9),
      );
    }
  }

  // ═══════════════════════════════════════════════════════
  // STIR ROD (rotating)
  // ═══════════════════════════════════════════════════════
  void _paintStirRod(Canvas canvas) {
    final cx = size.width * 0.5 + sin(stirAngle) * size.width * 0.22;
    canvas.drawLine(
      Offset(cx, 0),
      Offset(cx, size.height * 0.85),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    // Highlight
    canvas.drawLine(
      Offset(cx - 1, 0),
      Offset(cx - 1, size.height * 0.85),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..strokeWidth = 1,
    );
  }

  // ═══════════════════════════════════════════════════════
  // HEAT GLOW (when heating - bottom orange glow)
  // ═══════════════════════════════════════════════════════
  void _paintHeatGlow(Canvas canvas) {
    final rect = Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ).createShader(rect),
    );
  }

  // ═══════════════════════════════════════════════════════
  // GLASS SHINE
  // ═══════════════════════════════════════════════════════
  void _paintGlassShine(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.16,
        size.height * 0.1,
        size.width * 0.05,
        size.height * 0.7,
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.8),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(
          size.width * 0.16, size.height * 0.1,
          size.width * 0.05, size.height * 0.7,
        )),
    );
  }

  // ═══════════════════════════════════════════════════════
  // MEASUREMENT MARKS
  // ═══════════════════════════════════════════════════════
  void _paintMarks(Canvas canvas) {
    final marks = switch (shape) {
      EqShape.beaker => [50, 100, 150, 200, 250],
      EqShape.flask => [50, 100, 150, 200, 250],
      EqShape.testTube => [10, 20, 30, 40, 50],
      EqShape.cylinder => [20, 40, 60, 80, 100],
    };

    for (int i = 0; i < marks.length; i++) {
      final y = size.height * (0.82 - (i / marks.length) * 0.68);
      final isLong = i.isEven;
      final w = isLong ? size.width * 0.18 : size.width * 0.1;

      canvas.drawLine(
        Offset(size.width - w - 3, y),
        Offset(size.width - 4, y),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.7)
          ..strokeWidth = 1.2,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: '${marks[i]}',
          style: TextStyle(
            fontSize: 7,
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width - w - tp.width - 6, y - 4));
    }
  }

  @override
  bool shouldRepaint(covariant PhysicsEquipmentPainter old) => true;
}

// ═══════════════════════════════════════════════════════
// ANIMATED TOOL PAINTER (with real-time animation)
// ═══════════════════════════════════════════════════════
class AnimatedToolPainter extends CustomPainter {
  final ToolShape shape;
  final bool isActive;
  final double time;

  AnimatedToolPainter({
    required this.shape,
    required this.isActive,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (shape) {
      case ToolShape.bunsenBurner: _bunsen(canvas, size); break;
      case ToolShape.thermometer: _thermo(canvas, size); break;
      case ToolShape.stirrer: _stirrer(canvas, size); break;
      case ToolShape.balance: _balance(canvas, size); break;
      case ToolShape.dropper: _dropper(canvas, size); break;
      case ToolShape.filtration: _funnel(canvas, size); break;
    }
  }

  void _bunsen(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Shadow
    canvas.drawOval(
      Rect.fromLTWH(w * 0.1, h * 0.94, w * 0.8, h * 0.06),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, h * 0.85, w, h * 0.13),
        const Radius.circular(4),
      ),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF475569), Color(0xFF1E293B)],
        ).createShader(Rect.fromLTWH(0, h * 0.85, w, h * 0.13)),
    );

    // Stem
    canvas.drawRect(
      Rect.fromLTWH(w * 0.38, h * 0.4, w * 0.24, h * 0.46),
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF64748B),
            const Color(0xFFCBD5E1),
            const Color(0xFF64748B),
          ],
        ).createShader(Rect.fromLTWH(w * 0.38, h * 0.4, w * 0.24, h * 0.46)),
    );

    if (isActive) {
      // Flame with flicker
      final flicker = sin(time * 12) * 3;
      final fh = h * 0.4 + flicker;

      // Outer orange glow
      final glowRect = Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.4 - fh * 0.4),
        width: w * 1.5,
        height: fh,
      );
      canvas.drawRect(
        glowRect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.orange.withValues(alpha: 0.5),
              Colors.transparent,
            ],
          ).createShader(glowRect),
      );

      // Outer flame
      final outer = Path()
        ..moveTo(w * 0.38, h * 0.4)
        ..quadraticBezierTo(w * 0.32, h * 0.4 - fh * 0.5, w * 0.5, h * 0.4 - fh)
        ..quadraticBezierTo(w * 0.68, h * 0.4 - fh * 0.5, w * 0.62, h * 0.4)
        ..close();
      canvas.drawPath(
        outer,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.yellow.withValues(alpha: 0.95),
              Colors.orange.withValues(alpha: 0.8),
              Colors.deepOrange.withValues(alpha: 0.4),
            ],
          ).createShader(Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.4 - fh * 0.3),
            width: w,
            height: fh,
          )),
      );

      // Inner blue flame
      final inner = Path()
        ..moveTo(w * 0.44, h * 0.4)
        ..quadraticBezierTo(w * 0.42, h * 0.4 - fh * 0.3, w * 0.5, h * 0.4 - fh * 0.5)
        ..quadraticBezierTo(w * 0.58, h * 0.4 - fh * 0.3, w * 0.56, h * 0.4)
        ..close();
      canvas.drawPath(
        inner,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.lightBlue.shade100,
              Colors.blue.shade600,
            ],
          ).createShader(Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.4 - fh * 0.25),
            width: w * 0.5,
            height: fh * 0.5,
          )),
      );

      // Heat waves
      for (int i = 0; i < 3; i++) {
        final wy = h * 0.15 - i * 10 + sin(time * 4 + i) * 3;
        final wave = Path()
          ..moveTo(w * 0.3, wy)
          ..quadraticBezierTo(w * 0.5, wy - 6, w * 0.7, wy);
        canvas.drawPath(
          wave,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = Colors.red.withValues(alpha: 0.3 - i * 0.08),
        );
      }
    }
  }

  void _thermo(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Shadow
    canvas.drawOval(
      Rect.fromLTWH(w * 0.15, h * 0.94, w * 0.7, h * 0.06),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Bulb
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.92),
      w * 0.35,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.red.shade600, Colors.red.shade900],
        ).createShader(Rect.fromCircle(
          center: Offset(w * 0.5, h * 0.92),
          radius: w * 0.35,
        )),
    );

    // Tube
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.4, h * 0.08, w * 0.2, h * 0.84),
        const Radius.circular(3),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );

    // Mercury column (varies with time if active)
    final level = isActive ? 0.5 + sin(time * 2) * 0.3 : 0.3;
    final mh = h * 0.6 * level;
    canvas.drawRect(
      Rect.fromLTWH(w * 0.44, h * 0.92 - mh, w * 0.12, mh),
      Paint()..color = Colors.red.shade700,
    );

    // Marks
    for (int i = 0; i < 10; i++) {
      final y = h * 0.15 + i * h * 0.075;
      canvas.drawLine(
        Offset(w * 0.6, y),
        Offset(w * 0.75, y),
        Paint()..color = Colors.grey.shade700..strokeWidth = 1,
      );
    }
  }

  void _stirrer(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Rod
    canvas.drawLine(
      Offset(w * 0.5, 0),
      Offset(w * 0.5, h * 0.85),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    // Highlight
    canvas.drawLine(
      Offset(w * 0.46, 0),
      Offset(w * 0.46, h * 0.85),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..strokeWidth = 1.5,
    );

    if (isActive) {
      // Rotating ring at top
      canvas.save();
      canvas.translate(w * 0.5, h * 0.1);
      canvas.rotate(time * 8);
      canvas.drawCircle(
        Offset.zero,
        w * 0.22,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = K.cyan,
      );
      // Blade
      canvas.drawLine(
        Offset(-w * 0.22, 0),
        Offset(w * 0.22, 0),
        Paint()
          ..color = K.cyan
          ..strokeWidth = 2,
      );
      canvas.restore();
    }
  }

  void _balance(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Body
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, h * 0.2, w, h * 0.8),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFCBD5E1), Color(0xFF64748B)],
        ).createShader(body.outerRect),
    );

    // Screen
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.15, h * 0.38, w * 0.7, h * 0.4),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF064E3B),
    );

    // Animated weight
    final weight = isActive ? (10 + sin(time * 3) * 5).toStringAsFixed(1) : '0.0';
    final tp = TextPainter(
      text: TextSpan(
        text: '$weight g',
        style: const TextStyle(
          color: Color(0xFF6EE7B7),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w * 0.5 - tp.width / 2, h * 0.5 - tp.height / 2));

    // Pan on top
    canvas.drawRect(
      Rect.fromLTWH(w * 0.1, h * 0.05, w * 0.8, h * 0.15),
      Paint()..color = const Color(0xFF475569),
    );
  }

  void _dropper(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Bulb
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.18),
      w * 0.35,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.grey.shade300, Colors.grey.shade600],
        ).createShader(Rect.fromCircle(
          center: Offset(w * 0.5, h * 0.18),
          radius: w * 0.35,
        )),
    );

    // Tube
    canvas.drawRect(
      Rect.fromLTWH(w * 0.4, h * 0.3, w * 0.2, h * 0.55),
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );

    // Liquid in tube
    canvas.drawRect(
      Rect.fromLTWH(w * 0.42, h * 0.55, w * 0.16, h * 0.28),
      Paint()..color = K.cyan.withValues(alpha: 0.6),
    );

    // Tip
    final tip = Path()
      ..moveTo(w * 0.4, h * 0.85)
      ..lineTo(w * 0.5, h * 0.98)
      ..lineTo(w * 0.6, h * 0.85)
      ..close();
    canvas.drawPath(tip, Paint()..color = Colors.grey.shade700);

    if (isActive) {
      // Falling drop (animation)
      final dp = (time * 0.8) % 1.0;
      canvas.drawCircle(
        Offset(w * 0.5, h * 0.98 + dp * 20),
        3,
        Paint()..color = K.cyan.withValues(alpha: 1 - dp),
      );
    }
  }


  void _funnel(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Cone
    final cone = Path()
      ..moveTo(w * 0.05, h * 0.15)
      ..lineTo(w * 0.95, h * 0.15)
      ..lineTo(w * 0.55, h * 0.6)
      ..lineTo(w * 0.45, h * 0.6)
      ..close();
    canvas.drawPath(
      cone,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.7),
            Colors.white.withValues(alpha: 0.3),
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      cone,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.grey.shade600,
    );

    // Filter paper
    final paper = Path()
      ..moveTo(w * 0.15, h * 0.18)
      ..lineTo(w * 0.85, h * 0.18)
      ..lineTo(w * 0.53, h * 0.55)
      ..lineTo(w * 0.47, h * 0.55)
      ..close();
    canvas.drawPath(paper, Paint()..color = Colors.white.withValues(alpha: 0.9));

    // Stem
    canvas.drawRect(
      Rect.fromLTWH(w * 0.46, h * 0.6, w * 0.08, h * 0.3),
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );

    if (isActive) {
      // Falling drop
      final dp = (time * 1.2) % 1.0;
      canvas.drawCircle(
        Offset(w * 0.5, h * 0.92 + dp * 10),
        2.5,
        Paint()..color = K.cyan.withValues(alpha: 1 - dp),
      );
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedToolPainter old) => true;
}

