part of chem_lab;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B101E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // HERO BANNER
              // ==========================================
              Container(
                height: 280, // Adjusted to fit text & fix overflow
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/lab_bg.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.bottomRight,
                      ),
                      
                      // Solid Left Gradient (No withOpacity)
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF0B101E), // Solid
                              Color(0xFF0B101E), // Solid
                              Color(0xB30B101E), // 70% Opacity
                              Color(0x000B101E), // Transparent
                            ],
                            stops: [0.0, 0.4, 0.6, 1.0],
                          ),
                        ),
                      ),
                      
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 450,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Welcome to', style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 6),
                                const Text('Virtual Chemistry Lab', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                                const SizedBox(height: 12),
                                const Text('Explore real chemical reactions with interactive\nexperiments and stunning visuals.', style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
                                const SizedBox(height: 24),
                                
                                InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LabScreen()));
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF00E5FF), Color(0xFF2979FF)],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: const [
                                        BoxShadow(color: Color(0x4D00E5FF), blurRadius: 12, offset: Offset(0, 4))
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.rocket_launch, color: Colors.black, size: 18),
                                        SizedBox(width: 8),
                                        Text('Start Your Journey', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              const Text('Choose a Feature', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(child: _compactCard(context, title: 'Virtual Lab', icon: Icons.science, color: const Color(0xFF3B82F6), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LabScreen())))),
                  const SizedBox(width: 12),
                  Expanded(child: _compactCard(context, title: 'Chem Info', icon: Icons.menu_book, color: const Color(0xFF8B5CF6), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChemInfoScreen())))),
                  const SizedBox(width: 12),
                  Expanded(child: _compactCard(context, title: 'History', icon: Icons.history, color: const Color(0xFF10B981), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())))),
                  const SizedBox(width: 12),
                  Expanded(child: _compactCard(context, title: 'Settings', icon: Icons.settings, color: const Color(0xFFF59E0B), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())))),
                ],
              ),

              const SizedBox(height: 20), 
              
              const Text('Live Statistics', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1F2937), width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statItem('Chemicals', '${allChemicals.length}', Icons.science, const Color(0xFF3B82F6)),
                      _statItem('Reactions', '${reactions.length + multiReactions.length}', Icons.menu_book, const Color(0xFF8B5CF6)),
                      _statItem('Sessions', '0', Icons.folder, const Color(0xFF10B981)),
                      _statItem('Status', 'Online', Icons.check_circle, const Color(0xFFF59E0B)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _compactCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 70, 
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}
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
    return Scaffold(
      backgroundColor: LC.bgDeep,
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
                            Text('${allChemicals.length} chemicals ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ ${reactions.length + multiReactions.length} reactions', style: TextStyle(color: LC.textSub, fontSize: 12)),
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
    );
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

