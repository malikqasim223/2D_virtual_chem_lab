part of chem_lab;

class LabScreen extends StatefulWidget {
  final Map<String, dynamic>? loadData;
  const LabScreen({super.key, this.loadData});
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
  OverlayEntry? _alertOverlay;
  Timer? _alertTimer;

  ReactionInfo? currentReaction;
  Timer? _tick;
  late AnimationController _shakeCtrl;
  ReactionInfo? _currentReaction;
  late AnimationController _flashCtrl;
  double _time = 0;
  Size _benchSize = const Size(800, 600);
  final GlobalKey _benchKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.loadData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadFromHistoryData(widget.loadData!);
      });
    }
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3485));
    _flashCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 13500));
    _tick = Timer.periodic(const Duration(milliseconds: 33), (_) {
      if (!mounted) return;
      _time += 0.033;
      bool needs = false;
      for (final eq in equipment) {
        // Strip color animation
        if (eq.effects.contains(LabEffect.phPaper) || eq.effects.contains(LabEffect.phPaper)) {
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
          eq.reactionProgress = (eq.reactionProgress + 0.0030).clamp(0.0, 1.0);
          if (sideFx.heatUp) eq.temperature = (eq.temperature + 0.4).clamp(25.0, 1000.0);
          if (sideFx.coolDown) eq.temperature = (eq.temperature - 0.4).clamp(0.0, 150.0);
          if (eq.reactionProgress >= 1.0) eq.reactionComplete = true;
          needs = true;
        } else {
          // === Normal reaction (2-chem or multi-reaction map) ===
          final hasReaction = reactions.containsKey(myKey) || multiReactions.containsKey(myKey);
          final rxnForThis = multiReactions[myKey] ?? reactions[myKey];
          if (hasReaction && !eq.reactionComplete) {
            // HEAT GATE
            final needsHeat = rxnForThis?.requiresHeat == true;
            final hasEnoughHeat = eq.isHot && eq.temperature >= 60.0;
            if (needsHeat && !hasEnoughHeat) {
              // Heat required but not provided
            } else {
              eq.reactionProgress = (eq.reactionProgress + 0.0006).clamp(0.0, 1.0);
              if (eq.reactionProgress >= 1.0) eq.reactionComplete = true;
              if (rxnForThis != null && rxnForThis.releasesHeat) {
                final heatStep = (rxnForThis?.tempDeltaC ?? 10.0) / 10.0;
              eq.temperature = (eq.temperature + heatStep).clamp(25.0, 1000.0);
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
              // Slow start, then steady
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
        // FOAM RAMP
        if (eq.pourAnim == 0.0 && eq.foamRamp < 1.0) {
          eq.foamRamp = (eq.foamRamp + 0.008).clamp(0.0, 1.0); // ~2s smooth rise
          needs = true;
        }

        // Tools ka continuous animation
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
          eq.temperature = (eq.temperature - 0.05).clamp(25.0, 300.0);
          needs = true;
        }
        if (eq.isHot && eq.temperature > 60) eq.wasHeated = true;
      }
      // CONTINUOUS ANIMATION
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
    _alertTimer?.cancel();
    _alertOverlay?.remove(); _alertOverlay = null; // Dispose
    _alertTimer?.cancel();
    _alertOverlay?.remove(); _alertOverlay = null; // Dispose
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
    if (equipment.isEmpty) return;

    // === POPULATE eq.reaction for EACH beaker (multi-reaction display) ===
    for (final eq in equipment) {
      eq.reaction = _getRawReaction(eq);
    }

    EquipItem? targetEq;
    // 1. Try active equipment first
    if (activeEquipId != null) {
      for (final e in equipment) {
        if (e.id == activeEquipId) { targetEq = e; break; }
      }
    }

    // 2. Fallback to first beaker with chemicals
    if (targetEq == null) {
      for (final eq in equipment) {
        if (eq.layers.length >= 2) { targetEq = eq; break; }
      }
    }

    // 3. Set global currentReaction (for backwards compat)
    if (targetEq != null) {
      currentReaction = _reactionFor(targetEq);
    }
  }

  void addEquipment(EquipShape shape) {
    if (equipment.length >= 2) { _showRedAlert('Bench limit reached! Max 2 equipment allowed.'); return; }
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
      _currentReaction = null;
      activeEquipId = null;
      _flashCtrl.reset();
      _shakeCtrl.reset();
      _alertTimer?.cancel();
      _alertOverlay?.remove();
      _alertOverlay = null;
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
        // Dipping tool
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

        void _showRedAlert(String message) {
    _alertOverlay?.remove();
    _alertOverlay = null;
    _alertOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: 70,
        left: (MediaQuery.of(context).size.width - 340) / 2,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 340,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.6), width: 1.2),
              boxShadow: [BoxShadow(color: Colors.redAccent.withValues(alpha: 0.25), blurRadius: 12, spreadRadius: 1)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_alertOverlay!);
    _alertTimer?.cancel();
    _alertTimer = Timer(const Duration(seconds: 2), () {
      _alertOverlay?.remove();
      _alertOverlay = null;
    });
  }

  void _pourInto(String equipId, Chemical c, double amount) {
    EquipItem? targetEq;
    for (final e in equipment) {
      if (e.id == equipId) { targetEq = e; break; }
    }
    if (targetEq == null) return;
    final currentVol = targetEq.layers.fold(0.0, (sum, l) => sum + l.volume);
    if (currentVol + amount > targetEq.shape.maxVol) {
      _showRedAlert('${targetEq.shape.label} is full! Max capacity: ${targetEq.shape.maxVol} mL');
      return;
    }
    setState(() {
      final eq = equipment.firstWhere((e) => e.id == equipId);
      eq.addChem(c.id, c.color, amount, isSolid: c.state == 'Solid');
      eq.pourAnim = 1.0;
      eq.pourIsLiquid = c.state == 'Liquid';
      eq.foamRamp = 0; // Reset foam ramp
      eq.pourColor = c.color;
      activeEquipId = equipId;
      _recomputeReaction();
      final _rxnCheck = _reactionFor(eq);
        _currentReaction = _rxnCheck;
      if (_rxnCheck != null && _rxnCheck.isViolent) {
        _flashCtrl.forward(from: 0);
        // Only shake if the reaction has a shakeAmplitude > 0 (e.g. Sodium + Water)
        if (_rxnCheck.explosion != null && _rxnCheck.explosion!.shakeAmplitude > 0) {
          _shakeCtrl.forward(from: 0);
        }
      }
    });
  }

  Widget _dragBottle(Chemical c) => SizedBox(width: 60, height: 90,
    child: CustomPaint(painter: DragBottlePainter(color: c.color)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: LC.darkBgDeep,
      body: AnimatedBuilder(
        animation: _shakeCtrl,
        builder: (context, child) {
          final t = _shakeCtrl.value;
          // Shake intensity curve
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
                    // _topBar(), // Removed as requested
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showInventory)
                            Container(
                              width: 280,
                              constraints: const BoxConstraints.tightFor(width: 280),
                              child: _inventoryPanel(),
                            ),
                          if (showChemInfo)
                            Container(
                              width: 280,
                              constraints: const BoxConstraints.tightFor(width: 280),
                              child: _chemInfoPanel(),
                            ),
                          Expanded(child: _labArea()),
                          if (showToolbox)
                            Container(
                              width: 170, constraints: const BoxConstraints.tightFor(width: 170), child: _toolboxPanel(),
                            ),
                        ],
                      ),
                    ),
                  ]),
                  
                  // ===== Inventory Toggle (Left) =====
                  if (!showInventory)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _sideToggle(
                          icon: Icons.inventory_2_outlined,
                          isActive: false,
                          onTap: () {
                          setState(() => showInventory = true);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() => _clampEquipmentToBench());
                          });
                        },
                          isLeft: true,
                        ),
                      ),
                    ),
                  
                  // ===== Toolbox Toggle (Right) =====
                  if (!showToolbox)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _sideToggle(
                          icon: Icons.build_circle_outlined,
                          isActive: false,
                          onTap: () {
                          setState(() => showToolbox = true);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() => _clampEquipmentToBench());
                          });
                        },
                          isLeft: false,
                        ),
                      ),
                    ),
                  
                  IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _flashCtrl,
                      builder: (_, __) {
                        final v = _flashCtrl.value;
                        if (v == 0 || v >= 1) return const SizedBox.shrink();
                        double intensity;
                        if (v < 0.10) {
                          // Fast fade IN
                          final ft = v / 0.10;
                          intensity = 0.95 * ft * ft;
                        } else if (v < 0.25) {
                          // Peak hold (thora aur lamba)
                          intensity = 0.95;
                        } else {
                          // SUPER LONG fade OUT (10 seconds!)
                          final ft = (v - 0.25) / 0.75;
                          intensity = 0.95 * (1 - ft) * (1 - ft) * (1 - ft);
                        }
                        Color flashColor;
                          final _flashBase = _currentReaction?.explosion?.flashColor ?? const Color(0xFFFFEB3B);
                        if (v < 0.45) {
                          flashColor = Colors.white;
                        } else if (v < 0.75) {
                          flashColor = Color.lerp(Colors.white, _flashBase, (v - 0.45) / 0.30)!;
                        } else if (v < 0.95) {
                          flashColor = Color.lerp(_flashBase, const Color(0xFFFF6B35), (v - 0.75) / 0.20)!;
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
      decoration: const BoxDecoration(color: LC.darkBg,
        border: Border(bottom: BorderSide(color: LC.darkBorder))),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(children: [
            // ===== Home Button =====
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: LC.darkPanelElev,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: LC.darkBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.home_outlined, size: 16, color: LC.darkAccentBright),
                      SizedBox(width: 6),
                      Text('Home', style: TextStyle(color: LC.darkText, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
        Container(width: 38, height: 38,
          decoration: BoxDecoration(color: LC.darkPanelElev,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: LC.darkBorderSoft)),
          child: const Icon(Icons.science, color: LC.darkAccentBright, size: 20)),
        const SizedBox(width: 12),
        const Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Virtual Chemistry Lab (Illustrative)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LC.darkText)),
            SizedBox(height: 2),
            Text('Explore / Experiment / Learn',
              style: TextStyle(color: LC.darkTextDim, fontSize: 10)),
          ]),
        const SizedBox(width: 30),
        Expanded(child: Container(height: 34,
          decoration: BoxDecoration(color: LC.darkPanel, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8, offset: Offset(0, 4))],
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: LC.darkBorder)),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(children: const [
            Icon(Icons.search, color: LC.darkTextDim, size: 15),
            SizedBox(width: 8),
            Expanded(child: Text('Search chemicals, experiments...',
              style: TextStyle(color: LC.darkTextDim, fontSize: 11))),
          ]))),
        const SizedBox(width: 16),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: LC.darkPanel, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8, offset: Offset(0, 4))],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: LC.darkBorder)),
          child: Row(children: const [
            Icon(Icons.person, color: LC.darkAccentBright, size: 14),
            SizedBox(width: 6),
            Text('Student', style: TextStyle(color: LC.darkText, fontSize: 10)),
          ])),
      ]));
  }

  Widget _topBar() {
    return Container(height: 60,
      decoration: const BoxDecoration(color: LC.darkBg,
        border: Border(bottom: BorderSide(color: LC.darkBorder))),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(children: [
        // ===== Home Button =====
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: LC.darkPanelElev,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: LC.darkBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.home_outlined, size: 16, color: LC.darkAccentBright),
                  SizedBox(width: 6),
                  Text('Home', style: TextStyle(color: LC.darkText, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(width: 38, height: 38,
          decoration: BoxDecoration(color: LC.darkPanelElev,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: LC.darkBorderSoft)),
          child: const Icon(Icons.science, color: LC.darkAccentBright, size: 20)),
        const SizedBox(width: 12),
        const Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Virtual Chemistry Lab (Illustrative)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LC.darkText)),
            SizedBox(height: 2),
            Text('Explore / Experiment / Learn',
              style: TextStyle(color: LC.darkTextDim, fontSize: 10)),
          ]),
        const SizedBox(width: 30),
        Expanded(child: Container(height: 34,
          decoration: BoxDecoration(color: LC.darkPanel, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8, offset: Offset(0, 4))],
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: LC.darkBorder)),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(children: const [
            Icon(Icons.search, color: LC.darkTextDim, size: 15),
            SizedBox(width: 8),
            Expanded(child: Text('Search chemicals, experiments...',
              style: TextStyle(color: LC.darkTextDim, fontSize: 11))),
          ]))),
        const SizedBox(width: 16),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: LC.darkPanel, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8, offset: Offset(0, 4))],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: LC.darkBorder)),
          child: Row(children: const [
            Icon(Icons.person, color: LC.darkAccentBright, size: 14),
            SizedBox(width: 6),
            Text('Student', style: TextStyle(color: LC.darkText, fontSize: 10)),
          ])),
      ]));
  }

  Widget _sidebar() {
    final items = [
      (Icons.home_outlined, 'Home', -2),
      (Icons.science_outlined, 'Virtual Lab', -1),
      (Icons.inventory_2_outlined, 'Inventory', 0),
      (Icons.build_circle_outlined, 'Toolbox', 1),
    ];
    return Container(width: 130,
      decoration: const BoxDecoration(color: LC.darkBg,
        border: Border(right: BorderSide(color: LC.darkBorder))),
      child: Column(children: [
        const SizedBox(height: 14),
        ...items.asMap().entries.map((e) {
          final active = navIndex == e.key;
          return GestureDetector(
            onTap: () {
              if (e.value.$3 == -2) {
                Navigator.pop(context);
                return;
              }
              setState(() {
                navIndex = e.key;
                if (e.value.$3 == 0) {
                  showInventory = !showInventory;
                  if (showInventory) { showToolbox = false; }
                } else if (e.value.$3 == 1) {
                  showToolbox = !showToolbox;
                  if (showToolbox) { showInventory = false; }
                }
              });
            },
            child: AnimatedContainer(duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: active ? LC.darkPanelElev : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: active ? Border.all(color: LC.darkBorderSoft) : null),
              child: Row(children: [
                Icon(e.value.$1, size: 17, color: active ? LC.darkAccentBright : LC.darkTextSub),
                const SizedBox(width: 10),
                Expanded(child: Text(e.value.$2,
                  style: TextStyle(color: active ? LC.darkText : LC.darkTextSub,
                    fontSize: 11, fontWeight: active ? FontWeight.w600 : FontWeight.w400))),
              ])));
        }).toList(),
      ]));
  }

  Widget _experimentsPanel() {
    return Container(width: 300,
      decoration: const BoxDecoration(color: LC.darkPanel,
        border: Border(right: BorderSide(color: LC.darkBorder))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
          child: Row(children: [
            const Icon(Icons.biotech_outlined, size: 14, color: LC.darkAccentBright),
            const SizedBox(width: 10),
            const Text('Manual Experiments',
              style: TextStyle(color: LC.darkText, fontSize: 12, fontWeight: FontWeight.w600)),
            const Spacer(),
            GestureDetector(onTap: () => setState(() => showExperiments = false),
              child: const Icon(Icons.close, color: LC.darkTextDim, size: 15)),
          ])),
        Container(height: 1, color: LC.darkBorder),
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
      decoration: BoxDecoration(color: LC.darkPanelElev,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LC.darkBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 22, height: 22,
            decoration: BoxDecoration(
              color: LC.darkAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4)),
            child: Center(child: Text('${allExperiments.indexOf(exp) + 1}',
              style: const TextStyle(color: LC.darkAccentBright, fontSize: 10,
                fontWeight: FontWeight.w700)))),
          const SizedBox(width: 8),
          Expanded(child: Text(exp.name,
            style: const TextStyle(color: LC.darkText, fontSize: 11,
              fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 6),
        Text(exp.description,
          style: const TextStyle(color: LC.darkTextSub, fontSize: 9, height: 1.4)),
        const SizedBox(height: 8),
        const Text('STEPS',
          style: TextStyle(color: LC.darkTextMuted, fontSize: 8,
            fontWeight: FontWeight.w600, letterSpacing: 1.0)),
        const SizedBox(height: 4),
        ...exp.steps.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${e.key + 1}. ',
              style: const TextStyle(color: LC.darkAccentBright, fontSize: 9)),
            Expanded(child: Text(e.value,
              style: const TextStyle(color: LC.darkTextSub, fontSize: 9, height: 1.3))),
          ]))),
        const SizedBox(height: 8),
        const Text('CHEMICALS',
          style: TextStyle(color: LC.darkTextMuted, fontSize: 8,
            fontWeight: FontWeight.w600, letterSpacing: 1.0)),
        const SizedBox(height: 4),
        Wrap(spacing: 4, runSpacing: 4,
          children: exp.chemicals.map((c) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: LC.darkAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: LC.darkAccent.withValues(alpha: 0.4))),
            child: Text(c, style: const TextStyle(color: LC.darkAccentBright,
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
  
  
  
  //
  
  //
  // CHEM INFO PANEL
  //
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
      decoration: const BoxDecoration(color: LC.darkPanel,
        border: Border(right: BorderSide(color: LC.darkBorder))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // HEADER
        Container(padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
          child: Row(children: [
            const Icon(Icons.menu_book_rounded, size: 20, color: LC.darkAccentBright),
            const SizedBox(width: 10),
            const Text('Chemical Encyclopedia',
              style: TextStyle(color: LC.darkText, fontSize: 16, fontWeight: FontWeight.w700)),
            const Spacer(),
            GestureDetector(onTap: () => setState(() => showChemInfo = false),
              child: Container(width: 30, height: 30,
                decoration: BoxDecoration(color: LC.darkPanelElev,
                  borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.close, color: LC.darkTextDim, size: 16))),
          ])),
        Container(height: 1, color: LC.darkBorder),
        Expanded(child: Row(children: [
          // LEFT: Chem list
          Container(width: 180,
            decoration: BoxDecoration(border: Border(right: BorderSide(color: LC.darkBorder))),
            child: Column(children: [
              Padding(padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Container(height: 38,
                  decoration: BoxDecoration(color: LC.darkPanelElev,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: LC.darkBorder)),
                  child: TextField(
                    onChanged: (v) => setState(() => chemInfoSearch = v),
                    style: const TextStyle(color: LC.darkText, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: LC.darkTextDim, fontSize: 11),
                      prefixIcon: const Icon(Icons.search, size: 16, color: LC.darkTextDim),
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
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: active ? LC.darkAccent.withValues(alpha: 0.18) : LC.darkPanelElev,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: active ? LC.darkAccent : LC.darkBorder,
                          width: active ? 1.4 : 1.0)),
                      child: Row(children: [
                        SizedBox(width: 28, height: 40,
                          child: CustomPaint(painter: MiniBottlePainter(color: c.color, state: c.state))),
                        const SizedBox(width: 10),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: active ? LC.darkAccentBright : LC.darkText,
                                fontSize: 11,
                                fontWeight: FontWeight.w500)),
                            const SizedBox(height: 3),
                            Text(c.formula,
                              style: const TextStyle(
                                color: LC.darkAccentBright,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                          ])),
                        Icon(
                          active ? Icons.chevron_right : Icons.info_outline,
                          size: 14,
                          color: active ? LC.darkAccentBright : LC.darkTextDim),
                      ]),
                    ),
                  );
                })),
            ]),
          ),
          // RIGHT: Details (reference style)
          Expanded(child: selected == null
            ? Center(child: Text('Select a chemical',
                style: TextStyle(color: LC.darkTextDim, fontSize: 14)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Chem name (big)
                  Text(selected.name,
                    style: const TextStyle(color: LC.darkText, fontSize: 26,
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
                      _dataRow('Molar Mass', detail?.molarMass != null ? '${detail!.molarMass} g/mol' : 'ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â'),
                      if (detail?.boilingPoint != null)
                        _dataRow('Boiling Point', '${detail!.boilingPoint} ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â°C'),
                      if (detail?.meltingPoint != null)
                        _dataRow('Melting Point', '${detail!.meltingPoint} ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â°C'),
                      if (detail?.density != null)
                        _dataRow('Density', '${detail!.density} g/cmÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â³'),
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
                    Container(height: 2, color: LC.darkBorder),
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
        border: Border(bottom: BorderSide(color: LC.darkBorder, width: 0.5))),
      child: Row(children: [
        Text(label,
          style: TextStyle(color: LC.darkTextSub, fontSize: 13,
            fontWeight: FontWeight.w500)),
        const Spacer(),
        Flexible(child: Text(value,
          style: const TextStyle(color: LC.darkText, fontSize: 13,
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
            color: active ? color : LC.darkTextDim,
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
        style: TextStyle(color: LC.darkText, fontSize: 13, height: 1.5));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            width: 5, height: 5,
            decoration: BoxDecoration(
              color: LC.darkAccentBright,
              shape: BoxShape.circle)),
          Expanded(child: Text(item.trim(),
            style: TextStyle(color: LC.darkText, fontSize: 13, height: 1.5))),
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
        border: Border.all(color: LC.darkBorder, width: 0.5)),
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
      decoration: const BoxDecoration(color: LC.darkPanel,
        border: Border(right: BorderSide(color: LC.darkBorder))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
          child: Row(children: [
            const Icon(Icons.inventory_2_outlined, size: 14, color: LC.darkAccentBright),
            const SizedBox(width: 10),
            const Text('Chemical Inventory',
              style: TextStyle(color: LC.darkText, fontSize: 12, fontWeight: FontWeight.w600)),
            const Spacer(),
            GestureDetector(onTap: () => setState(() => showInventory = false),
              child: const Icon(Icons.close, color: LC.darkTextDim, size: 15)),
          ])),
        Container(height: 1, color: LC.darkBorder),
        Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Container(height: 30,
            decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10, offset: Offset(0, 5))], color: LC.darkPanelElev,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: LC.darkBorder)),
            child: Row(children: [
              const SizedBox(width: 8),
              const Icon(Icons.search, size: 14, color: LC.darkTextDim),
              const SizedBox(width: 6),
              Expanded(child: TextField(
                controller: _invSearchCtrl,
                onChanged: (v) => setState(() => _invSearch = v),
                style: const TextStyle(color: LC.darkText, fontSize: 11),
                decoration: const InputDecoration(
                  hintText: 'Search chemical...',
                  hintStyle: TextStyle(color: LC.darkTextDim, fontSize: 11),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8)),
              )),
              if (_invSearch.isNotEmpty)
                GestureDetector(onTap: () {
                  _invSearchCtrl.clear();
                  setState(() => _invSearch = '');
                }, child: const Padding(padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.close, size: 13, color: LC.darkTextDim))),
            ]))),
        Padding(padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: SizedBox(height: 34,
            child: ListView(scrollDirection: Axis.horizontal,
              children: ['All', 'Acids', 'Bases', 'Salts', 'Others'].map((c) {
                return Padding(padding: const EdgeInsets.only(right: 4),
                  child: _PremiumFilterChip(
                    label: c,
                    isActive: category == c,
                    onTap: () => setState(() => category = c),
                  ),
                );
              }).toList()))),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 4, 20, 12),
          itemCount: filteredChemicals.length,
          itemBuilder: (_, i) => _chemTile(filteredChemicals[i]))),
      ]));
  }

  Widget _chemTile(Chemical c) => _PremiumChemTile(c: c);

  
  Widget _equipTile(EquipShape s) => _PremiumEquipCard(s: s, onTap: () => addEquipment(s));

  Widget _effectTile(LabEffect effect) => _PremiumEffectCard(effect: effect);

  Widget _actionChip(IconData icon, String label, Color color, VoidCallback onTap) {
    return IconButton(
      tooltip: label,
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: color),
    );
  }



  Widget _toolboxPanel() {
    return Container(width: 170,
      decoration: const BoxDecoration(color: LC.darkPanel,
        border: Border(left: BorderSide(color: LC.darkBorder))),
      child: ScrollConfiguration(behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false), child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(padding: const EdgeInsets.fromLTRB(12, 14, 8, 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.build_circle_outlined, size: 14, color: LC.darkAccentBright),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Chemistry Toolbox',
                  maxLines: 2,
                  softWrap: true,
                  style: TextStyle(color: LC.darkText, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 4),
              GestureDetector(onTap: () => setState(() => showToolbox = false),
                child: const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.close, color: LC.darkTextDim, size: 15),
                )),
            ])),
          Container(height: 1, color: LC.darkBorder),
          _sectionLabel('EQUIPMENT'),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center,
              children: EquipShape.values.map(_equipTile).toList())),
          const SizedBox(height: 16),
          _sectionLabel('TOOLS - Drag to bench'),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center,
              children: LabEffect.values.map(_effectTile).toList())),
          const SizedBox(height: 16),
          _sectionLabel('QUICK ACTIONS'),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center, children: [
              _PremiumColorChartBtn()])),
          const SizedBox(height: 12),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _PremiumClearBtn(onTap: reset)),
          const SizedBox(height: 16),
        ]))));
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Text(
        text,
        style: TextStyle(
          color: LC.darkTextSub.withValues(alpha: 0.9),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          shadows: const [Shadow(color: Colors.black54, blurRadius: 2, offset: Offset(0, 1))],
        ),
      ),
    );
  }

  // ============ PH TEST HELPERS ============
            

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

    void _clampEquipmentToBench() {
    if (_benchSize.width <= 0) return;
    // Equipment size is roughly 120x150 based on _equipmentWidget
    const equipW = 120.0;
    const equipH = 150.0;
    final maxX = (_benchSize.width - equipW).clamp(0.0, 5000.0);
    final maxY = (_benchSize.height - equipH).clamp(0.0, 5000.0);
    
    for (final eq in equipment) {
      final newX = eq.position.dx.clamp(0.0, maxX);
      final newY = eq.position.dy.clamp(0.0, maxY);
      if (newX != eq.position.dx || newY != eq.position.dy) {
        eq.position = Offset(newX, newY);
      }
    }
    
    // Also clamp bench tools
    const toolW = 70.0;
    const toolH = 70.0;
    final tMaxX = (_benchSize.width - toolW).clamp(0.0, 5000.0);
    final tMaxY = (_benchSize.height - toolH).clamp(0.0, 5000.0);
    for (final t in benchTools) {
      final newX = t.position.dx.clamp(0.0, tMaxX);
      final newY = t.position.dy.clamp(0.0, tMaxY);
      if (newX != t.position.dx || newY != t.position.dy) {
        t.position = Offset(newX, newY);
      }
    }
  }
