part of chem_lab;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.75, -0.9),
          radius: 1.9,
          colors: [
            Color(0xFF1F2A3F),  // Soft blue glow top-left
            Color(0xFF141A24),  // Mid slate
            Color(0xFF080B10),  // Deep black bottom-right
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: LC.panelElev, borderRadius: BorderRadius.circular(10), border: Border.all(color: LC.border)),
                        child: Icon(Icons.science, color: LC.accent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text('Chemistry Lab', style: TextStyle(color: LC.text, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                      const Spacer(),
                      Container(
                        width: 220, height: 36,
                        decoration: BoxDecoration(color: LC.panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: LC.border)),
                        child: Row(children: [
                          const SizedBox(width: 12),
                          Icon(Icons.search, color: LC.textSub, size: 16),
                          const SizedBox(width: 8),
                          Text('Search...', style: TextStyle(color: LC.textDim, fontSize: 12)),
                        ]),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: LC.panel, shape: BoxShape.circle, border: Border.all(color: LC.border)),
                        child: Center(child: Icon(Icons.person, color: LC.textSub, size: 18)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Pills
                  Row(
                    children: [
                      _HoverPill(label: 'Dashboard', isActive: true, onTap: () {}),
                      const SizedBox(width: 10),
                      _HoverPill(label: 'Virtual Lab', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LabScreen()))),
                      const SizedBox(width: 10),
                      _HoverPill(label: 'Chem Info', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChemInfoScreen()))),
                      const SizedBox(width: 10),
                      _HoverPill(label: 'History', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Stats
                  SizedBox(
                    height: 90,
                    child: Row(
                      children: [
                        Expanded(child: _StatCard(label: 'Chemicals', value: '${allChemicals.length}', icon: Icons.menu_book_outlined)),
                        const SizedBox(width: 16),
                        Expanded(child: _StatCard(label: 'Reactions', value: '${reactions.length + multiReactions.length}', icon: Icons.science_outlined)),
                        const SizedBox(width: 16),
                        Expanded(child: _StatCard(label: 'Equipment', value: '${EquipShape.values.length}', icon: Icons.biotech_outlined)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Action Cards
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 3.2,
                      children: [
                        _ActionCard(title: 'Virtual Lab', subtitle: 'Run interactive experiments', icon: Icons.biotech, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LabScreen()))),
                        _ActionCard(title: 'Chem Info', subtitle: 'Explore encyclopedia', icon: Icons.menu_book, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChemInfoScreen()))),
                        _ActionCard(title: 'History', subtitle: 'View past experiments', icon: Icons.history, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()))),
                        _ActionCard(title: 'Settings', subtitle: 'App preferences', icon: Icons.settings, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

// ==========================================
// PREMIUM HOVER WIDGETS
// ==========================================
class _HoverPill extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _HoverPill({required this.label, this.isActive = false, required this.onTap});
  @override
  State<_HoverPill> createState() => _HoverPillState();
}

class _HoverPillState extends State<_HoverPill> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final active = widget.isActive || _hovered;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: active ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]) : null,
            color: active ? null : LC.panel,
            boxShadow: active ? [BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2, offset: Offset(0, 8))] : [],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: active ? const Color(0xFF8B5CF6) : LC.border, width: active ? 1.5 : 1.0),
            
          ),
          child: Text(widget.label, style: TextStyle(color: active ? LC.text : LC.textSub, fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
        ),
      ),
    );
  }
}