class _HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color? borderColor;
  const _HoverCard({required this.child, required this.onTap, this.borderColor});
  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
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
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: _hovered ? LC.panelElev : LC.panel,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _hovered ? LC.accentBright.withValues(alpha: 0.6) : (widget.borderColor ?? LC.border), width: _hovered ? 1.5 : 1),
            boxShadow: _hovered ? [BoxShadow(color: LC.accentBright.withValues(alpha: 0.15), blurRadius: 16, spreadRadius: 2)] : [],
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

  Color _categoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'acids': return const Color(0xFFE57373);
      case 'bases': return const Color(0xFF64B5F6);
      case 'salts': return const Color(0xFF81C784);
      case 'indicator': return const Color(0xFFBA68C8);
      default: return const Color(0xFF9575CD);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(chem.category);
    return Scaffold(
      backgroundColor: LC.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            _buildHero(context, catColor),
            Expanded(
              child: detail == null
                  ? Center(child: Text('No detailed info available', style: TextStyle(color: LC.textSub)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (detail!.commonName != null) _infoSection('Common Names', detail!.commonName!, Icons.local_offer_outlined, catColor),
                          if (detail!.appearance != null) _infoSection('Appearance', detail!.appearance!, Icons.palette_outlined, catColor),
                          _keyValuesSection(detail!, catColor),
                          if (detail!.uses.isNotEmpty) _infoSection('Uses', detail!.uses, Icons.shopping_bag_outlined, catColor),
                          if (detail!.properties.isNotEmpty) _infoSection('Properties', detail!.properties, Icons.build_outlined, catColor),
                          if (detail!.safety.isNotEmpty) _infoSection('Safety', detail!.safety, Icons.security_outlined, catColor),
                          if (detail!.occurrence.isNotEmpty) _infoSection('Occurrence', detail!.occurrence, Icons.public, catColor),
                          if (detail!.industrial != null) _infoSection('Industrial Production', detail!.industrial!, Icons.factory_outlined, catColor),
                          if (detail!.history != null) _infoSection('History', detail!.history!, Icons.history_edu_outlined, catColor),
                          if (detail!.reactions != null) _infoSection('Known Reactions', detail!.reactions!, Icons.science_outlined, catColor),
                          if (detail!.hazards.isNotEmpty) _hazardsSection(detail!.hazards),
                          _relatedReactionsSection(context, catColor),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, Color catColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [catColor.withValues(alpha: 0.3), LC.panel, LC.panel]),
        border: Border(bottom: BorderSide(color: LC.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => navigatorKey.currentState?.pop(),
            child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: LC.bgDeep.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(8), border: Border.all(color: LC.border)), child: Icon(Icons.arrow_back, color: LC.text, size: 18)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [chem.color.withValues(alpha: 0.6), chem.color.withValues(alpha: 0.25)]),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: chem.color.withValues(alpha: 0.8), width: 2),
                  boxShadow: [BoxShadow(color: chem.color.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 2)],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chem.name, style: const TextStyle(color: LC.text, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 6, children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: LC.bgDeep, borderRadius: BorderRadius.circular(6), border: Border.all(color: catColor.withValues(alpha: 0.6))), child: Text(chem.formula, style: TextStyle(color: catColor, fontSize: 13, fontWeight: FontWeight.w700))),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: catColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6), border: Border.all(color: catColor.withValues(alpha: 0.5))), child: Text(chem.category, style: TextStyle(color: catColor, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.3))),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: LC.info.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6), border: Border.all(color: LC.info.withValues(alpha: 0.5))), child: Text(chem.state, style: TextStyle(color: LC.info, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.3))),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoSection(String title, String body, IconData icon, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: LC.panel, borderRadius: BorderRadius.circular(10), border: Border.all(color: LC.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)), child: Icon(icon, size: 14, color: accent)),
            const SizedBox(width: 10),
            Text(title.toUpperCase(), style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
          ]),
          const SizedBox(height: 10),
          Text(body, style: const TextStyle(color: LC.text, fontSize: 12.5, height: 1.6)),
        ],
      ),
    );
  }

  Widget _keyValuesSection(ChemDetail d, Color accent) {
    final rows = <MapEntry<String, String>>[];
    if (d.molarMass != null) rows.add(MapEntry('Molar Mass', '${d.molarMass} g/mol'));
    if (d.density != null) rows.add(MapEntry('Density', '${d.density} g/cmÃƒâ€šÃ‚Â³'));
    if (d.meltingPoint != null) rows.add(MapEntry('Melting Point', '${d.meltingPoint} Ãƒâ€šÃ‚Â°C'));
    if (d.boilingPoint != null) rows.add(MapEntry('Boiling Point', '${d.boilingPoint} Ãƒâ€šÃ‚Â°C'));
    if (d.ph != null) rows.add(MapEntry('pH', d.ph!));
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: LC.panel, borderRadius: BorderRadius.circular(10), border: Border.all(color: LC.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)), child: Icon(Icons.speed, size: 14, color: accent)),
            const SizedBox(width: 10),
            Text('KEY PROPERTIES', style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
          ]),
          const SizedBox(height: 12),
          ...rows.map((r) => Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: LC.bgDeep, borderRadius: BorderRadius.circular(6), border: Border.all(color: LC.border.withValues(alpha: 0.5))),
            child: Row(children: [
              SizedBox(width: 130, child: Text(r.key, style: TextStyle(color: LC.textSub, fontSize: 11, fontWeight: FontWeight.w500))),
              Expanded(child: Text(r.value, style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w700))),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _hazardsSection(List<String> hazards) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: LC.danger.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: LC.danger.withValues(alpha: 0.4))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: LC.danger.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)), child: Icon(Icons.warning_amber_rounded, size: 14, color: LC.danger)),
            const SizedBox(width: 10),
            Text('HAZARDS', style: TextStyle(color: LC.danger, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
          ]),
          const SizedBox(height: 10),
          Wrap(spacing: 6, runSpacing: 6, children: hazards.map((h) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: LC.danger.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(5), border: Border.all(color: LC.danger.withValues(alpha: 0.5))),
            child: Text(h.toUpperCase(), style: TextStyle(color: LC.danger, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          )).toList()),
        ],
      ),
    );
  }

  Widget _relatedReactionsSection(BuildContext context, Color accent) {
    final related = <MapEntry<String, ReactionInfo>>[];
    for (final e in reactions.entries) {
      final parts = e.key.split('+');
      if (parts.contains(chem.id)) related.add(e);
    }
    for (final e in multiReactions.entries) {
      final parts = e.key.split('+');
      if (parts.contains(chem.id)) related.add(e);
    }
    if (related.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: LC.panel, borderRadius: BorderRadius.circular(10), border: Border.all(color: LC.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)), child: Icon(Icons.link, size: 14, color: accent)),
            const SizedBox(width: 10),
            Text('RELATED REACTIONS (${related.length})', style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
          ]),
          const SizedBox(height: 10),
          ...related.map((e) => _HoverCard(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReactionDetailPage(reactionKey: e.key, reaction: e.value))),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.value.name, style: const TextStyle(color: LC.text, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(e.value.equation, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: LC.accentBright, fontSize: 10.5)),
              ]),
            ),
          )),
        ],
      ),
    );
  }
}