Widget _labArea() {
    return Column(children: [
      _labHeader(),
      Expanded(child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
          border: Border.all(color: LC.darkBorder), color: LC.darkBgDeep),
        child: ClipRRect(borderRadius: BorderRadius.circular(10),
          child: LayoutBuilder(builder: (context, constraints) {
            _benchSize = Size(constraints.maxWidth, constraints.maxHeight);
              // Clamp equipment to fit within new bench size
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  final needsClamp = equipment.any((e) =>
                    e.position.dx + 120 > _benchSize.width ||
                    e.position.dy + 150 > _benchSize.height);
                  if (needsClamp) {
                    setState(() => _clampEquipmentToBench());
                  }
                }
              });
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

    // ===== NEW: SAVE / LOAD EXPERIMENT =====
  Future<void> _saveExperiment() async {
    final hasContent = equipment.any((eq) => eq.layers.isNotEmpty);
    if (!hasContent) {
      _showRedAlert('Bench is empty! Add chemicals before saving.');
      return;
    }

    final TextEditingController nameCtrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: LC.panel,
        title: const Text('Save Experiment', style: TextStyle(color: LC.text)),
        content: TextField(
          controller: nameCtrl,
          style: const TextStyle(color: LC.text),
          decoration: const InputDecoration(
            hintText: 'Enter experiment name...',
            hintStyle: TextStyle(color: LC.textDim),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: LC.accent)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: LC.textDim)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: LC.accent),
            onPressed: () => Navigator.pop(ctx, nameCtrl.text.trim().isEmpty ? 'Unnamed Experiment' : nameCtrl.text.trim()),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null) {
      await LabHistoryService.saveExperiment(equipment, result);
      _showRedAlert('Experiment "$result" saved successfully!');
    }
  }

  Future<void> _loadExperiment() async {
    if (equipment.isEmpty) {
      _showRedAlert('Please add equipment to the bench first to load a reaction.');
      return;
    }

    final history = await LabHistoryService.loadHistory();
    if (history.isEmpty) {
      _showRedAlert('No saved experiment found!');
      return;
    }

    final selectedIndex = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: LC.panel,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: 550,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Saved Experiments',
                      style: TextStyle(color: LC.text, fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close, color: LC.textDim, size: 18),
                      onPressed: () => Navigator.pop(ctx),
                    )
                  ],
                ),
                const Divider(color: LC.border),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: history.length,
                    itemBuilder: (context, i) {
                      final item = history[i];
                      final expName = item['name'] ?? 'Unnamed Experiment';
                      final date = DateTime.parse(item['date']).toLocal();
                      final eqList = item['equipment'] as List;
                      int chemCount = 0;
                      final eqNames = <String>{};
                      for (final eq in eqList) {
                        final layers = eq['layers'] as List;
                        if (layers.isNotEmpty) {
                          chemCount += layers.length;
                          eqNames.add(eq['label'] ?? 'Unknown');
                        }
                      }
                      
                      return ListTile(
                        leading: const Icon(Icons.science, color: LC.accentBright),
                        title: Text(
                          expName,
                          style: const TextStyle(color: LC.text, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${date.day}/${date.month}/${date.year}  ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¢  $chemCount chemicals  ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¢  In: ${eqNames.join(", ")}',
                          style: const TextStyle(color: LC.textDim, fontSize: 11),
                        ),
                        onTap: () => Navigator.pop(ctx, i),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedIndex == null) return;

    final data = history[selectedIndex]['equipment'] as List;
    setState(() {
      reset();
      for (var i = 0; i < data.length; i++) {
        if (i >= equipment.length) break;
        final eq = equipment[i];
        eq.temperature = (data[i]['temperature'] as num).toDouble();
        final layers = data[i]['layers'] as List;
        for (var l in layers) {
          final chem = allChemicals.firstWhere(
            (c) => c.id == l['chemId'],
            orElse: () => allChemicals.first,
          );
          eq.addChem(chem.id, chem.color, (l['volume'] as num).toDouble(),
            isSolid: chem.state == 'Solid');
        }
        if (eq.layers.isNotEmpty && activeEquipId == null) {
          activeEquipId = eq.id;
        }
      }
      _recomputeReaction();
    });
    _showRedAlert('Experiment loaded successfully!');
  }

  void _loadFromHistoryData(Map<String, dynamic> item) {
    final data = item['equipment'] as List;
    setState(() {
      reset();
      for (var i = 0; i < data.length; i++) {
        if (i >= equipment.length) break;
        final eq = equipment[i];
        eq.temperature = (data[i]['temperature'] as num).toDouble();
        final layers = data[i]['layers'] as List;
        for (var l in layers) {
          final chem = allChemicals.firstWhere(
            (c) => c.id == l['chemId'],
            orElse: () => allChemicals.first,
          );
          eq.addChem(chem.id, chem.color, (l['volume'] as num).toDouble(),
            isSolid: chem.state == 'Solid');
        }
        if (eq.layers.isNotEmpty && activeEquipId == null) {
          activeEquipId = eq.id;
        }
      }
      _recomputeReaction();
    });
    _showRedAlert('Experiment loaded successfully!');
  }

  Widget _labHeader() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // --- HOME / BACK BUTTON ---
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: LC.panel,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: LC.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back_ios_new, size: 12, color: LC.textSub),
                    SizedBox(width: 6),
                    Text('Home', style: TextStyle(color: LC.text, fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          
          // --- TITLE ---
          const Icon(Icons.science_outlined, size: 15, color: LC.accentBright),
          const SizedBox(width: 8),
          const Text('Virtual Laboratory', style: TextStyle(color: LC.text, fontSize: 12, fontWeight: FontWeight.w600)),
          
          const Spacer(), // Pushes everything after this to the extreme right
          
          // --- RIGHT SIDE BUTTONS ---
          _headerBtn(Icons.save, 'Save', _saveExperiment, hoverColor: Colors.green),
          const SizedBox(width: 8),
          _headerBtn(Icons.folder_open, 'Load', _loadExperiment, hoverColor: Colors.grey),
          const SizedBox(width: 8),
          _headerBtn(Icons.refresh, 'Reset', reset, hoverColor: Colors.red),
        ],
      ),
    );
  }

  Widget _headerBtn(IconData icon, String label, VoidCallback onTap, {bool primary = false, Color hoverColor = Colors.blue}) {
    return _PremiumHeaderBtn(icon: icon, label: label, onTap: onTap, primary: primary, hoverColor: hoverColor);
  }

  // Determine reaction specific to this equipment only
  ReactionInfo? _reactionFor(EquipItem eq) {
    final rx = _getRawReaction(eq);
    if (rx == null) return null;

    // Check Heat Condition
    if (rx.requiresHeat && (!eq.isHot || eq.temperature < 60)) {
      return const ReactionInfo(
        name: 'Condition Not Met',
        equation: 'Heat required (>= 60ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â°C)',
        type: 'Condition',
        description: 'Turn on the Bunsen burner to proceed.',
        products: [],
      );
    }

    // Check Acid Condition
    if (rx.needsAcid) {
      final hasAcid = eq.layers.any((l) => ['hcl', 'h2so4', 'hno3', 'ch3cooh'].contains(l.chemId));
      if (!hasAcid) {
        return const ReactionInfo(
          name: 'Condition Not Met',
          equation: 'Acidic medium required',
          type: 'Condition',
          description: 'Add an acid (e.g., H2SO4) to proceed.',
          products: [],
        );
      }
    }
    
    return rx;
  }

  ReactionInfo? _getRawReaction(EquipItem eq) {
    if (eq.layers.length < 2) return null;
    final ids = eq.layers.map((l) => l.chemId).toList()..sort();
    final key = ids.join('+');
    if (multiReactions.containsKey(key)) return multiReactions[key];
    if (reactions.containsKey(key)) return reactions[key];
    
    // Safe pairwise fallback ONLY for needsAcid reactions
    // This allows 3+ chemicals like KMnO4+H2O2+H2SO4 to match KMnO4+H2O2 reaction
    // (which needs acid as a condition)
    for (int i = 0; i < ids.length; i++) {
      for (int j = i + 1; j < ids.length; j++) {
        final pk = [ids[i], ids[j]].join('+');
        if (reactions.containsKey(pk) && reactions[pk]!.needsAcid) {
          return reactions[pk];
        }
      }
    }
    return null;
  }

  // ============ PH OVERLAY ============
  Widget _buildPhOverlay(EquipItem eq) {
    if (eq.layers.length < 2) return const SizedBox.shrink();
    if (eq.layers.isEmpty) return const SizedBox.shrink();
    
    final hasLitmus = eq.effects.contains(LabEffect.phPaper);
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
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 10.5, shadows: [Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1))],
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
    return type == LabEffect.phPaper
        ? PhCalculator.litmusColor(ph)
        : PhCalculator.colorForPh(ph);
  }

  Widget _buildEquipmentVisual(EquipItem eq, bool isHovered, Size s) {
    final totalH = s.height + 175;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      if (eq.layers.isNotEmpty &&
          (eq.effects.contains(LabEffect.phPaper) ||
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
                  color: LC.darkPanel.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: LC.darkBorderSoft)),
                child: const Icon(Icons.remove, size: 16, color: LC.darkText)),
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
                  color: LC.darkPanel.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: LC.darkBorderSoft)),
                child: const Icon(Icons.add, size: 16, color: LC.darkText)),
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
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Double-tap the Litmus Strip to detach'), duration: Duration(seconds: 1))),
                onDoubleTap: () => _detachTool(eq, LabEffect.phPaper),
                child: const SizedBox())),
          if (eq.hasPhPaper)
            Positioned(
              top: (s.height * (1 - eq.fillRatio) - 45).clamp(7.5, s.height - 47.5).toDouble(),
              left: (s.width + 140) / 2 - 22.5,
              width: 45, height: 55,
              child: GestureDetector(behavior: HitTestBehavior.opaque,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Double-tap the pH Paper Strip to detach'), duration: Duration(seconds: 1))),
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

      Widget _sideToggle({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 64,
          decoration: BoxDecoration(
            color: isActive ? LC.darkAccent : LC.darkPanelElev,
            borderRadius: isLeft
                ? const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8))
                : const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
            border: Border.all(color: LC.darkBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF94A3B8).withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : LC.darkTextSub,
            size: 20,
          ),
        ),
      ),
    );
  }
  Widget _dustbin() {
    return AnimatedContainer(duration: const Duration(milliseconds: 180),
      width: dustbinHover ? 90 : 80, height: dustbinHover ? 110 : 100,
      decoration: BoxDecoration(
        color: dustbinHover ? LC.danger.withValues(alpha: 0.35) : LC.darkPanel.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dustbinHover ? LC.danger : LC.darkBorderSoft,
          width: dustbinHover ? 2.5 : 1.5)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.delete_outline, size: dustbinHover ? 36 : 32,
          color: dustbinHover ? LC.danger : LC.darkTextSub),
        const SizedBox(height: 4),
        Text(dustbinHover ? 'DROP' : 'Drag here\nto delete',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 8,
            color: dustbinHover ? LC.danger : LC.darkTextDim,
            fontWeight: FontWeight.w600, height: 1.2)),
      ]));
  }

    Widget _bottomPanels() {
    return Container(height: 110, // Increased from 90 to prevent vertical overflow
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Row(children: [
        Expanded(flex: 2, child: _progressPanel()), // Narrower Left Panel
        const SizedBox(width: 8),
        Expanded(flex: 3, child: _resultPanel()),   // Wider Right Panel (Reaction Result)
      ]));
  }

  Widget _progressPanel() {
    final anyChem = equipment.any((e) => e.layers.isNotEmpty);
    final any2 = equipment.any((e) => e.layers.length >= 2);
    final reacted = currentReaction != null;
    return Container(padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: LC.darkPanel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LC.darkBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.play_circle_outline, color: LC.darkAccentBright, size: 11),
          SizedBox(width: 6),
          Flexible(child: Text('Current Experiment',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: LC.darkText, fontSize: 10, fontWeight: FontWeight.w600))),
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
          color: active ? LC.success : LC.darkPanelElev, shape: BoxShape.circle,
          border: Border.all(color: active ? LC.success : LC.darkBorder)),
        alignment: Alignment.center,
        child: Text(n, style: TextStyle(
          color: active ? LC.darkBgDeep : LC.darkTextDim, fontSize: 9, fontWeight: FontWeight.w600))),
      const SizedBox(height: 3),
      Flexible(child: Text(t, overflow: TextOverflow.ellipsis, maxLines: 1,
        softWrap: false, style: TextStyle(color: active ? LC.darkText : LC.darkTextDim, fontSize: 8))),
      ]));
  }

  Widget _dotLine() => Expanded(child: Container(height: 1, color: LC.darkBorder,
    margin: const EdgeInsets.only(bottom: 14)));

  Widget _resultPanel() {
    // Collect all beakers with reactions (audit fix: multi-reaction display)
    final List<MapEntry<String, ReactionInfo>> activeReactions = [];
    for (final eq in equipment) {
      if (eq.reaction != null) {
        activeReactions.add(MapEntry(eq.shape.label, eq.reaction!));
      }
    }
    
    final anyMixed = equipment.any((e) => e.layers.length >= 2);
    final hasAny = activeReactions.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: LC.darkPanel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasAny ? LC.success.withValues(alpha: 0.5) : LC.darkBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                hasAny ? Icons.check_circle : Icons.science_outlined,
                color: hasAny ? LC.success : LC.darkTextDim,
                size: 11,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  hasAny ? 'Reactions (${activeReactions.length})' : 'Reaction Result',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: LC.darkText, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          
          // Content
          Expanded(
            child: activeReactions.isEmpty
                ? Center(
                    child: Text(
                      anyMixed ? 'No reaction occurs' : 'Drag chemicals to equipment',
                      style: TextStyle(
                        color: anyMixed ? LC.warning : LC.darkTextDim,
                        fontSize: 9,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: activeReactions.length,
                    separatorBuilder: (_, __) => Container(
                      height: 1,
                      color: LC.darkBorder.withValues(alpha: 0.5),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                    ),
                    itemBuilder: (context, index) {
                      final entry = activeReactions[index];
                      final rxn = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Beaker name badge
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: LC.darkAccent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: LC.darkAccent.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  entry.key.toUpperCase(),
                                  style: const TextStyle(
                                    color: LC.darkAccentBright,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  rxn.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: LC.darkText,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Equation
                          Text(
                            rxn.equation,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: LC.darkAccentBright,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // Quick indicators
                          const SizedBox(height: 3),
                          Wrap(
                            spacing: 4,
                            runSpacing: 2,
                            children: [
                              if (rxn.isViolent)
                                _indicatorBadge('VIOLENT', Colors.red),
                              if (rxn.releasesHeat)
                                _indicatorBadge('HEAT', LC.danger),
                              if (rxn.bubbles)
                                _indicatorBadge('GAS', LC.info),
                              if (rxn.precipitate)
                                _indicatorBadge('PPT', LC.warning),
                              if (rxn.producesSmoke)
                                _indicatorBadge('SMOKE', LC.darkTextSub),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _indicatorBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 7, fontWeight: FontWeight.w600),
      ),
    );
  }
}













// ============================================================
// PREMIUM CHEMICAL CARD (Left Sidebar)
// ============================================================
class _PremiumChemTile extends StatefulWidget {
  final Chemical c;
  const _PremiumChemTile({required this.c});
  @override
  State<_PremiumChemTile> createState() => _PremiumChemTileState();
}

class _PremiumChemTileState extends State<_PremiumChemTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.grab,
      child: GestureDetector(
        // INSTANT drag (no threshold) - smooth & responsive
        dragStartBehavior: DragStartBehavior.down,
        onPanStart: (d) {
          final state = context.findAncestorStateOfType<_LabScreenState>();
          state?.startChemicalDrag(widget.c, d.globalPosition);
        },
        onPanUpdate: (d) {
          final state = context.findAncestorStateOfType<_LabScreenState>();
          state?.updateChemicalDrag(d.globalPosition);
        },
        onPanEnd: (_) {
          final state = context.findAncestorStateOfType<_LabScreenState>();
          state?.endChemicalDrag();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: _isHovered
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      LC.darkAccent.withValues(alpha: 0.25),
                      LC.darkPanelElev,
                    ],
                  )
                : null,
            color: _isHovered ? null : LC.darkPanelElev,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered ? LC.darkAccentBright : LC.darkBorder,
              width: _isHovered ? 1.4 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.6 : 0.35),
                blurRadius: _isHovered ? 10 : 5,
                offset: Offset(0, _isHovered ? 6 : 2),
              ),
              if (_isHovered)
                BoxShadow(
                  color: LC.darkAccentBright.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 0),
                ),
            ],
          ),
          child: Row(children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              scale: _isHovered ? 1.08 : 1.0,
              child: SizedBox(
                width: 28,
                height: 40,
                child: CustomPaint(
                  painter: MiniBottlePainter(
                    color: widget.c.color,
                    state: widget.c.state,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.c.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    shadows: [Shadow(color: Colors.black87, blurRadius: 3, offset: Offset(0, 1))],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.c.formula,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                    shadows: [Shadow(color: Colors.black87, blurRadius: 3, offset: Offset(0, 1))],
                  ),
                ),
              ],
            )),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              opacity: _isHovered ? 1.0 : 0.0,
              child: Icon(Icons.drag_indicator, size: 14, color: LC.darkAccentBright),
            ),
          ]),
        ),
      ),
    );
  }
}

