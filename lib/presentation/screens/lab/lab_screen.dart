part of chem_lab;

class LabScreen extends StatefulWidget {
  const LabScreen({super.key});
  @override
  State<LabScreen> createState() => _LabScreenState();
}


class _LabScreenState extends State<LabScreen> with TickerProviderStateMixin {
  String category = 'All';
  final TextEditingController _invSearchCtrl = TextEditingController();
  String _invSearch = '';
  int navIndex = 1;
  bool showInventory = false;
  bool showToolbox = false;
  bool showExperiments = false;
  bool showChemInfo = false; // NEW: chemical encyclopedia
  String? selectedChemInfo; // currently viewed chemical
  String chemInfoSearch = ''; // search filter
  String chemInfoTab = 'PROPERTIES'; // active tab
  String experimentName = 'Neutralization Reaction';

  final List<EquipItem> equipment = [
    EquipItem(id: 'eq1', shape: EquipShape.beaker, position: const Offset(150, 30)),
    EquipItem(id: 'eq2', shape: EquipShape.flask, position: const Offset(400, 30)),
    EquipItem(id: 'eq3', shape: EquipShape.testTube, position: const Offset(650, 30)),
  ];
  final List<BenchTool> benchTools = [];

  Chemical? draggingChemical;
  LabEffect? draggingEffect;
  Offset dragPos = Offset.zero;
  OverlayEntry? dragOverlay;
  String? hoveredEquipId;
  String? activeEquipId;

  EquipItem? draggingEquip;
  Offset draggingEquipStart = Offset.zero;
  Offset draggingEquipCurrent = Offset.zero;
  BenchTool? draggingBenchTool;
  Offset draggingToolStart = Offset.zero;
  Offset draggingToolCurrent = Offset.zero;
  bool dustbinHover = false;