class _StatCard extends StatefulWidget {
  final String label, value;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});
  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: _hovered ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]) : null,
          color: _hovered ? null : LC.panel,
          boxShadow: _hovered ? [BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2, offset: Offset(0, 8))] : [],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _hovered ? const Color(0xFF8B5CF6) : LC.border, width: _hovered ? 1.5 : 1.0),
          
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: _hovered ? LC.accent.withValues(alpha: 0.15) : LC.panelElev, borderRadius: BorderRadius.circular(8)),
              child: Icon(widget.icon, color: _hovered ? LC.accentBright : LC.accent, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.label, style: TextStyle(color: _hovered ? Colors.black : LC.textSub, fontSize: 11, fontWeight: _hovered ? FontWeight.w600 : FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(widget.value, style: TextStyle(color: _hovered ? LC.text : LC.text, fontSize: 24, fontWeight: FontWeight.w700, height: 1.0)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionCard({required this.title, required this.subtitle, required this.icon, required this.onTap});
  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: _hovered ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]) : null,
          color: _hovered ? null : LC.panel,
          boxShadow: _hovered ? [BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2, offset: Offset(0, 8))] : [],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _hovered ? const Color(0xFF8B5CF6) : LC.border, width: _hovered ? 1.5 : 1.0),
            
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _hovered ? LC.accent.withValues(alpha: 0.15) : LC.panelElev,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _hovered ? LC.accent.withValues(alpha: 0.4) : LC.border),
                ),
                child: Icon(widget.icon, color: _hovered ? Colors.white : LC.accent, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.title, style: TextStyle(color: _hovered ? Colors.white : LC.text, fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(widget.subtitle, style: TextStyle(color: _hovered ? Colors.white70 : LC.textSub, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: _hovered ? LC.textSub : LC.textDim),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// PREMIUM CHEM INFO SCREEN
// ==========================================
class ChemInfoScreen extends StatefulWidget {
  const ChemInfoScreen({super.key});
  @override
  State<ChemInfoScreen> createState() => _ChemInfoScreenState();
}

class _ChemInfoScreenState extends State<ChemInfoScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _chemSearch = '';
  String _rxnSearch = '';
  String _selectedChemCat = 'All';
  String _selectedRxnType = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() { if (mounted) setState(() {}); });
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  Color _catColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'acids': return const Color(0xFFEF4444);
      case 'bases': return const Color(0xFF3B82F6);
      case 'salts': return const Color(0xFF10B981);
      case 'indicator': return const Color(0xFFA855F7);
      default: return const Color(0xFF8B5CF6);
    }
  }

  IconData _catIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'acids': return Icons.water_drop_outlined;
      case 'bases': return Icons.science_outlined;
      case 'salts': return Icons.grain;
      case 'indicator': return Icons.palette_outlined;
      case 'all': return Icons.apps;
      default: return Icons.category_outlined;
    }
  }

  List<String> get _chemCats {
    final cats = <String>{'All'};
    for (final c in allChemicals) { cats.add(c.category); }
    final list = cats.toList()..remove('All')..sort();
    return ['All', ...list];
  }

  List<String> get _rxnTypes {
    final types = <String>{'All'};
    for (final r in reactions.values) { types.add(r.type); }
    for (final r in multiReactions.values) { types.add(r.type); }
    final list = types.toList()..remove('All')..sort();
    return ['All', ...list];
  }

  List<Chemical> get _filteredChems {
    final q = _chemSearch.toLowerCase().trim();
    return allChemicals.where((c) {
      final ms = q.isEmpty || c.name.toLowerCase().contains(q) || c.formula.toLowerCase().contains(q);
      final mc = _selectedChemCat == 'All' || c.category == _selectedChemCat;
      return ms && mc;
    }).toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  List<MapEntry<String, ReactionInfo>> get _filteredRxns {
    final q = _rxnSearch.toLowerCase().trim();
    final res = <MapEntry<String, ReactionInfo>>[];
    for (final e in reactions.entries) {
      if ((q.isEmpty || e.value.name.toLowerCase().contains(q) || e.value.equation.toLowerCase().contains(q)) && (_selectedRxnType == 'All' || e.value.type == _selectedRxnType)) res.add(e);
    }
    for (final e in multiReactions.entries) {
      if ((q.isEmpty || e.value.name.toLowerCase().contains(q) || e.value.equation.toLowerCase().contains(q)) && (_selectedRxnType == 'All' || e.value.type == _selectedRxnType)) res.add(e);
    }
    return res..sort((a, b) => a.value.name.compareTo(b.value.name));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.75, -0.9),
          radius: 1.9,
          colors: [
            Color(0xFF1F2A3F),  // Soft blue glow top-left
            Color(0xFF141A24),  // Mid slate
            Color(0xFF080B10),  // Deep black bottom-right
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
        child: Column(
          children: [
            // Hero Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              decoration: BoxDecoration(
                color: LC.panel,
                border: Border(bottom: BorderSide(color: LC.border)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: LC.panelElev, borderRadius: BorderRadius.circular(8), border: Border.all(color: LC.border)), child: Icon(Icons.arrow_back, color: LC.text, size: 18)),
                      ),
                      const SizedBox(width: 16),
                      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: LC.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: LC.accent.withValues(alpha: 0.3))), child: Icon(Icons.menu_book_outlined, color: LC.accent, size: 24)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Chemical Encyclopedia', style: TextStyle(color: LC.text, fontSize: 20, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('${allChemicals.length} chemicals • ${reactions.length + multiReactions.length} reactions', style: TextStyle(color: LC.textSub, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Tabs
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: LC.bgDeep, borderRadius: BorderRadius.circular(10), border: Border.all(color: LC.border)),
                    child: Row(
                      children: [
                        _buildTabBtn('Chemicals', Icons.menu_book_outlined, 0),
                        _buildTabBtn('Reactions', Icons.science_outlined, 1),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildChemsTab(), _buildRxnsTab()],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildTabBtn(String label, IconData icon, int idx) {
    final sel = _tabController.index == idx;
    return Expanded(
      child: InkWell(
        onTap: () => _tabController.animateTo(idx),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? LC.accentBright : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: sel ? [BoxShadow(color: LC.accent.withValues(alpha: 0.2), blurRadius: 8, spreadRadius: 1)] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: sel ? Colors.black : LC.textSub, size: 16),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: sel ? Colors.black : LC.textSub, fontSize: 13, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(String hint, ValueChanged<String> onChanged, String val, VoidCallback onClear) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Container(
        decoration: BoxDecoration(color: LC.panel, borderRadius: BorderRadius.circular(10), border: Border.all(color: LC.border)),
        child: TextField(
          onChanged: onChanged,
          controller: TextEditingController(text: val)..selection = TextSelection.collapsed(offset: val.length),
          style: const TextStyle(color: LC.text, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: LC.textDim, fontSize: 13),
            prefixIcon: Icon(Icons.search, color: LC.textSub, size: 18),
            suffixIcon: val.isNotEmpty ? GestureDetector(onTap: onClear, child: Icon(Icons.close, color: LC.textSub, size: 18)) : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(List<String> options, String selected, Function(String) onSelect, IconData Function(String) getIcon) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final opt = options[i];
          final sel = selected == opt;
          return InkWell(
            onTap: () => onSelect(opt),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? LC.accentBright : LC.panel,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: sel ? LC.accent : LC.border),
                boxShadow: sel ? [BoxShadow(color: LC.accent.withValues(alpha: 0.2), blurRadius: 8)] : [],
              ),
              child: Row(
                children: [
                  Icon(getIcon(opt), size: 12, color: sel ? Colors.black : LC.textSub),
                  const SizedBox(width: 6),
                  Text(opt, style: TextStyle(color: sel ? Colors.black : LC.textSub, fontSize: 11, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChemsTab() {
    final chems = _filteredChems;
    return Column(
      children: [
        _buildSearchBar('Search chemicals...', (v) => setState(() => _chemSearch = v), _chemSearch, () => setState(() => _chemSearch = '')),
        _buildFilters(_chemCats, _selectedChemCat, (v) => setState(() => _selectedChemCat = v), _catIcon),
        Expanded(
          child: chems.isEmpty
              ? const Center(child: Text('No chemicals found', style: TextStyle(color: LC.textSub)))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: chems.length,
                  itemBuilder: (ctx, i) => _buildChemCard(ctx, chems[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildChemCard(BuildContext ctx, Chemical c) {
    return _HoverListCard(
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => ChemDetailPage(chem: c, detail: chemDetails[c.id]))),
      child: Row(
        children: [
          // MiniBottlePainter (same as inventory!)
          SizedBox(
            width: 32, height: 44,
            child: CustomPaint(painter: MiniBottlePainter(color: c.color, state: c.state)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: LC.text, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(children: [
                  Text(c.formula, style: const TextStyle(color: LC.accentBright, fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: LC.panelElev, borderRadius: BorderRadius.circular(3), border: Border.all(color: LC.border)),
                    child: Text(c.state.toUpperCase(), style: TextStyle(color: LC.textSub, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
                  ),
                ]),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 12, color: LC.textDim),
        ],
      ),
    );
  }

  Widget _buildRxnsTab() {
    final rxns = _filteredRxns;
    return Column(
      children: [
        _buildSearchBar('Search reactions...', (v) => setState(() => _rxnSearch = v), _rxnSearch, () => setState(() => _rxnSearch = '')),
        _buildFilters(_rxnTypes, _selectedRxnType, (v) => setState(() => _selectedRxnType = v), (_) => Icons.science_outlined),
        Expanded(
          child: rxns.isEmpty
              ? const Center(child: Text('No reactions found', style: TextStyle(color: LC.textSub)))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: rxns.length,
                  itemBuilder: (ctx, i) => _buildRxnCard(ctx, rxns[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildRxnCard(BuildContext ctx, MapEntry<String, ReactionInfo> e) {
    final r = e.value;
    return _HoverListCard(
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => ReactionDetailPage(reactionKey: e.key, reaction: r))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(r.name, style: const TextStyle(color: LC.text, fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (r.isViolent) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: LC.danger.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)), child: Text('HAZARD', style: TextStyle(color: LC.danger, fontSize: 8, fontWeight: FontWeight.w700))),
            ],
          ),
          const SizedBox(height: 6),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: LC.bgDeep, borderRadius: BorderRadius.circular(6), border: Border.all(color: LC.border)), child: Text(r.equation, style: TextStyle(color: LC.accentBright, fontSize: 11, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: [
            _miniBadge(r.type, LC.info),
            if (r.bubbles) _miniBadge('GAS', LC.info),
            if (r.precipitate) _miniBadge('PPT', LC.warning),
            if (r.releasesHeat) _miniBadge('HEAT', LC.danger),
            if (r.needsAcid) _miniBadge('ACID', LC.warning),
          ]),
        ],
      ),
    );
  }

  Widget _miniBadge(String label, Color color) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)), child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)));
  }
}

// ==========================================
// PREMIUM HOVER LIST CARD
// ==========================================
class _HoverListCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _HoverListCard({required this.child, required this.onTap});
  @override
  State<_HoverListCard> createState() => _HoverListCardState();
}

class _HoverListCardState extends State<_HoverListCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: _hovered ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]) : null,
          color: _hovered ? null : LC.panel,
          boxShadow: _hovered ? [BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2, offset: Offset(0, 8))] : [],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _hovered ? const Color(0xFF8B5CF6) : LC.border, width: _hovered ? 1.5 : 1.0),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class ChemDetailPage extends StatelessWidget {
  final Chemical chem;
  final ChemDetail? detail;
  const ChemDetailPage({super.key, required this.chem, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LC.bgDeep,
      appBar: AppBar(backgroundColor: LC.panel, iconTheme: const IconThemeData(color: LC.text), title: Text(chem.name, style: const TextStyle(color: LC.text, fontSize: 16, fontWeight: FontWeight.w700)), elevation: 0),
      body: detail == null
          ? const Center(child: Text('No details available', style: TextStyle(color: LC.textSub)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: LC.panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: LC.border)),
                    child: Row(children: [
                      Container(width: 60, height: 60, decoration: BoxDecoration(color: chem.color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: chem.color.withValues(alpha: 0.5)))),
                      const SizedBox(width: 20),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(chem.name, style: const TextStyle(color: LC.text, fontSize: 22, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Row(children: [
                          Text(chem.formula, style: TextStyle(color: LC.accentBright, fontSize: 14, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 12),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: LC.panelElev, borderRadius: BorderRadius.circular(4)), child: Text(chem.category, style: TextStyle(color: LC.textSub, fontSize: 10, fontWeight: FontWeight.w600))),
                        ]),
                      ])),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  if (detail!.uses.isNotEmpty) _infoBlock('Uses', detail!.uses, Icons.shopping_bag_outlined),
                  if (detail!.properties.isNotEmpty) _infoBlock('Properties', detail!.properties, Icons.build_outlined),
                  if (detail!.safety.isNotEmpty) _infoBlock('Safety', detail!.safety, Icons.security_outlined),
                  if (detail!.molarMass != null) _keyValueBlock(detail!),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _infoBlock(String title, String body, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: LC.panel, borderRadius: BorderRadius.circular(12), border: Border.all(color: LC.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, size: 16, color: LC.accent), const SizedBox(width: 10), Text(title.toUpperCase(), style: TextStyle(color: LC.accent, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8))]),
        const SizedBox(height: 12),
        Text(body, style: const TextStyle(color: LC.text, fontSize: 13, height: 1.6)),
      ]),
    );
  }

  Widget _keyValueBlock(ChemDetail d) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: LC.panel, borderRadius: BorderRadius.circular(12), border: Border.all(color: LC.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.speed, size: 16, color: LC.accent), const SizedBox(width: 10), Text('KEY PROPERTIES', style: TextStyle(color: LC.accent, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8))]),
        const SizedBox(height: 12),
        if (d.molarMass != null) _row('Molar Mass', '${d.molarMass} g/mol'),
        if (d.density != null) _row('Density', '${d.density} g/cm³'),
        if (d.meltingPoint != null) _row('Melting Point', '${d.meltingPoint} °C'),
        if (d.boilingPoint != null) _row('Boiling Point', '${d.boilingPoint} °C'),
        if (d.ph != null) _row('pH', d.ph!),
      ]),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 140, child: Text(k, style: TextStyle(color: LC.textSub, fontSize: 12))),
        Text(v, style: TextStyle(color: LC.text, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class ReactionDetailPage extends StatelessWidget {
  final String reactionKey;
  final ReactionInfo reaction;
  const ReactionDetailPage({super.key, required this.reactionKey, required this.reaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LC.bgDeep,
      appBar: AppBar(backgroundColor: LC.panel, iconTheme: const IconThemeData(color: LC.text), title: Text(reaction.name, style: const TextStyle(color: LC.text, fontSize: 16, fontWeight: FontWeight.w700)), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reaction.isViolent) Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: LC.danger.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: LC.danger.withValues(alpha: 0.4))),
              child: Row(children: [
                Icon(Icons.warning_amber, color: LC.danger, size: 24),
                const SizedBox(width: 12),
                Expanded(child: Text('HAZARDOUS DEMONSTRATION\nPerform only in controlled environments.', style: TextStyle(color: LC.danger, fontSize: 12, fontWeight: FontWeight.w600, height: 1.4))),
              ]),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: LC.panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: LC.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(reaction.type.toUpperCase(), style: TextStyle(color: LC.accent, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                const SizedBox(height: 10),
                Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: LC.bgDeep, borderRadius: BorderRadius.circular(8), border: Border.all(color: LC.border)), child: Text(reaction.equation, style: TextStyle(color: LC.accentBright, fontSize: 16, fontWeight: FontWeight.w600, height: 1.5))),
                const SizedBox(height: 16),
                Text(reaction.description, style: const TextStyle(color: LC.text, fontSize: 13, height: 1.6)),
              ]),
            ),
            const SizedBox(height: 20),
            if (reaction.products.isNotEmpty) _infoBlock('Products', reaction.products.join(', '), Icons.inventory_2_outlined),
          ],
        ),
      ),
    );
  }

  Widget _infoBlock(String title, String body, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: LC.panel, borderRadius: BorderRadius.circular(12), border: Border.all(color: LC.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, size: 16, color: LC.success), const SizedBox(width: 10), Text(title.toUpperCase(), style: TextStyle(color: LC.success, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8))]),
        const SizedBox(height: 12),
        Text(body, style: const TextStyle(color: LC.text, fontSize: 13, height: 1.6)),
      ]),
    );
  }
}
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LC.bgDeep,
      appBar: AppBar(
        backgroundColor: LC.panel,
        iconTheme: const IconThemeData(color: LC.text),
        title: const Text('History', style: TextStyle(color: LC.text)),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: LC.textDim),
            const SizedBox(height: 20),
            const Text(
              'Experiment History',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: LC.text),
            ),
            const SizedBox(height: 8),
            const Text(
              'No past experiments yet',
              style: TextStyle(fontSize: 14, color: LC.textSub),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LC.bgDeep,
      appBar: AppBar(
        backgroundColor: LC.panel,
        iconTheme: const IconThemeData(color: LC.text),
        title: const Text('Settings', style: TextStyle(color: LC.text)),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 64, color: LC.textDim),
            const SizedBox(height: 20),
            const Text(
              'App Settings',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: LC.text),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configuration coming soon',
              style: TextStyle(fontSize: 14, color: LC.textSub),
            ),
          ],
        ),
      ),
    );
  }
}