// ============================================================
// PREMIUM EQUIPMENT CARD (Right Sidebar)
// ============================================================
class _PremiumEquipCard extends StatefulWidget {
  final EquipShape s; 
  final VoidCallback onTap;
  const _PremiumEquipCard({required this.s, required this.onTap});
  @override
  State<_PremiumEquipCard> createState() => _PremiumEquipCardState();
}

class _PremiumEquipCardState extends State<_PremiumEquipCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250), // SMOOTHER
          curve: Curves.easeOutQuart,
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          width: 68,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: _isHovered ? LC.darkAccent.withValues(alpha: 0.15) : LC.darkPanelElev,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered ? LC.darkAccentBright : LC.darkBorder,
              width: _isHovered ? 1.4 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.45 : 0.2),
                blurRadius: _isHovered ? 16 : 6,
                offset: Offset(0, _isHovered ? 8 : 3),
              ),
              if (_isHovered)
                BoxShadow(
                  color: LC.darkAccentBright.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                ),
            ],
          ),
          child: Column(children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 250), // SMOOTHER
              curve: Curves.easeOutQuart,
              scale: _isHovered ? 1.1 : 1.0,
              child: Icon(widget.s.icon, color: _isHovered ? Colors.white : LC.darkAccentBright, size: 20),
            ),
            const SizedBox(height: 5),
            Text(
              widget.s.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: _isHovered ? Colors.white : LC.darkText, fontSize: 10, shadows: [Shadow(color: Colors.black87, blurRadius: 3, offset: Offset(0, 1))],
                fontWeight: _isHovered ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ============================================================
// PREMIUM EFFECT CARD (Right Sidebar Tools)
// ============================================================
class _PremiumEffectCard extends StatefulWidget {
  final LabEffect effect;
  const _PremiumEffectCard({required this.effect});
  @override
  State<_PremiumEffectCard> createState() => _PremiumEffectCardState();
}

class _PremiumEffectCardState extends State<_PremiumEffectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.grab,
      child: Listener(
        onPointerDown: (event) {
          final state = context.findAncestorStateOfType<_LabScreenState>();
          state?.startEffectDrag(widget.effect, event.position);
        },
        onPointerMove: (event) {
          final state = context.findAncestorStateOfType<_LabScreenState>();
          state?.updateEffectDrag(event.position);
        },
        
        onPointerUp: (_) {
          final state = context.findAncestorStateOfType<_LabScreenState>();
          state?.endEffectDrag();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250), // SMOOTHER
          curve: Curves.easeOutQuart,
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          width: 62, height: 62,
          decoration: BoxDecoration(
            color: _isHovered ? widget.effect.color.withValues(alpha: 0.15) : LC.darkPanelElev,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isHovered ? widget.effect.color : LC.darkBorder,
              width: _isHovered ? 1.4 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.45 : 0.2),
                blurRadius: _isHovered ? 16 : 6,
                offset: Offset(0, _isHovered ? 8 : 3),
              ),
              if (_isHovered)
                BoxShadow(
                  color: widget.effect.color.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                ),
            ],
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 250), // SMOOTHER
              curve: Curves.easeOutQuart,
              scale: _isHovered ? 1.15 : 1.0,
              child: Icon(widget.effect.icon, color: _isHovered ? Colors.white : widget.effect.color, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              widget.effect.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: _isHovered ? Colors.white : LC.darkText, fontSize: 9, shadows: [Shadow(color: Colors.black87, blurRadius: 3, offset: Offset(0, 1))],
                fontWeight: _isHovered ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
// ============================================================
// PREMIUM HEADER BUTTON (Toolbar)
// ============================================================
class _PremiumHeaderBtn extends StatefulWidget {
  final IconData icon; final String label; final VoidCallback onTap; final bool primary; final Color hoverColor;
  const _PremiumHeaderBtn({required this.icon, required this.label, required this.onTap, this.primary = false, this.hoverColor = Colors.blue});
  @override
  State<_PremiumHeaderBtn> createState() => _PremiumHeaderBtnState();
}

class _PremiumHeaderBtnState extends State<_PremiumHeaderBtn> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: _isHovered ? widget.hoverColor.withValues(alpha: 0.15) : (widget.primary ? LC.success : LC.darkPanel),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _isHovered ? widget.hoverColor : (widget.primary ? LC.success : LC.darkBorder), width: 1.0),
            boxShadow: _isHovered ? [BoxShadow(color: widget.hoverColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : [],
          ),
          child: Row(children: [
            Icon(widget.icon, size: 12, color: _isHovered ? widget.hoverColor : (widget.primary ? LC.darkText : LC.darkTextSub)),
            const SizedBox(width: 5),
            Text(widget.label, style: TextStyle(color: _isHovered ? widget.hoverColor : (widget.primary ? LC.darkText : LC.darkTextSub), fontSize: 10, fontWeight: _isHovered ? FontWeight.w600 : FontWeight.normal)),
          ]),
        ),
      ),
    );
  }
}