class ReactionDetailPage extends StatelessWidget {
  final String reactionKey;
  final ReactionInfo reaction;
  const ReactionDetailPage({super.key, required this.reactionKey, required this.reaction});

  Color _reactionTypeColor(String type) {
    if (type.contains('Precipitation')) return const Color(0xFF64B5F6);
    if (type.contains('Neutralization')) return const Color(0xFF81C784);
    if (type.contains('Redox')) return const Color(0xFFFFB74D);
    if (type.contains('Displacement')) return const Color(0xFFBA68C8);
    if (type.contains('Gas')) return const Color(0xFF4DD0E1);
    if (type.contains('Decomposition')) return const Color(0xFFE57373);
    if (type.contains('Complex')) return const Color(0xFF9575CD);
    return LC.accentBright;
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _reactionTypeColor(reaction.type);
    return Scaffold(
      backgroundColor: LC.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            _buildHero(context, typeColor),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (reaction.isViolent) _hazardBanner(),
                    _equationCard(typeColor),
                    _infoCard('Description', reaction.description, Icons.info_outline, typeColor),
                    _productsCard(reaction.products),
                    _observationsCard(reaction),
                    _conditionsCard(reaction),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, Color typeColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [typeColor.withValues(alpha: 0.3), LC.panel, LC.panel]),
        border: Border(bottom: BorderSide(color: LC.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => navigatorKey.currentState?.pop(),
            child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: LC.bgDeep.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(8), border: Border.all(color: LC.border)), child: Icon(Icons.arrow_back, color: LC.text, size: 18)),
          ),
          const SizedBox(height: 16),
          Text(reaction.name, style: const TextStyle(color: LC.text, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
          const SizedBox(height: 10),
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6), border: Border.all(color: typeColor.withValues(alpha: 0.5))), child: Row(children: [Icon(Icons.science_outlined, color: typeColor, size: 12), const SizedBox(width: 5), Text(reaction.type.toUpperCase(), style: TextStyle(color: typeColor, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5))])),
            if (reaction.isViolent) ...[
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: LC.danger.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(6), border: Border.all(color: LC.danger.withValues(alpha: 0.6))), child: Row(children: [Icon(Icons.warning_amber, color: LC.danger, size: 12), const SizedBox(width: 5), Text('HAZARDOUS', style: TextStyle(color: LC.danger, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5))])),
            ],
          ]),
        ],
      ),
    );
  }

  Widget _hazardBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [LC.danger.withValues(alpha: 0.2), LC.danger.withValues(alpha: 0.05)]), borderRadius: BorderRadius.circular(10), border: Border.all(color: LC.danger.withValues(alpha: 0.5))),
      child: Row(children: [
        Icon(Icons.warning_amber_rounded, color: LC.danger, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Text('HAZARDOUS DEMONSTRATION\nOnly perform in a controlled laboratory environment.', style: TextStyle(color: LC.danger, fontSize: 11, fontWeight: FontWeight.w600, height: 1.4))),
      ]),
    );
  }

  Widget _equationCard(Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [accent.withValues(alpha: 0.15), LC.panel]), borderRadius: BorderRadius.circular(10), border: Border.all(color: accent.withValues(alpha: 0.4))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)), child: Icon(Icons.functions, size: 14, color: accent)),
            const SizedBox(width: 10),
            Text('BALANCED EQUATION', style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
          ]),
          const SizedBox(height: 12),
          Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: LC.bgDeep, borderRadius: BorderRadius.circular(6), border: Border.all(color: LC.border)), child: Text(reaction.equation, style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.w600, height: 1.5))),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String body, IconData icon, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: LC.panel, borderRadius: BorderRadius.circular(10), border: Border.all(color: LC.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)), child: Icon(icon, size: 14, color: accent)),
          const SizedBox(width: 10),
          Text(title.toUpperCase(), style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
        ]),
        const SizedBox(height: 10),
        Text(body, style: const TextStyle(color: LC.text, fontSize: 12.5, height: 1.6)),
      ]),
    );
  }

  Widget _productsCard(List<String> products) {
    if (products.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: LC.panel, borderRadius: BorderRadius.circular(10), border: Border.all(color: LC.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: LC.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)), child: Icon(Icons.inventory_2_outlined, size: 14, color: LC.success)),
          const SizedBox(width: 10),
          Text('PRODUCTS', style: TextStyle(color: LC.success, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
        ]),
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 6, children: products.map((p) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: LC.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(5), border: Border.all(color: LC.success.withValues(alpha: 0.5))), child: Text(p, style: TextStyle(color: LC.success, fontSize: 11, fontWeight: FontWeight.w700)))).toList()),
      ]),
    );
  }

  Widget _observationsCard(ReactionInfo r) {
    final obs = <MapEntry<String, IconData>>[];
    if (r.bubbles) obs.add(MapEntry('Gas bubbles evolved', Icons.bubble_chart));
    if (r.gasEvolution != null) obs.add(MapEntry('Gas released: ${r.gasEvolution}', Icons.cloud));
    if (r.precipitate) obs.add(MapEntry('Precipitate forms', Icons.water_drop));
    if (r.colorChange != null || r.endColor != null) obs.add(MapEntry('Color change observed', Icons.palette));
    if (r.releasesHeat) obs.add(MapEntry('Exothermic (releases heat)', Icons.thermostat));
    if (r.producesSmoke) obs.add(MapEntry('Smoke/vapor produced', Icons.cloud_queue));
    if (r.foam) obs.add(MapEntry('Foam/fizz produced', Icons.bubble_chart_outlined));
    if (r.isViolent) obs.add(MapEntry('Violent reaction', Icons.warning));
    if (obs.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: LC.panel, borderRadius: BorderRadius.circular(10), border: Border.all(color: LC.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: LC.info.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)), child: Icon(Icons.visibility_outlined, size: 14, color: LC.info)),
          const SizedBox(width: 10),
          Text('OBSERVATIONS', style: TextStyle(color: LC.info, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
        ]),
        const SizedBox(height: 10),
        ...obs.map((o) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            Icon(o.value, size: 14, color: LC.info),
            const SizedBox(width: 10),
            Expanded(child: Text(o.key, style: const TextStyle(color: LC.text, fontSize: 12))),
          ]),
        )),
      ]),
    );
  }

  Widget _conditionsCard(ReactionInfo r) {
    final cond = <String>[];
    if (r.requiresHeat) cond.add('Requires heat');
    if (r.needsAcid) cond.add('Requires acidic medium');
    if (cond.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: LC.warning.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: LC.warning.withValues(alpha: 0.4))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: LC.warning.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)), child: Icon(Icons.tune, size: 14, color: LC.warning)),
          const SizedBox(width: 10),
          Text('REQUIRED CONDITIONS', style: TextStyle(color: LC.warning, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
        ]),
        const SizedBox(height: 10),
        ...cond.map((c) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            Icon(Icons.arrow_right, size: 16, color: LC.warning),
            const SizedBox(width: 6),
            Expanded(child: Text(c, style: const TextStyle(color: LC.text, fontSize: 12))),
          ]),
        )),
      ]),
    );
  }
}
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await LabHistoryService.loadHistory();
    setState(() {
      _history = data;
      _isLoading = false;
    });
  }

  Future<void> _clearHistory() async {
    await LabHistoryService.clearHistory();
    _loadHistory();
  }

  void _showDetails(BuildContext context, dynamic item) {
    final eqList = item['equipment'] as List;
    List<String> allChemIds = [];
    for (var eq in eqList) {
      for (var l in eq['layers']) {
        allChemIds.add(l['chemId']);
      }
    }
    allChemIds.sort();
    final key = allChemIds.join('+');
    final rxn = multiReactions[key] ?? reactions[key];

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: LC.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 550,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(item['name'] ?? 'Experiment Details',
                    style: const TextStyle(color: LC.accentBright, fontSize: 18, fontWeight: FontWeight.bold))),
                  IconButton(
                    icon: const Icon(Icons.close, color: LC.textDim, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  )
                ],
              ),
              const Divider(color: LC.border),
              const SizedBox(height: 12),
              const Text('EQUIPMENT & CHEMICALS', style: TextStyle(color: LC.textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: eqList.length,
                  itemBuilder: (c, i) {
                    final eq = eqList[i];
                    final layers = eq['layers'] as List;
                    if (layers.isEmpty) return const SizedBox.shrink();
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(eq['label'] ?? 'Equipment', style: const TextStyle(color: LC.accent, fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          ...layers.map((l) {
                            final chem = allChemicals.firstWhere((c) => c.id == l['chemId'], orElse: () => allChemicals.first);
                            return Padding(
                              padding: const EdgeInsets.only(left: 8, bottom: 2),
                              child: Row(
                                children: [
                                  Container(width: 4, height: 4, decoration: BoxDecoration(color: chem.color, shape: BoxShape.circle)),
                                  const SizedBox(width: 6),
                                  Text('${chem.name} (${l['volume']} mL)', style: const TextStyle(color: LC.text, fontSize: 12)),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (rxn != null) ...[
                const SizedBox(height: 16),
                const Text('REACTION ANALYSIS', style: TextStyle(color: LC.textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: LC.panelElev,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: LC.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rxn.name, style: const TextStyle(color: LC.success, fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(rxn.equation, style: const TextStyle(color: LC.accentBright, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(rxn.description, style: const TextStyle(color: LC.textSub, fontSize: 11, height: 1.4)),
                      if (rxn.products.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Products: ${rxn.products.join(", ")}', style: const TextStyle(color: LC.warning, fontSize: 11)),
                      ]
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LC.accent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: const Text('Load in Lab', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LabScreen(loadData: item)));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LC.bgDeep,
      appBar: AppBar(
        backgroundColor: LC.panel,
        iconTheme: const IconThemeData(color: LC.text),
        title: const Text('Experiment History', style: TextStyle(color: LC.text)),
        elevation: 0,
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _clearHistory,
              tooltip: 'Clear All History',
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: LC.accentBright))
          : _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: LC.textDim),
                      const SizedBox(height: 16),
                      const Text('No experiments saved yet.', style: TextStyle(color: LC.textSub, fontSize: 16)),
                      const SizedBox(height: 8),
                      const Text('Go to Lab, do an experiment, and press Save.', style: TextStyle(color: LC.textDim, fontSize: 12)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history.length,
                  itemBuilder: (ctx, i) {
                    final item = _history[i];
                    final name = item['name'] ?? 'Unnamed Experiment';
                    final date = DateTime.parse(item['date']).toLocal();
                    final eqList = item['equipment'] as List;
                    int chemCount = 0;
                    for (var eq in eqList) { chemCount += (eq['layers'] as List).length; }

                    return InkWell(
                      onTap: () => _showDetails(ctx, item),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: LC.panel,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: LC.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: LC.accent.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.science, color: LC.accentBright, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: const TextStyle(color: LC.text, fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(color: LC.textDim, fontSize: 11),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('$chemCount chemicals mixed', style: const TextStyle(color: LC.accent, fontSize: 12)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: LC.textDim),
                          ],
                        ),
                      ),
                    );
                  },
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
            color: _hovered ? Colors.white.withValues(alpha: 0.08) : LC.panel,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _hovered ? LC.accent : LC.border),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}