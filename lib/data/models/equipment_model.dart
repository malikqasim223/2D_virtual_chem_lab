part of chem_lab;

class EquipItem {
  final String id;
  final EquipShape shape;
  Offset position;
  final List<ChemLayer> layers = [];
  final Set<LabEffect> effects = {};
  double temperature = 25.0;
  double targetTemp = 25.0;
  double pourAnim = 0;
  bool pourIsLiquid = true;
  double sloshAmp = 0;
  double reactionProgress = 0;
  double foamRamp = 0; // 0→1 smoothly after pour — prevents foam jump
  bool reactionComplete = false;
  double sloshPhase = 0;
  double stripColorProgress = 0.0; // 0-1 color development on litmus/pH paper
  Color pourColor = Colors.transparent;
  bool wasHeated = false;
  HeatingEffect? activeHeatingEffect;
  ReactionInfo? reaction; // Per-beaker reaction (audit fix)

  EquipItem({required this.id, required this.shape, required this.position});

  double get totalVolume => layers.fold(0.0, (a, b) => a + b.volume);
  double get liquidVolume => layers.fold(0.0, (a, b) => a + (b.isSolid ? b.volume * b.dissolveProgress : b.volume));
  double get solidVolume => layers.where((l) => l.isSolid).fold(0.0, (a, b) => a + b.volume * (1 - b.dissolveProgress));
  bool get hasLiquid => layers.any((l) => !l.isSolid);
  double get fillRatio => (liquidVolume / shape.maxVol).clamp(0.0, 1.0);
  bool get isHot => effects.contains(LabEffect.heat);
  bool get isCold => effects.contains(LabEffect.cool);
  bool get isStirring => effects.contains(LabEffect.stir);
  bool get hasThermo => effects.contains(LabEffect.thermometer);
  bool get hasDropper => effects.contains(LabEffect.dropper);
  bool get hasLitmus => effects.contains(LabEffect.litmus);
  bool get hasPhPaper => effects.contains(LabEffect.phPaper);
  bool get isHeatedTransform => wasHeated && temperature > 60;

  Color get blendedColor {
    if (layers.isEmpty) return Colors.transparent;
    final liquidLayers = layers.where((l) => !l.isSolid || l.dissolveProgress >= 1.0).toList();
    if (liquidLayers.isEmpty) return Colors.transparent;
    if (liquidLayers.length == 1) return liquidLayers.first.color;
    double r = 0, g = 0, b = 0, a = 0, total = 0;
    for (final l in liquidLayers) {
      r += (l.color.r * 255.0).round().clamp(0, 255) * l.volume;
      g += (l.color.g * 255.0).round().clamp(0, 255) * l.volume;
      b += (l.color.b * 255.0).round().clamp(0, 255) * l.volume;
      a += (l.color.a * 255.0).round().clamp(0, 255) * l.volume;
      total += l.volume;
    }
    if (total <= 0) return Colors.transparent;
    return Color.fromARGB((a/total).toInt(), (r/total).toInt(), (g/total).toInt(), (b/total).toInt());
  }

  void addChem(String id, Color color, double vol, {bool isSolid = false}) {
    final existing = layers.where((l) => l.chemId == id).toList();
    if (existing.isNotEmpty) {
      existing.first.volume = (existing.first.volume + vol).clamp(0.0, shape.maxVol);
    } else {
      layers.add(ChemLayer(chemId: id, color: color, volume: vol, isSolid: isSolid));
      reactionProgress = 0;
      reactionComplete = false;
    }
    double total = totalVolume;
    while (total > shape.maxVol && layers.isNotEmpty) {
      final l = layers.first;
      final over = total - shape.maxVol;
      if (l.volume <= over) { total -= l.volume; layers.removeAt(0); }
      else { l.volume -= over; total = shape.maxVol; }
    }
  }

  void clear() {
    layers.clear();
    effects.clear();
    temperature = 25.0;
    targetTemp = 25.0;
    pourAnim = 0.0;
    sloshAmp = 0.0;
    reactionProgress = 0.0;
    foamRamp = 0.0;
    reactionComplete = false;
    stripColorProgress = 0.0;
    pourColor = Colors.transparent;
    wasHeated = false;
    activeHeatingEffect = null;
    reaction = null;
  }
}