// ============================================================
// PREMIUM FILTER CHIP
// ============================================================
class _PremiumFilterChip extends StatefulWidget {
  final String label; final bool isActive; final VoidCallback onTap;
  const _PremiumFilterChip({required this.label, required this.isActive, required this.onTap});
  @override
  State<_PremiumFilterChip> createState() => _PremiumFilterChipState();
}

class _PremiumFilterChipState extends State<_PremiumFilterChip> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered && !widget.isActive ? -3 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: widget.isActive ? LC.darkAccent : (_isHovered ? LC.darkPanelElev.withValues(alpha: 0.9) : LC.darkPanelElev),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: widget.isActive ? LC.darkAccentBright : (_isHovered ? LC.darkAccentBright : LC.darkBorder),
              width: _isHovered && !widget.isActive ? 1.2 : 1.0,
            ),
            boxShadow: [
              // Normal state floating shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
              // Hover glow
              if (_isHovered && !widget.isActive)
                BoxShadow(
                  color: LC.darkAccentBright.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                color: widget.isActive || _isHovered ? Colors.white : LC.darkTextSub,
                fontSize: 10,
                fontWeight: widget.isActive || _isHovered ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// ============================================================
// PREMIUM CLEAR BUTTON (Red Icon)
// ============================================================
class _PremiumClearBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _PremiumClearBtn({required this.onTap});
  @override
  State<_PremiumClearBtn> createState() => _PremiumClearBtnState();
}

class _PremiumClearBtnState extends State<_PremiumClearBtn> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered ? LC.danger.withValues(alpha: 0.15) : LC.darkPanelElev,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: _isHovered ? LC.danger : LC.darkBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.5 : 0.3),
                blurRadius: _isHovered ? 10 : 6,
                offset: Offset(0, _isHovered ? 5 : 3),
              ),
              if (_isHovered)
                BoxShadow(color: LC.danger.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 0)),
            ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.cleaning_services, size: 16, color: _isHovered ? LC.danger : LC.darkTextSub),
            const SizedBox(width: 8),
            Text('Clear', style: TextStyle(color: _isHovered ? LC.danger : LC.darkTextSub, fontSize: 11, fontWeight: _isHovered ? FontWeight.w600 : FontWeight.normal)),
          ]),
        ),
      ),
    );
  }
}
// ============================================================
// PREMIUM pH COLOR CHART BUTTON (Floating + Hover)
// ============================================================
class _PremiumColorChartBtn extends StatefulWidget {
  const _PremiumColorChartBtn();
  @override
  State<_PremiumColorChartBtn> createState() => _PremiumColorChartBtnState();
}

class _PremiumColorChartBtnState extends State<_PremiumColorChartBtn> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => PhColorBook.show(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            gradient: _isHovered
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [LC.darkAccent.withValues(alpha: 0.25), LC.darkPanelElev],
                  )
                : null,
            color: _isHovered ? null : LC.darkPanelElev,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: _isHovered ? LC.darkAccentBright : LC.darkBorder,
              width: _isHovered ? 1.4 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.5 : 0.3),
                blurRadius: _isHovered ? 10 : 6,
                offset: Offset(0, _isHovered ? 6 : 3),
              ),
              if (_isHovered)
                BoxShadow(
                  color: LC.darkAccentBright.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 0),
                ),
            ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.menu_book, size: 16, color: _isHovered ? Colors.white : LC.darkAccentBright),
            const SizedBox(width: 8),
            Text(
              'pH Color Chart',
              style: TextStyle(
                color: _isHovered ? Colors.white : LC.darkTextSub,
                fontSize: 11,
                fontWeight: _isHovered ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