  ReactionInfo? currentReaction;
  Timer? _tick;
  late AnimationController _shakeCtrl;
  late AnimationController _flashCtrl;
  double _time = 0;
  Size _benchSize = const Size(800, 600);
  final GlobalKey _benchKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3485));
    _flashCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3485));
    _tick = Timer.periodic(const Duration(milliseconds: 33), (_) {
      if (!mounted) return;
      _time += 0.033;
      bool needs = false;
      for (final eq in equipment) {
        // Strip color animation — slow capillary action (like real lab)
        if (eq.effects.contains(LabEffect.litmus) || eq.effects.contains(LabEffect.phPaper)) {
          if (eq.stripColorProgress < 1.0 && eq.layers.isNotEmpty) {
            eq.stripColorProgress = (eq.stripColorProgress + 0.006).clamp(0.0, 1.0);
            needs = true;
          }
        } else {
          eq.stripColorProgress = 0.0;
        }
        // === Per-equipment chemistry ===
        String myKey = '';
        if (eq.layers.length >= 2) {
          myKey = (eq.layers.map((l) => l.chemId).toList()..sort()).join('+');
        } else if (eq.layers.length == 1 && eq.isHot) {
          myKey = eq.layers.first.chemId + '+heat';
        }
        // === Side effect (wrong combos with 3+) ===
        final chemIds = eq.layers.map((l) => l.chemId).toList();
        final sideFx = chemIds.length >= 3 ? detectSideEffect(chemIds) : null;
        if (sideFx != null && !eq.reactionComplete) {
          eq.reactionProgress = (eq.reactionProgress + 0.0009).clamp(0.0, 1.0);
          if (sideFx.heatUp) eq.temperature = (eq.temperature + 0.4).clamp(25.0, 150.0);
          if (sideFx.coolDown) eq.temperature = (eq.temperature - 0.4).clamp(0.0, 150.0);
          if (eq.reactionProgress >= 1.0) eq.reactionComplete = true;
          needs = true;
        } else {
          // === Normal reaction (2-chem or multi-reaction map) ===
          final hasReaction = reactions.containsKey(myKey) || multiReactions.containsKey(myKey);
          final rxnForThis = multiReactions[myKey] ?? reactions[myKey];
          if (hasReaction && !eq.reactionComplete) {
            // HEAT GATE â€” reactions requiring heat need Bunsen + temp >= 60C
            final needsHeat = rxnForThis?.requiresHeat == true;
            final hasEnoughHeat = eq.isHot && eq.temperature >= 60.0;
            if (needsHeat && !hasEnoughHeat) {
              // Heat required but not provided â€” skip for now
            } else {
              eq.reactionProgress = (eq.reactionProgress + 0.0004).clamp(0.0, 1.0);
              if (eq.reactionProgress >= 1.0) eq.reactionComplete = true;
              if (rxnForThis != null && rxnForThis.releasesHeat) {
                eq.temperature = (eq.temperature + 0.6).clamp(25.0, 150.0);
              }
              needs = true;
            }
          }
        }
        // === GRADUAL SOLID DISSOLVE (starts with reaction, ends at complete) ===
        if (eq.reactionProgress > 0.0) {
          for (final l in eq.layers) {
            if (l.isSolid && l.dissolveProgress < 1.0) {
              // Dissolve speed proportional to reaction progress
              // Reaches 1.0 when reactionProgress reaches 1.0
              // Slow start, then steady â€” smooth
              final targetDissolve = eq.reactionProgress;
              // Smoothly approach target (not instant)
              if (l.dissolveProgress < targetDissolve) {
                l.dissolveProgress = (l.dissolveProgress + 0.004).clamp(0.0, 1.0);
                needs = true;
              }
            }
          }
        }
        if (eq.pourAnim > 0) {
          eq.pourAnim = (eq.pourAnim - 0.022).clamp(0.0, 1.0);
          needs = true;
        }
        // FOAM RAMP â€” outside pourAnim check (independent, runs after pour)
        if (eq.pourAnim == 0.0 && eq.foamRamp < 1.0) {
          eq.foamRamp = (eq.foamRamp + 0.008).clamp(0.0, 1.0); // ~2s smooth rise
          needs = true;
        }

        // Tools ka continuous animation ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â stirrer/thermo/dropper/ice chalta rahe
        if (eq.effects.isNotEmpty) needs = true;
        // Temperature update
        if (eq.isHot || eq.isCold) {
          final diff = eq.targetTemp - eq.temperature;
          if (diff.abs() > 0.5) { // keep climbing until close
            final step = eq.isHot ? 1.0 : 1.0; // gradual heating
            final n = eq.temperature + (diff > 0 ? step : -step);
            eq.temperature = diff > 0
                ? (n < eq.targetTemp ? n : eq.targetTemp)
                : (n > eq.targetTemp ? n : eq.targetTemp);
            needs = true;
          }
        }
        if (!eq.isHot && !eq.isCold && eq.temperature > 25.0) {
          eq.temperature = (eq.temperature - 0.3).clamp(25.0, 300.0);
          needs = true;
        }
        if (eq.isHot && eq.temperature > 60) eq.wasHeated = true;
      }
      // CONTINUOUS ANIMATION â€” keep painting if any content visible
      if (!needs) {
        for (final eq in equipment) {
          if (eq.layers.isNotEmpty || eq.effects.isNotEmpty) { needs = true; break; }
        }
      }
      if (needs) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    dragOverlay?.remove();
    _shakeCtrl.dispose();
    _flashCtrl.dispose();
    _invSearchCtrl.dispose();
    super.dispose();
  }

  List<Chemical> get filteredChemicals {
    final q = _invSearch.trim().toLowerCase();
    return allChemicals.where((c) {
      final matchCat = (category == 'All') || (c.category == category);
      final matchSearch = q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          c.formula.toLowerCase().contains(q);
      return matchCat && matchSearch;
    }).toList();
  }

  void _recomputeReaction() {
    currentReaction = null;
    for (final eq in equipment) {
      if (eq.layers.length >= 2) {
        final ids = eq.layers.map((l) => l.chemId).toList()..sort();
        final key = ids.join('+');
        if (multiReactions.containsKey(key)) { currentReaction = multiReactions[key]; return; }
        if (reactions.containsKey(key)) { currentReaction = reactions[key]; return; }
        // Fallback: any 2-subset
        for (int i = 0; i < ids.length; i++) {
          for (int j = i + 1; j < ids.length; j++) {
            final pk = [ids[i], ids[j]].join('+');
            if (reactions.containsKey(pk)) { currentReaction = reactions[pk]; return; }
          }
        }
      }
    }
  }

  void addEquipment(EquipShape shape) {
    final x = 150.0 + (equipment.length * 150) % 600;
    setState(() {
      equipment.add(EquipItem(
        id: 'eq_${DateTime.now().microsecondsSinceEpoch}',
        shape: shape,
        position: Offset(x, 30),
      ));
    });
  }

  void removeEquipment(String id) {
    setState(() {
      equipment.removeWhere((e) => e.id == id);
      benchTools.removeWhere((t) => t.attachedTo == id);
      if (activeEquipId == id) activeEquipId = null;
      _recomputeReaction();
    });
  }

  void reset() {
    setState(() {
      for (final eq in equipment) { eq.clear(); }
      benchTools.clear();
      currentReaction = null;
      activeEquipId = null;
    });
  }

  void _startEquipDrag(EquipItem eq, DragStartDetails d) {
    setState(() {
      draggingEquip = eq;
      draggingEquipStart = eq.position;
      draggingEquipCurrent = Offset.zero;
    });
  }

  void _updateEquipDrag(DragUpdateDetails d) {
    if (draggingEquip == null) return;
    setState(() {
      draggingEquipCurrent += d.delta;
      final oldPos = draggingEquip!.position;
      draggingEquip!.position = draggingEquipStart + draggingEquipCurrent;
      final delta = draggingEquip!.position - oldPos;
      // Attached tools bhi saath move karein
      for (final tool in benchTools) {
        // Dipping tool — move dip targets with equipment         if (tool.isDipping && tool.dippedEqId == draggingEquip!.id) {           tool.dipStartPos += delta;           tool.dipTargetPos += delta;           tool.position += delta;           continue;         }
        if (tool.attachedTo == draggingEquip!.id) {
          tool.position += delta;
        }
      }
      draggingEquip!.sloshAmp = (draggingEquip!.sloshAmp + d.delta.dx.abs() * 0.15).clamp(0.0, 5.0);
    });
    final binRect = _dustbinRect();
    final eqRect = Rect.fromLTWH(draggingEquip!.position.dx, draggingEquip!.position.dy, 120, 150);
    final hover = binRect.overlaps(eqRect);
    if (hover != dustbinHover) setState(() => dustbinHover = hover);
  }

  void _endEquipDrag() {
    if (draggingEquip == null) return;
    if (dustbinHover) { removeEquipment(draggingEquip!.id); }
    else { _updateToolAttachments(); }
    setState(() { draggingEquip = null; dustbinHover = false; });
  }

  void _startToolDrag(BenchTool tool, DragStartDetails d) {
    setState(() {
      draggingBenchTool = tool;
      draggingToolStart = tool.position;
      draggingToolCurrent = Offset.zero;
    });
  }

  void _updateToolDrag(DragUpdateDetails d) {
    if (draggingBenchTool == null) return;
    setState(() {
      draggingToolCurrent += d.delta;
      draggingBenchTool!.position = draggingToolStart + draggingToolCurrent;
    });
    final binRect = _dustbinRect();
    final toolRect = Rect.fromLTWH(draggingBenchTool!.position.dx, draggingBenchTool!.position.dy, 70, 70);
    final hover = binRect.overlaps(toolRect);
    if (hover != dustbinHover) setState(() => dustbinHover = hover);
  }

  void _endToolDrag() {
    if (draggingBenchTool == null) return;
    if (dustbinHover) { _removeBenchTool(draggingBenchTool!.id); }
    else { _updateToolAttachments(); }
    setState(() { draggingBenchTool = null; dustbinHover = false; });
  }

  Rect _dustbinRect() => Rect.fromLTWH(_benchSize.width - 100, _benchSize.height - 120, 80, 100);

  void _addBenchTool(LabEffect type, Offset pos) {
    setState(() {
      benchTools.add(BenchTool(
        id: 'tool_${DateTime.now().microsecondsSinceEpoch}',
        type: type,
        position: pos - const Offset(27.5, 27.5),
      ));
      _updateToolAttachments();
    });
  }

  // Fixed positions on left side of bench for detached tools
  Offset _toolDockPosition(LabEffect type) {
    final idx = LabEffect.values.indexOf(type);
    return Offset(20, 105 + idx * 68);
  }

  void _detachTool(EquipItem eq, LabEffect type) {
    setState(() {
      final m = benchTools.where((t) => t.attachedTo == eq.id && t.type == type).toList();
      if (m.isNotEmpty) {
        final t = m.first;
        t.attachedTo = null;
        t.position = _toolDockPosition(t.type);
        _updateToolAttachments();
      }
    });
  }

  void _removeBenchTool(String id) {
    setState(() {
      benchTools.removeWhere((t) => t.id == id);
      _updateToolAttachments();
    });
  }


  void _updateToolAttachments() {
    for (final eq in equipment) { eq.effects.clear(); }
    for (final tool in benchTools) {
      final center = tool.position + const Offset(27.5, 27.5);
      String? found;
      for (final eq in equipment) {
        final s = eq.shape.size;
        final rect = Rect.fromLTWH(eq.position.dx - 20, eq.position.dy - 20,
            s.width + 40, s.height + 40);
        if (rect.contains(center) && eq.layers.isNotEmpty) { found = eq.id; break; }
      }
      tool.attachedTo = found;
      if (found != null) {
        final eq = equipment.firstWhere((e) => e.id == found);
        eq.effects.add(tool.type);
        if (tool.type == LabEffect.heat) eq.effects.remove(LabEffect.cool);
        if (tool.type == LabEffect.cool) eq.effects.remove(LabEffect.heat);
        if (tool.type == LabEffect.heat && eq.targetTemp < 25.0) eq.targetTemp = 25.0;
        if (tool.type == LabEffect.cool && eq.targetTemp > 0.0) eq.targetTemp = 0.0;
      }
    }
  }

  void startChemicalDrag(Chemical c, Offset pos) {
    draggingChemical = c;
    dragPos = pos;
    dragOverlay?.remove();
    dragOverlay = OverlayEntry(builder: (_) => Positioned(
      left: dragPos.dx - 30, top: dragPos.dy - 45,
      child: IgnorePointer(child: Material(color: Colors.transparent, child: _dragBottle(c))),
    ));
    Overlay.of(context).insert(dragOverlay!);
    setState(() {});
  }

  void updateChemicalDrag(Offset pos) {
    if (dragOverlay == null) return;
    dragPos = pos;
    dragOverlay!.markNeedsBuild();
    final hit = _equipUnderPoint(pos);
    if (hit != hoveredEquipId) setState(() => hoveredEquipId = hit);
  }

  void endChemicalDrag() {
    dragOverlay?.remove();
    dragOverlay = null;
    final hit = _equipUnderPoint(dragPos);
        if (hit != null && draggingChemical != null) _showAmountAndPour(hit, draggingChemical!);
    setState(() { draggingChemical = null; hoveredEquipId = null; });
  }

  void startEffectDrag(LabEffect effect, Offset pos) {
    draggingEffect = effect;
    dragPos = pos;
    dragOverlay?.remove();
    dragOverlay = OverlayEntry(builder: (_) => Positioned(
      left: dragPos.dx - 22, top: dragPos.dy - 22,
      child: IgnorePointer(child: Material(color: Colors.transparent,
        child: Icon(effect.icon, color: effect.color, size: 44))),
    ));
    Overlay.of(context).insert(dragOverlay!);
    setState(() {});
  }

  void updateEffectDrag(Offset pos) {
    if (dragOverlay == null) return;
    dragPos = pos;
    dragOverlay!.markNeedsBuild();
  }

  void endEffectDrag() {
    dragOverlay?.remove();
    dragOverlay = null;
    final benchBox = _benchKey.currentContext?.findRenderObject() as RenderBox?;
    if (benchBox != null && draggingEffect != null) {
      final local = benchBox.globalToLocal(dragPos);
      if (local.dx > 0 && local.dy > 0 && local.dx < benchBox.size.width && local.dy < benchBox.size.height) {
        _addBenchTool(draggingEffect!, local);
      }
    }
    setState(() => draggingEffect = null);
  }

  String? _equipUnderPoint(Offset globalPos) {
    final benchBox = _benchKey.currentContext?.findRenderObject() as RenderBox?;
    if (benchBox == null) return null;
    final local = benchBox.globalToLocal(globalPos);
    for (final eq in equipment) {
      final s = eq.shape.size;
      final rect = Rect.fromLTWH(eq.position.dx - 20, eq.position.dy - 20, s.width + 40, s.height + 40);
      if (rect.contains(local)) return eq.id;
    }
    return null;
  }

  Future<void> _showAmountAndPour(String equipId, Chemical c) async {
    final amount = await showDialog<double>(
      context: context,
      barrierDismissible: false, // outside click se band nahi hoga
      builder: (_) => AmountPickerDialog(chemical: c),
    );
    if (amount != null) _pourInto(equipId, c, amount);
  }

  void _pourInto(String equipId, Chemical c, double amount) {
    setState(() {
      final eq = equipment.firstWhere((e) => e.id == equipId);
      eq.addChem(c.id, c.color, amount, isSolid: c.state == 'Solid');
      eq.pourAnim = 1.0;
      eq.pourIsLiquid = c.state == 'Liquid';
      eq.foamRamp = 0; // Reset foam ramp â€” will grow smoothly after pour
      eq.pourColor = c.color;
      activeEquipId = equipId;
      _recomputeReaction(); // Original timing â€” blast fires immediately
      final _rxnCheck = _reactionFor(eq);
      if (_rxnCheck != null && _rxnCheck.isViolent) {
        _flashCtrl.forward(from: 0);
        _shakeCtrl.forward(from: 0);
      }
    });
  }

  Widget _dragBottle(Chemical c) => SizedBox(width: 60, height: 90,
    child: CustomPaint(painter: DragBottlePainter(color: c.color)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: LC.bgDeep,
      body: AnimatedBuilder(
        animation: _shakeCtrl,
        builder: (context, child) {
          final t = _shakeCtrl.value;
          // Shake intensity curve â€” matches flash (build up -> peak -> fade out)
          double shakeIntensity;
          if (t < 0.40) {
            final ft = t / 0.40;
            shakeIntensity = ft * ft; // Fade in (build up)
          } else if (t < 0.58) {
            shakeIntensity = 1.0; // Peak (same as flash peak)
          } else {
            final ft = (t - 0.65) / 0.35;
            shakeIntensity = (1 - ft) * (1 - ft) * (1 - ft); // Fade out
          }
          // High frequency shake modulated by intensity
          final freq = t * 60;
          final dx = sin(freq) * 30 * shakeIntensity;
          final dy = cos(freq * 0.9) * 22 * shakeIntensity;
          final rot = sin(freq * 0.7) * 0.02 * shakeIntensity;
          return Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.rotate(
              angle: rot,
              child: Stack(
                children: [
                  Column(children: [
                    _topBar(),
                    Expanded(child: Row(children: [
                      _sidebar(),
                      if (showInventory) _inventoryPanel(),
                      if (showExperiments) _experimentsPanel(),
          if (showChemInfo) _chemInfoPanel(),
                      Expanded(child: _labArea()),
                      if (showToolbox) _toolboxPanel(),
                    ])),
                  ]),
                  IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _flashCtrl,
                      builder: (_, __) {
                        final v = _flashCtrl.value;
                        if (v == 0 || v >= 1) return const SizedBox.shrink();
                        double intensity;
                        if (v < 0.40) {
                          final ft = v / 0.40;
                          intensity = ft * ft;
                        } else if (v < 0.65) {
                          intensity = 1.0;
                        } else {
                          final ft = (v - 0.65) / 0.35;
                          intensity = (1 - ft) * (1 - ft) * (1 - ft);
                        }
                        Color flashColor;
                        if (v < 0.45) {
                          flashColor = Colors.white;
                        } else if (v < 0.75) {
                          flashColor = Color.lerp(Colors.white, const Color(0xFFFFEB3B), (v - 0.45) / 0.30)!;
                        } else if (v < 0.95) {
                          flashColor = Color.lerp(const Color(0xFFFFEB3B), const Color(0xFFFF6B35), (v - 0.75) / 0.20)!;
                        } else {
                          flashColor = Color.lerp(const Color(0xFFFF6B35), Colors.transparent, (v - 0.95) / 0.05)!;
                        }
                        return Container(color: flashColor.withValues(alpha: intensity.clamp(0.0, 1.0)));
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    return Container(height: 60,
      decoration: const BoxDecoration(color: LC.bg,
        border: Border(bottom: BorderSide(color: LC.border))),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(children: [
        Container(width: 38, height: 38,
          decoration: BoxDecoration(color: LC.panelElev,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: LC.borderSoft)),
          child: const Icon(Icons.science, color: LC.accentBright, size: 20)),
        const SizedBox(width: 12),
        const Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Virtual Chemistry Lab',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LC.text)),
            SizedBox(height: 2),
            Text('Explore / Experiment / Learn',
              style: TextStyle(color: LC.textDim, fontSize: 10)),
          ]),
        const SizedBox(width: 30),
        Expanded(child: Container(height: 34,
          decoration: BoxDecoration(color: LC.panel,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: LC.border)),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(children: const [
            Icon(Icons.search, color: LC.textDim, size: 15),
            SizedBox(width: 8),
            Expanded(child: Text('Search chemicals, experiments...',
              style: TextStyle(color: LC.textDim, fontSize: 11))),
          ]))),
        const SizedBox(width: 16),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: LC.panel,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: LC.border)),
          child: Row(children: const [
            Icon(Icons.person, color: LC.accentBright, size: 14),
            SizedBox(width: 6),
            Text('Student', style: TextStyle(color: LC.text, fontSize: 10)),
          ])),
      ]));
  }

  Widget _topBar() {
    return Container(height: 60,
      decoration: const BoxDecoration(color: LC.bg,
        border: Border(bottom: BorderSide(color: LC.border))),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(children: [
        Container(width: 38, height: 38,
          decoration: BoxDecoration(color: LC.panelElev,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: LC.borderSoft)),
          child: const Icon(Icons.science, color: LC.accentBright, size: 20)),
        const SizedBox(width: 12),
        const Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Virtual Chemistry Lab',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LC.text)),
            SizedBox(height: 2),
            Text('Explore / Experiment / Learn',
              style: TextStyle(color: LC.textDim, fontSize: 10)),
          ]),
        const SizedBox(width: 30),
        Expanded(child: Container(height: 34,
          decoration: BoxDecoration(color: LC.panel,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: LC.border)),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(children: const [
            Icon(Icons.search, color: LC.textDim, size: 15),
            SizedBox(width: 8),
            Expanded(child: Text('Search chemicals, experiments...',
              style: TextStyle(color: LC.textDim, fontSize: 11))),
          ]))),
        const SizedBox(width: 16),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: LC.panel,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: LC.border)),
          child: Row(children: const [
            Icon(Icons.person, color: LC.accentBright, size: 14),
            SizedBox(width: 6),
            Text('Student', style: TextStyle(color: LC.text, fontSize: 10)),
          ])),
      ]));
  }

  Widget _sidebar() {
    final items = [
      (Icons.home_outlined, 'Home', -1),
      (Icons.science_outlined, 'Virtual Lab', -1),
      (Icons.biotech_outlined, 'Experiments', 2),
      (Icons.inventory_2_outlined, 'Inventory', 0),
    (Icons.menu_book_outlined, 'Chem Info', 3),
      (Icons.build_circle_outlined, 'Toolbox', 1),
      (Icons.history, 'History', -1),
      (Icons.settings_outlined, 'Settings', -1),
    ];
    return Container(width: 130,
      decoration: const BoxDecoration(color: LC.bg,
        border: Border(right: BorderSide(color: LC.border))),
      child: Column(children: [
        const SizedBox(height: 14),
        ...items.asMap().entries.map((e) {
          final active = navIndex == e.key;
          return GestureDetector(
            onTap: () => setState(() {
              navIndex = e.key;
              if (e.value.$3 == 0) {
                showInventory = !showInventory;
                if (showInventory) { showToolbox = false; showExperiments = false; }
              } else if (e.value.$3 == 1) {
                showToolbox = !showToolbox;
                if (showToolbox) { showInventory = false; showExperiments = false; }
              } else if (e.value.$3 == 2) {
                showExperiments = !showExperiments;
                if (showExperiments) { showInventory = false; showToolbox = false; }
              }
              else if (e.value.$3 == 3) {
                showChemInfo = !showChemInfo;
                if (showChemInfo) { showInventory = false; showToolbox = false; showExperiments = false; }
              }
            }),
            child: AnimatedContainer(duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: active ? LC.panelElev : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: active ? Border.all(color: LC.borderSoft) : null),
              child: Row(children: [
                Icon(e.value.$1, size: 17, color: active ? LC.accentBright : LC.textSub),
                const SizedBox(width: 10),
                Expanded(child: Text(e.value.$2,
                  style: TextStyle(color: active ? LC.text : LC.textSub,
                    fontSize: 11, fontWeight: active ? FontWeight.w600 : FontWeight.w400))),
              ])));
        }),
        const Spacer(),
        Container(margin: const EdgeInsets.all(10), padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: LC.panel,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: LC.border)),
          child: const Column(children: [
            Icon(Icons.science, color: LC.accent, size: 22),
            SizedBox(height: 8),
            Text('Small\nExperiments\nBig\nDiscoveries',
              textAlign: TextAlign.center,
              style: TextStyle(color: LC.textDim, fontSize: 9, height: 1.5)),
          ])),
      ]));
  }

  Widget _experimentsPanel() {
    return Container(width: 300,
      decoration: const BoxDecoration(color: LC.panel,
        border: Border(right: BorderSide(color: LC.border))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
          child: Row(children: [
            const Icon(Icons.biotech_outlined, size: 14, color: LC.accentBright),
            const SizedBox(width: 10),
            const Text('Manual Experiments',
              style: TextStyle(color: LC.text, fontSize: 12, fontWeight: FontWeight.w600)),
            const Spacer(),
            GestureDetector(onTap: () => setState(() => showExperiments = false),
              child: const Icon(Icons.close, color: LC.textDim, size: 15)),
          ])),
        Container(height: 1, color: LC.border),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          itemCount: allExperiments.length,
          itemBuilder: (_, i) => _experimentCard(allExperiments[i]))),
      ]));
  }

  Widget _experimentCard(LabExperiment exp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: LC.panelElev,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LC.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 22, height: 22,
            decoration: BoxDecoration(
              color: LC.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4)),
            child: Center(child: Text('${allExperiments.indexOf(exp) + 1}',
              style: const TextStyle(color: LC.accentBright, fontSize: 10,
                fontWeight: FontWeight.w700)))),
          const SizedBox(width: 8),
          Expanded(child: Text(exp.name,
            style: const TextStyle(color: LC.text, fontSize: 11,
              fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 6),
        Text(exp.description,
          style: const TextStyle(color: LC.textSub, fontSize: 9, height: 1.4)),
        const SizedBox(height: 8),
        const Text('STEPS',
          style: TextStyle(color: LC.textMuted, fontSize: 8,
            fontWeight: FontWeight.w600, letterSpacing: 1.0)),
        const SizedBox(height: 4),
        ...exp.steps.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${e.key + 1}. ',
              style: const TextStyle(color: LC.accentBright, fontSize: 9)),
            Expanded(child: Text(e.value,
              style: const TextStyle(color: LC.textSub, fontSize: 9, height: 1.3))),
          ]))),
        const SizedBox(height: 8),
        const Text('CHEMICALS',
          style: TextStyle(color: LC.textMuted, fontSize: 8,
            fontWeight: FontWeight.w600, letterSpacing: 1.0)),
        const SizedBox(height: 4),
        Wrap(spacing: 4, runSpacing: 4,
          children: exp.chemicals.map((c) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: LC.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: LC.accent.withValues(alpha: 0.4))),
            child: Text(c, style: const TextStyle(color: LC.accentBright,
              fontSize: 8, fontWeight: FontWeight.w500)),
          )).toList()),
        const SizedBox(height: 8),
        Container(width: double.infinity,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: LC.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: LC.success.withValues(alpha: 0.3))),
          child: Row(children: [
            const Icon(Icons.science, size: 10, color: LC.success),
            const SizedBox(width: 5),
            Expanded(child: Text(exp.expectedResult,
              style: const TextStyle(color: LC.success, fontSize: 9,
                fontWeight: FontWeight.w500))),
          ])),
      ]));
  }
  
  
  
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // CHEM INFO PANEL â€” reference style
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _chemInfoPanel() {
    final filtered = allChemicals.where((c) {
      if (chemInfoSearch.isEmpty) return true;
      final q = chemInfoSearch.toLowerCase();
      return c.name.toLowerCase().contains(q) || c.formula.toLowerCase().contains(q);
    }).toList();
    final selected = selectedChemInfo != null
        ? allChemicals.firstWhere((c) => c.id == selectedChemInfo, orElse: () => allChemicals.first)
        : null;
    final detail = selected != null ? chemDetails[selected.id] : null;
    return Container(width: 640,
      decoration: const BoxDecoration(color: LC.panel,
        border: Border(right: BorderSide(color: LC.border))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // HEADER
        Container(padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
          child: Row(children: [
            const Icon(Icons.menu_book_rounded, size: 20, color: LC.accentBright),
            const SizedBox(width: 10),
            const Text('Chemical Encyclopedia',
              style: TextStyle(color: LC.text, fontSize: 16, fontWeight: FontWeight.w700)),
            const Spacer(),
            GestureDetector(onTap: () => setState(() => showChemInfo = false),
              child: Container(width: 30, height: 30,
                decoration: BoxDecoration(color: LC.panelElev,
                  borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.close, color: LC.textDim, size: 16))),
          ])),
        Container(height: 1, color: LC.border),
        Expanded(child: Row(children: [
          // LEFT: Chem list
          Container(width: 180,
            decoration: BoxDecoration(border: Border(right: BorderSide(color: LC.border))),
            child: Column(children: [
              Padding(padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Container(height: 38,
                  decoration: BoxDecoration(color: LC.panelElev,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: LC.border)),
                  child: TextField(
                    onChanged: (v) => setState(() => chemInfoSearch = v),
                    style: const TextStyle(color: LC.text, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: LC.textDim, fontSize: 11),
                      prefixIcon: const Icon(Icons.search, size: 16, color: LC.textDim),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ))),
              Expanded(child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: filtered.length,
                itemBuilder: (ctx, idx) {
                  final c = filtered[idx];
                  final active = selectedChemInfo == c.id;
                  return GestureDetector(
                    onTap: () => setState(() { selectedChemInfo = c.id; chemInfoTab = 'PROPERTIES'; }),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? LC.panelElev : Colors.transparent,
                        borderRadius: BorderRadius.circular(6)),
                      child: Row(children: [
                        Container(width: 3, height: 28,
                          decoration: BoxDecoration(color: c.color,
                            borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(c.formula,
                            style: TextStyle(
                              color: active ? LC.accentBright : LC.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                          Text(c.name,
                            style: TextStyle(color: LC.textDim, fontSize: 10),
                            overflow: TextOverflow.ellipsis),
                        ])),
                      ]),
                    ),
                  );
                })),
            ]),
          ),
          // RIGHT: Details (reference style)
          Expanded(child: selected == null
            ? Center(child: Text('Select a chemical',
                style: TextStyle(color: LC.textDim, fontSize: 14)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Chem name (big)
                  Text(selected.name,
                    style: const TextStyle(color: LC.text, fontSize: 26,
                      fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  // Molecule diagram + data table (side by side)
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Molecule
                    if (detail?.atoms != null && detail!.atoms!.isNotEmpty)
                      Container(width: 200, height: 150,
                        child: CustomPaint(
                          painter: MoleculePainter(
                            atoms: detail.atoms!,
                            bonds: detail.bonds ?? [],
                          ),
                        )),
                    const SizedBox(width: 12),
                    // Data table
                    Expanded(child: Column(children: [
                      _dataRow('Molar Mass', detail?.molarMass != null ? '${detail!.molarMass} g/mol' : 'â€”'),
                      if (detail?.boilingPoint != null)
                        _dataRow('Boiling Point', '${detail!.boilingPoint}Â°C'),
                      if (detail?.meltingPoint != null)
                        _dataRow('Melting Point', '${detail!.meltingPoint}Â°C'),
                      if (detail?.density != null)
                        _dataRow('Density', '${detail!.density} g/cmÂ³'),
                      if (detail?.ph != null)
                        _dataRow('pH', detail!.ph!),
                      if (detail?.hazards != null && detail!.hazards.isNotEmpty)
                        _dataRow('Hazards', detail.hazards.join(', ')),
                    ])),
                  ]),
                  const SizedBox(height: 20),
                  // TABS
                  if (detail != null) ...[
                    Row(children: [
                      _chemTab('PROPERTIES', const Color(0xFF4A90E2)),
                      _chemTab('USES', const Color(0xFF4CAF50)),
                      _chemTab('SAFETY', const Color(0xFFE85D5D)),
                    ]),
                    Container(height: 2, color: LC.border),
                    const SizedBox(height: 16),
                    // Tab content
                    if (chemInfoTab == 'PROPERTIES') ...[
                      _refCard(Icons.info_outline, 'Properties', detail.properties, const Color(0xFF2196F3)),
                      if (detail.reactions != null)
                        _refCard(Icons.compare_arrows, 'Key Reactions', detail.reactions!, const Color(0xFF9C27B0)),
                    ] else if (chemInfoTab == 'USES') ...[
                      _refCard(Icons.science_outlined, 'Uses', detail.uses, const Color(0xFF4CAF50)),
                      if (detail.industrial != null)
                        _refCard(Icons.factory_outlined, 'Industrial', detail.industrial!, const Color(0xFF607D8B)),
                    ] else ...[
                      _refCard(Icons.warning_amber_rounded, 'Safety', detail.safety, const Color(0xFFF44336)),
                      if (detail.history != null)
                        _refCard(Icons.history_edu, 'History', detail.history!, const Color(0xFF8BC34A)),
                    ],
                    const SizedBox(height: 16),
                    // Bottom cards
                    Row(children: [
                      if (detail.commonName != null)
                        Expanded(child: _refCard(Icons.label_outline, 'COMMON NAME', detail.commonName!, const Color(0xFF00BCD4))),
                      if (detail.commonName != null && detail.appearance != null)
                        const SizedBox(width: 12),
                      if (detail.appearance != null)
                        Expanded(child: _refCard(Icons.visibility_outlined, 'APPEARANCE', detail.appearance!, const Color(0xFF3F51B5))),
                    ]),
                    if (detail.occurrence.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _refCard(Icons.public_outlined, 'Occurrence', detail.occurrence, const Color(0xFF795548)),
                    ],
                  ],
                ]),
              ),
          ),
        ])),
      ]),
    );
  }
  
  Widget _dataRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF14141E),
        border: Border(bottom: BorderSide(color: LC.border, width: 0.5))),
      child: Row(children: [
        Text(label,
          style: TextStyle(color: LC.textSub, fontSize: 13,
            fontWeight: FontWeight.w500)),
        const Spacer(),
        Flexible(child: Text(value,
          style: const TextStyle(color: LC.text, fontSize: 13,
            fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis, textAlign: TextAlign.end)),
      ]),
    );
  }
  
  Widget _chemTab(String tabName, Color color) {
    final active = chemInfoTab == tabName;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => chemInfoTab = tabName),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(
            color: active ? color : Colors.transparent,
            width: 3))),
        child: Text(tabName,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? color : LC.textDim,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8)),
      ),
    ));
  }
  
  Widget _bullets(String content) {
    final items = content.split(' | ').where((s) => s.trim().isNotEmpty).toList();
    if (items.length <= 1) {
      return Text(content,
        style: TextStyle(color: LC.text, fontSize: 13, height: 1.5));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            width: 5, height: 5,
            decoration: BoxDecoration(
              color: LC.accentBright,
              shape: BoxShape.circle)),
          Expanded(child: Text(item.trim(),
            style: TextStyle(color: LC.text, fontSize: 13, height: 1.5))),
        ]),
      )).toList());
  }
  
  Widget _refCard(IconData icon, String title, String content, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14141E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: LC.border, width: 0.5)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 34, height: 34,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 17, color: accentColor)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title.toUpperCase(),
            style: TextStyle(color: accentColor, fontSize: 11,
              fontWeight: FontWeight.w800, letterSpacing: 1.0)),
          const SizedBox(height: 6),
          _bullets(content),
        ])),
      ]),
    );
  }
  
  Widget _inventoryPanel() {
    return Container(width: 280,
      decoration: const BoxDecoration(color: LC.panel,
        border: Border(right: BorderSide(color: LC.border))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
          child: Row(children: [
            const Icon(Icons.inventory_2_outlined, size: 14, color: LC.accentBright),
            const SizedBox(width: 10),
            const Text('Chemical Inventory',
              style: TextStyle(color: LC.text, fontSize: 12, fontWeight: FontWeight.w600)),
            const Spacer(),
            GestureDetector(onTap: () => setState(() => showInventory = false),
              child: const Icon(Icons.close, color: LC.textDim, size: 15)),
          ])),
        Container(height: 1, color: LC.border),
        Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Container(height: 30,
            decoration: BoxDecoration(color: LC.panelElev,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: LC.border)),
            child: Row(children: [
              const SizedBox(width: 8),
              const Icon(Icons.search, size: 14, color: LC.textDim),
              const SizedBox(width: 6),
              Expanded(child: TextField(
                controller: _invSearchCtrl,
                onChanged: (v) => setState(() => _invSearch = v),
                style: const TextStyle(color: LC.text, fontSize: 11),
                decoration: const InputDecoration(
                  hintText: 'Search chemical...',
                  hintStyle: TextStyle(color: LC.textDim, fontSize: 11),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8)),
              )),
              if (_invSearch.isNotEmpty)
                GestureDetector(onTap: () {
                  _invSearchCtrl.clear();
                  setState(() => _invSearch = '');
                }, child: const Padding(padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.close, size: 13, color: LC.textDim))),
            ]))),
        Padding(padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: SizedBox(height: 28,
            child: ListView(scrollDirection: Axis.horizontal,
              children: ['All', 'Acids', 'Bases', 'Salts', 'Others'].map((c) {
                final active = category == c;
                return Padding(padding: const EdgeInsets.only(right: 4),
                  child: GestureDetector(onTap: () => setState(() => category = c),
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: active ? LC.accent : LC.panelElev,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: active ? LC.accentBright : LC.border)),
                      alignment: Alignment.center,
                      child: Text(c, style: TextStyle(
                        color: active ? LC.bgDeep : LC.textSub,
                        fontSize: 10,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400)))));
              }).toList()))),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 4, 8, 12),
          itemCount: filteredChemicals.length,
          itemBuilder: (_, i) => _chemTile(filteredChemicals[i]))),
      ]));
  }

  Widget _chemTile(Chemical c) {
    return MouseRegion(cursor: SystemMouseCursors.grab,
      child: GestureDetector(behavior: HitTestBehavior.opaque,
        onPanStart: (d) => startChemicalDrag(c, d.globalPosition),
        onPanUpdate: (d) => updateChemicalDrag(d.globalPosition),
        onPanEnd: (_) => endChemicalDrag(),
        onPanCancel: endChemicalDrag,
        child: Container(margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: LC.panelElev,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: LC.border)),
          child: Row(children: [
            SizedBox(width: 28, height: 40,
              child: CustomPaint(painter: MiniBottlePainter(color: c.color, state: c.state))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: LC.text, fontSize: 11, fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(c.formula, style: const TextStyle(color: LC.accentBright,
                  fontSize: 10, fontWeight: FontWeight.w600)),
              ])),
            const Icon(Icons.drag_indicator, size: 14, color: LC.textDim),
          ]))));
  }

  Widget _toolboxPanel() {
    return Container(width: 280,
      decoration: const BoxDecoration(color: LC.panel,
        border: Border(left: BorderSide(color: LC.border))),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(children: [
              const Icon(Icons.build_circle_outlined, size: 14, color: LC.accentBright),
              const SizedBox(width: 10),
              const Text('Chemistry Toolbox',
                style: TextStyle(color: LC.text, fontSize: 12, fontWeight: FontWeight.w600)),
              const Spacer(),
              GestureDetector(onTap: () => setState(() => showToolbox = false),
                child: const Icon(Icons.close, color: LC.textDim, size: 15)),
            ])),
          Container(height: 1, color: LC.border),
          _sectionLabel('EQUIPMENT'),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(spacing: 6, runSpacing: 6,
              children: EquipShape.values.map(_equipTile).toList())),
          const SizedBox(height: 16),
          _sectionLabel('TOOLS - Drag to bench'),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(spacing: 6, runSpacing: 6,
              children: LabEffect.values.map(_effectTile).toList())),
          const SizedBox(height: 16),
          _sectionLabel('QUICK ACTIONS'),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(spacing: 6, runSpacing: 6, children: [
              Material(color: Colors.transparent,
                child: InkWell(
                  onTap: () => PhColorBook.show(context),
                  borderRadius: BorderRadius.circular(7),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: LC.panelElev,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: LC.border)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.menu_book, size: 14, color: LC.accentBright),
                      const SizedBox(width: 6),
                      Text('pH Color Chart',
                        style: TextStyle(color: LC.textSub, fontSize: 10)),
              const SizedBox(width: 6),
              Material(color: Colors.transparent,
                child: InkWell(
                  onTap: () => LitmusColorBook.show(context),
                  borderRadius: BorderRadius.circular(7),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: LC.panelElev,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: LC.border)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.description, size: 14, color: Color(0xFFE53935)),
                      const SizedBox(width: 6),
                      Text('Litmus Chart',
                        style: TextStyle(color: LC.textSub, fontSize: 10)),
                    ]),
                  ),
                ),
              ),
                    ]),
                  ),
                ),
              ),
            ])),
          const SizedBox(height: 12),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _actionChip(Icons.cleaning_services, 'Clear', LC.danger, reset)),
          const SizedBox(height: 16),
          _reactionInfoBox(),
          const SizedBox(height: 16),
        ])));
  }

  Widget _sectionLabel(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: Text(title, style: const TextStyle(color: LC.textMuted,
      fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 1.2)));

  Widget _equipTile(EquipShape s) {
    return Material(color: Colors.transparent,
      child: InkWell(onTap: () => addEquipment(s),
        borderRadius: BorderRadius.circular(7),
        child: Container(width: 78,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(color: LC.panelElev,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: LC.border)),
          child: Column(children: [
            Icon(s.icon, color: LC.accentBright, size: 20),
            const SizedBox(height: 5),
            Text(s.label, textAlign: TextAlign.center,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: LC.textSub, fontSize: 9)),
          ]))));
  }

  Widget _effectTile(LabEffect effect) {
    return MouseRegion(cursor: SystemMouseCursors.grab,
      child: GestureDetector(behavior: HitTestBehavior.opaque,
        onPanStart: (d) => startEffectDrag(effect, d.globalPosition),
        onPanUpdate: (d) => updateEffectDrag(d.globalPosition),
        onPanEnd: (_) => endEffectDrag(),
        onPanCancel: endEffectDrag,
        child: SizedBox(width: 62, height: 62,
          child: Column(children: [
            Icon(effect.icon, color: effect.color, size: 20),
            const SizedBox(height: 5),
            Text(effect.label, textAlign: TextAlign.center,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: LC.textSub, fontSize: 9)),
          ]))));
  }

  Widget _actionChip(IconData icon, String label, Color color, VoidCallback onTap) {
    return IconButton(
      tooltip: label,
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: color),
    );
  }

  // ============ PH TEST HELPERS ============
  Widget _reactionInfoBox() {
    final rxn = currentReaction;
    // Detect active side effects across all equipment
    final allChemIds = <String>{};
    for (final eq in equipment) {
      for (final l in eq.layers) { allChemIds.add(l.chemId); }
    }
    final sideFx = allChemIds.length >= 3 ? detectSideEffect(allChemIds.toList()) : null;

    // Detect "no reaction but mixed"
    final anyEquipment = equipment.any((e) => e.layers.length >= 2);
    final hasNoReaction = anyEquipment && rxn == null && sideFx == null;

    return Container(margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: LC.panelElev,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color:
          sideFx != null ? LC.danger.withValues(alpha: 0.6) :
          rxn != null ? LC.success.withValues(alpha: 0.4) :
          hasNoReaction ? LC.warning.withValues(alpha: 0.4) :
          LC.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(
            sideFx != null ? Icons.warning_amber :
            rxn != null ? Icons.check_circle_outline :
            hasNoReaction ? Icons.block :
            Icons.info_outline,
            size: 12,
            color: sideFx != null ? LC.danger :
                   rxn != null ? LC.success :
                   hasNoReaction ? LC.warning : LC.accent),
          const SizedBox(width: 8),
          Text(
            sideFx != null ? 'Side Effect' :
            rxn != null ? 'Reaction Info' :
            hasNoReaction ? 'No Reaction' : 'Reaction Info',
            style: TextStyle(
              color: sideFx != null ? LC.danger : LC.text,
              fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 10),
        if (sideFx != null) ...[
          Text(sideFx.label, style: TextStyle(color: LC.danger,
            fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(sideFx.description, style: const TextStyle(
            color: LC.textSub, fontSize: 10, height: 1.4)),
          const SizedBox(height: 8),
          Wrap(spacing: 4, runSpacing: 4, children: [
            if (sideFx.fizz) _badge('FIZZ', LC.info),
            if (sideFx.smoke) _badge('SMOKE', LC.textSub),
            if (sideFx.heatUp) _badge('HEAT', LC.danger),
            if (sideFx.coolDown) _badge('COOL', LC.info),
            if (sideFx.colorPulse) _badge('COLOR', LC.warning),
            if (sideFx.smallPop) _badge('POP', LC.danger),
          ]),
        ] else if (rxn == null && !hasNoReaction)
          const Text('Drag chemicals to equipment to see reaction',
            style: TextStyle(color: LC.textDim, fontSize: 10))
        else if (hasNoReaction) ...[
          const Text('Chemicals mixed but no reaction occurs.',
            style: TextStyle(color: LC.textSub, fontSize: 10, height: 1.4)),
          const SizedBox(height: 6),
          const Text('These chemicals do not react under normal conditions.',
            style: TextStyle(color: LC.textDim, fontSize: 9, height: 1.3)),
        ]
        else ...[
          Text(rxn!.name, style: const TextStyle(color: LC.text, fontSize: 10)),
          const SizedBox(height: 8),
          Container(width: double.infinity, padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: LC.bg,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: LC.border)),
            child: Text(rxn.equation,
              style: const TextStyle(color: LC.accentBright,
                fontSize: 11, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center)),
          const SizedBox(height: 6),
          Text(rxn.description, style: const TextStyle(
            color: LC.textSub, fontSize: 9, height: 1.3)),
          if (rxn.releasesHeat) ...[
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.thermostat, size: 11, color: LC.danger),
              const SizedBox(width: 4),
              const Text('Exothermic ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¾ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¾ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¦ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¾ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¦ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¦ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¦ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¾ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¦ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¦ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â releases heat',
                style: TextStyle(color: LC.danger, fontSize: 9,
                  fontWeight: FontWeight.w500)),
            ]),
          ],
          if (rxn.bubbles) ...[
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.bubble_chart, size: 11, color: LC.info),
              const SizedBox(width: 4),
              const Text('Gas bubbles evolve',
                style: TextStyle(color: LC.info, fontSize: 9)),
            ]),
          ],
          if (rxn.precipitate) ...[
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.water_drop, size: 11, color: LC.warning),
              const SizedBox(width: 4),
              const Text('Precipitate forms',
                style: TextStyle(color: LC.warning, fontSize: 9)),
            ]),
          ],
        ],
      ]));
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label, style: TextStyle(
        color: color, fontSize: 8, fontWeight: FontWeight.w600,
        letterSpacing: 0.5)),
    );
  }

  Widget _labArea() {
    return Column(children: [
      _labHeader(),
      Expanded(child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
          border: Border.all(color: LC.border), color: LC.bgDeep),
        child: ClipRRect(borderRadius: BorderRadius.circular(10),
          child: LayoutBuilder(builder: (context, constraints) {
            _benchSize = Size(constraints.maxWidth, constraints.maxHeight);
            return Stack(key: _benchKey, children: [
              Positioned.fill(child: CustomPaint(painter: MarbleBenchPainter())),
              ...equipment.map((eq) => Positioned(
                left: eq.position.dx, top: eq.position.dy,
                child: _equipmentWidget(eq))),
              ...benchTools.map((t) => Positioned(
                left: t.position.dx, top: t.position.dy,
                child: _benchToolWidget(t))),
              Positioned(right: 20, bottom: 20, child: _dustbin()),
            ]);
          })))),
      _bottomPanels(),
    ]);
  }

  Widget _labHeader() {
    return Container(height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(children: [
        const Icon(Icons.science_outlined, size: 15, color: LC.accentBright),
        const SizedBox(width: 8),
        Flexible(child: Text('Virtual Laboratory',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: LC.text, fontSize: 12, fontWeight: FontWeight.w600))),
        const SizedBox(width: 16),
        Flexible(child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: LC.panel,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: LC.border)),
          child: Row(children: [
            Flexible(child: Text('Experiment: $experimentName',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: LC.textSub, fontSize: 10))),
            const Icon(Icons.keyboard_arrow_down, color: LC.textDim, size: 13),
          ]))),
        const Spacer(),
        _headerBtn(Icons.refresh, 'Reset', reset, false),
        const SizedBox(width: 8),
        _headerBtn(Icons.play_arrow, 'Start', () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Experiment started'),
              duration: Duration(seconds: 1)));
        }, true),
      ]));
  }

  Widget _headerBtn(IconData icon, String label, VoidCallback onTap, bool primary) {
    return Material(color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(6),
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(color: primary ? LC.success : LC.panel,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: primary ? LC.success : LC.border)),
          child: Row(children: [
            Icon(icon, size: 12, color: primary ? LC.text : LC.textSub),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(color: primary ? LC.text : LC.textSub, fontSize: 10)),
          ]))));
  }

  // Determine reaction specific to this equipment only
  ReactionInfo? _reactionFor(EquipItem eq) {
    if (eq.layers.length < 2) return null;
    final ids = eq.layers.map((l) => l.chemId).toList()..sort();
    final key = ids.join('+');
    if (multiReactions.containsKey(key)) return multiReactions[key];
    if (reactions.containsKey(key)) return reactions[key];
    for (int i = 0; i < ids.length; i++) {
      for (int j = i + 1; j < ids.length; j++) {
        final pk = [ids[i], ids[j]].join('+');
        if (reactions.containsKey(pk)) return reactions[pk];
      }
    }
    return null;
  }

  // ============ PH OVERLAY ============
  Widget _buildPhOverlay(EquipItem eq) {
    if (eq.layers.isEmpty) return const SizedBox.shrink();
    
    final hasLitmus = eq.effects.contains(LabEffect.litmus);
    final hasPhPaper = eq.effects.contains(LabEffect.phPaper);
    
    if (!hasLitmus && !hasPhPaper) return const SizedBox.shrink();
    
    final ph = LabPhService.calculatePh(eq);
    if (ph == null) return const SizedBox.shrink();
    
    Color bgColor;
    String label;
    String value;
    
    if (hasLitmus) {
      final result = PhCalculator.litmusResult(ph);
      bgColor = PhCalculator.litmusColor(ph);
      label = 'Litmus';
      value = result == 'red' ? 'ACID' : result == 'blue' ? 'BASE' : 'NEUTRAL';
    } else {
      bgColor = PhCalculator.colorForPh(ph);
      label = 'pH Paper';
      value = ph.toStringAsFixed(1);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(
              color: Colors.white, fontSize: 8,
              fontWeight: FontWeight.w500, height: 1.1)),
            Text(value, style: const TextStyle(
              color: Colors.white, fontSize: 10,
              fontWeight: FontWeight.w700, height: 1.1)),
          ]),
      ]),
    );
  }
  Widget _equipmentWidget(EquipItem eq) {
    final isHovered = hoveredEquipId == eq.id;
    final isDragging = draggingEquip?.id == eq.id;
    final s = eq.shape.size;

    return MouseRegion(cursor: SystemMouseCursors.grab,
      child: GestureDetector(behavior: HitTestBehavior.opaque,
        onPanStart: (d) => _startEquipDrag(eq, d),
        onPanUpdate: _updateEquipDrag,
        onPanEnd: (_) => _endEquipDrag(),
        onPanCancel: _endEquipDrag,
        onTap: () {
          if (draggingChemical != null) {
        _showAmountAndPour(eq.id, draggingChemical!);
            setState(() => draggingChemical = null);
          }
        },
        child: Opacity(opacity: isDragging ? 0.85 : 1.0,
          child: _buildEquipmentVisual(eq, isHovered, s))));
  }

  Color _getStripColor(EquipItem eq, LabEffect type) {
    final ph = LabPhService.calculatePh(eq) ?? 7.0;
    return type == LabEffect.litmus
        ? PhCalculator.litmusColor(ph)
        : PhCalculator.colorForPh(ph);
  }

  Widget _buildEquipmentVisual(EquipItem eq, bool isHovered, Size s) {
    final totalH = s.height + 175;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      if (eq.layers.isNotEmpty &&
          (eq.effects.contains(LabEffect.litmus) ||
           eq.effects.contains(LabEffect.phPaper)))
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _buildPhOverlay(eq),
        ),
      if (eq.isHot || eq.isCold)
        Row(mainAxisSize: MainAxisSize.min, children: [
          if (eq.isHot) const Padding(padding: EdgeInsets.only(right: 6),
            child: Icon(Icons.local_fire_department, size: 16, color: Color(0xFFFF7043))),
          if (eq.isCold) const Padding(padding: EdgeInsets.only(right: 6),
            child: Icon(Icons.ac_unit, size: 16, color: Color(0xFF4FC3F7))),
          if (eq.isHot || eq.isCold)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() {
      eq.targetTemp = (eq.targetTemp - 1).clamp(eq.isHot ? 25.0 : -50.0, eq.isHot ? 300.0 : 0.0);
                final d = eq.targetTemp - eq.temperature;
                if (d.abs() > 0.1) {
                  final step = eq.isHot ? 9.0 : 7.0;
                  final n = eq.temperature + (d > 0 ? step : -step);
                  eq.temperature = d > 0 ? (n < eq.targetTemp ? n : eq.targetTemp) : (n > eq.targetTemp ? n : eq.targetTemp);
                }
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: LC.panel.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: LC.borderSoft)),
                child: const Icon(Icons.remove, size: 16, color: LC.text)),
            ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('${eq.temperature.toInt()}\u00B0 / ${eq.targetTemp.toInt()}\u00B0', style: TextStyle(color: eq.isHot ? const Color(0xFFFF8A65) : const Color(0xFF4FC3F7), fontSize: 18, fontWeight: FontWeight.w800))),
          if (eq.isHot || eq.isCold)
            Padding(padding: const EdgeInsets.only(right: 6),
              child: Text('\u2192 ${eq.targetTemp.toInt()}\u00B0',
                style: const TextStyle(color: Color(0xFFFF8A65), fontSize: 12, fontWeight: FontWeight.w700))),
          if (eq.isHot || eq.isCold)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() {
      eq.targetTemp = (eq.targetTemp + 1).clamp(eq.isHot ? 25.0 : -50.0, eq.isHot ? 300.0 : 0.0);
                final d = eq.targetTemp - eq.temperature;
                if (d.abs() > 0.1) {
                  final step = eq.isHot ? 9.0 : 7.0;
                  final n = eq.temperature + (d > 0 ? step : -step);
                  eq.temperature = d > 0 ? (n < eq.targetTemp ? n : eq.targetTemp) : (n > eq.targetTemp ? n : eq.targetTemp);
                }
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: LC.panel.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: LC.borderSoft)),
                child: const Icon(Icons.add, size: 16, color: LC.text)),
            ),
        ]),
      const SizedBox(height: 18),
      SizedBox(width: s.width + 140, height: totalH,
        child: Stack(alignment: Alignment.topCenter, children: [
          if (eq.isHot)
            Positioned(bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onDoubleTap: () => _detachTool(eq, LabEffect.heat),
                child: SizedBox(width: 95, height: 175,
                  child: CustomPaint(painter: HeatingSetupPainter(time: _time))))),
          if (eq.isCold)
            Positioned(top: 0,
              child: SizedBox(width: s.width * 0.75, height: s.height * 0.75,
                child: CustomPaint(painter: IcePainter(time: _time)))),
          Positioned(top: 0,
            child: SizedBox(width: s.width + 50, height: s.height + 15,
              child: CustomPaint(painter: RealisticEquipPainter(
                shape: eq.shape, item: eq, isHovered: isHovered,
                time: _time, reaction: _reactionFor(eq))))),
          if (eq.isCold)
            Positioned(top: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onDoubleTap: () => _detachTool(eq, LabEffect.cool),
                child: SizedBox(width: s.width * 0.75, height: s.height * 0.75,
                  child: const SizedBox()))),
          if (eq.hasThermo)
            Positioned(top: s.height * 0.25, left: 45 + s.width * 0.88, width: 70, height: s.height * 0.70,
              child: GestureDetector(behavior: HitTestBehavior.opaque,
                onDoubleTap: () => _detachTool(eq, LabEffect.thermometer),
                child: const SizedBox())),
          if (eq.hasDropper)
            Positioned(top: s.height * (1 - eq.fillRatio) - 30, left: 45 + s.width * 0.05, width: 55, height: s.height * 0.55,
              child: GestureDetector(behavior: HitTestBehavior.translucent,
                onDoubleTap: () => _detachTool(eq, LabEffect.dropper),
                child: const SizedBox())),
          if (eq.hasLitmus)
            Positioned(
              top: (s.height * (1 - eq.fillRatio) - 45).clamp(7.5, s.height - 47.5).toDouble(),
              left: (s.width + 140) / 2 - 22.5,
              width: 45, height: 55,
              child: GestureDetector(behavior: HitTestBehavior.opaque,
                onTap: () {},
                onDoubleTap: () => _detachTool(eq, LabEffect.litmus),
                child: const SizedBox())),
          if (eq.hasPhPaper)
            Positioned(
              top: (s.height * (1 - eq.fillRatio) - 45).clamp(7.5, s.height - 47.5).toDouble(),
              left: (s.width + 140) / 2 - 22.5,
              width: 45, height: 55,
              child: GestureDetector(behavior: HitTestBehavior.opaque,
                onTap: () {},
                onDoubleTap: () => _detachTool(eq, LabEffect.phPaper),
                child: const SizedBox())),
          if (eq.isStirring)
            Positioned(top: s.height * (1 - eq.fillRatio) - 30, left: (s.width + 140) / 2 - 50, width: 100, height: s.height * 0.40,
              child: GestureDetector(behavior: HitTestBehavior.opaque,
                onDoubleTap: () => _detachTool(eq, LabEffect.stir),
                child: const SizedBox())),
        ])),
    ]);
  }

  void _dockTool(BenchTool tool) {
    setState(() {
      EquipItem? target;

      // 1) active equipment
      if (activeEquipId != null) {
        for (final e in equipment) {
          if (e.id == activeEquipId) { target = e; break; }
        }
      }
      // 2) hovered equipment
      if (target == null && hoveredEquipId != null) {
        for (final e in equipment) {
          if (e.id == hoveredEquipId) { target = e; break; }
        }
      }
      // 3) nearest equipment jisme chemical ho
      if (target == null || target.layers.isEmpty) {
        double best = double.infinity;
        for (final eq in equipment) {
          if (eq.layers.isEmpty) continue;
          final d = (eq.position - tool.position).distance;
          if (d < best) { best = d; target = eq; }
        }
      }
      if (target == null || target.layers.isEmpty) return;

      // Purane dock se hatao
      for (final eq in equipment) {
        if (eq.id != target.id) eq.effects.remove(tool.type);
      }

      // Naya dock
      tool.attachedTo = target.id;
      tool.position = Offset(
        target.position.dx + target.shape.size.width / 2 - 27.5,
        target.position.dy + target.shape.size.height / 2 - 27.5,
      );

      target.effects.add(tool.type);
      if (tool.type == LabEffect.heat) target.effects.remove(LabEffect.cool);
      if (tool.type == LabEffect.cool) target.effects.remove(LabEffect.heat);
      if (tool.type == LabEffect.heat && target.targetTemp < 25.0) target.targetTemp = 25.0;
      if (tool.type == LabEffect.cool && target.targetTemp > 0.0) target.targetTemp = 0.0;

      _updateToolAttachments();
    });
  }

  void _detachStripTool(BenchTool tool) {
    setState(() {
      // Remove effect from equipment
      for (final eq in equipment) {
        eq.effects.remove(tool.type);
      }
      // Reset tool state
      tool.attachedTo = null;
      tool.dippedEqId = null;
      tool.isDipping = false;
      tool.wetness = 0.0;
      tool.capillaryProgress = 0.0;
      tool.dropFormation = 0.0;
      tool.tilt = 0;
      // Move to dock
      tool.position = _toolDockPosition(tool.type);
    });
  }

  Widget _benchToolWidget(BenchTool tool) {
    if (tool.attachedTo != null) return const SizedBox.shrink();
    final isDragging = draggingBenchTool?.id == tool.id;
    final content = MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (d) => _startToolDrag(tool, d),
        onPanUpdate: _updateToolDrag,
        onPanEnd: (_) => _endToolDrag(),
        onPanCancel: _endToolDrag,
        onSecondaryTap: () => _removeBenchTool(tool.id),
        onLongPress: () => _removeBenchTool(tool.id),
        onDoubleTap: () => _dockTool(tool),
        child: Opacity(opacity: isDragging ? 0.85 : 1.0,
          child: _buildToolVisual(tool)),
      ),
    );
    // During dip, ignore pointer so beaker can be dragged
    if (tool.isDipping) {
      return IgnorePointer(child: content);
    }
    return content;
  }

  Widget _buildToolVisual(BenchTool tool) {
    final m = Matrix4.identity();
    if (tool.tilt != 0) {
      m.translate(27.5, 27.5);
      m.rotateZ(tool.tilt);
      m.translate(-27.5, -27.5);
    }
    return Transform(
      transform: m,
      alignment: Alignment.center,
      child: SizedBox(width: 55, height: 55,
        child: CustomPaint(painter: BenchToolPainter(
          type: tool.type,
          time: _time,
          wetness: tool.wetness,
          colorProgress: tool.capillaryProgress,
          developedColor: tool.resultColor,
        ))),
    );
  }

  Widget _dustbin() {
    return AnimatedContainer(duration: const Duration(milliseconds: 180),
      width: dustbinHover ? 90 : 80, height: dustbinHover ? 110 : 100,
      decoration: BoxDecoration(
        color: dustbinHover ? LC.danger.withValues(alpha: 0.35) : LC.panel.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dustbinHover ? LC.danger : LC.borderSoft,
          width: dustbinHover ? 2.5 : 1.5)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.delete_outline, size: dustbinHover ? 36 : 32,
          color: dustbinHover ? LC.danger : LC.textSub),
        const SizedBox(height: 4),
        Text(dustbinHover ? 'DROP' : 'Drag here\nto delete',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 8,
            color: dustbinHover ? LC.danger : LC.textDim,
            fontWeight: FontWeight.w600, height: 1.2)),
      ]));
  }

  Widget _bottomPanels() {
    return Container(height: 90,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Row(children: [
        Expanded(child: _progressPanel()),
        const SizedBox(width: 8),
        Expanded(child: _resultPanel()),
      ]));
  }

  Widget _progressPanel() {
    final anyChem = equipment.any((e) => e.layers.isNotEmpty);
    final any2 = equipment.any((e) => e.layers.length >= 2);
    final reacted = currentReaction != null;
    return Container(padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: LC.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LC.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.play_circle_outline, color: LC.accentBright, size: 11),
          SizedBox(width: 6),
          Flexible(child: Text('Current Experiment',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: LC.text, fontSize: 10, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _stepDot('1', 'Select', anyChem),
          _dotLine(),
          _stepDot('2', 'Mix', any2),
          _dotLine(),
          _stepDot('3', 'Observe', reacted),
          _dotLine(),
          _stepDot('4', 'View', reacted),
        ]),
      ]));
  }

  Widget _stepDot(String n, String t, bool active) {
    return Flexible(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 18, height: 18,
        decoration: BoxDecoration(
          color: active ? LC.success : LC.panelElev, shape: BoxShape.circle,
          border: Border.all(color: active ? LC.success : LC.border)),
        alignment: Alignment.center,
        child: Text(n, style: TextStyle(
          color: active ? LC.bgDeep : LC.textDim, fontSize: 9, fontWeight: FontWeight.w600))),
      const SizedBox(height: 3),
      Flexible(child: Text(t, overflow: TextOverflow.ellipsis, maxLines: 1,
        softWrap: false, style: TextStyle(color: active ? LC.text : LC.textDim, fontSize: 8))),
      ]));
  }

  Widget _dotLine() => Expanded(child: Container(height: 1, color: LC.border,
    margin: const EdgeInsets.only(bottom: 14)));

  Widget _resultPanel() {
    final rxn = currentReaction;
    return Container(padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: LC.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: rxn != null
          ? LC.success.withValues(alpha: 0.5) : LC.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(rxn != null ? Icons.check_circle : Icons.science_outlined,
            color: rxn != null ? LC.success : LC.textDim, size: 11),
          const SizedBox(width: 6),
          Flexible(child: Text('Reaction Result',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: LC.text, fontSize: 10, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 6),
        if (rxn == null)
          Expanded(child: Center(child: Text(
            equipment.any((e) => e.layers.length >= 2) ? 'No reaction occurs' : 'Drag chemicals to equipment',
            style: TextStyle(
              color: equipment.any((e) => e.layers.length >= 2) ? LC.warning : LC.textDim,
              fontSize: 9))))
        else
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(rxn.equation, style: const TextStyle(color: LC.accentBright,
              fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(rxn.name, style: const TextStyle(color: LC.textSub, fontSize: 9)),
          ])),
      ]));
  }
}




























