part of chem_lab;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LC.bgDeep,
      body: Column(
        children: [
          // === TOP HEADER (Same style as Lab Screen) ===
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: LC.panel,
              border: Border(bottom: BorderSide(color: LC.border, width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: LC.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.science, color: LC.accentBright, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Virtual Chemistry Lab',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: LC.text,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Explore / Experiment / Learn',
                      style: TextStyle(
                        fontSize: 12,
                        color: LC.textSub,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // === MAIN CONTENT ===
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Section Title
                      Text(
                        'Choose an Option',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: LC.text,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select a feature to begin your chemistry journey',
                        style: TextStyle(fontSize: 13, color: LC.textSub),
                      ),
                      const SizedBox(height: 40),

                      // Feature Cards Grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 2.8,
                        children: [
                          _buildCard(
                            context,
                            'Virtual Lab',
                            'Interactive experiments with inventory & toolbox',
                            Icons.biotech,
                            LC.info,
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LabScreen())),
                          ),
                          _buildCard(
                            context,
                            'Chem Info',
                            'Chemical encyclopedia & properties',
                            Icons.menu_book,
                            LC.warning,
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChemInfoScreen())),
                          ),
                          _buildCard(
                            context,
                            'History',
                            'Past experiments & saved sessions',
                            Icons.history,
                            LC.success,
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                          ),
                          _buildCard(
                            context,
                            'Settings',
                            'App preferences & configuration',
                            Icons.settings,
                            LC.accentBright,
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // === FOOTER ===
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: LC.panel,
              border: Border(top: BorderSide(color: LC.border, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '2D Virtual Chemistry Lab (Illustrative)',
                  style: TextStyle(fontSize: 11, color: LC.textDim),
                ),
                Text(
                  'Final Year Project',
                  style: TextStyle(fontSize: 11, color: LC.textDim),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: LC.panelElev,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: LC.border, width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: LC.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: LC.textSub,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: LC.textDim),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PLACEHOLDER SCREENS (Chem Info, History, Settings)
// ============================================================

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
    if (d.density != null) rows.add(MapEntry('Density', '${d.density} g/cm³'));
    if (d.meltingPoint != null) rows.add(MapEntry('Melting Point', '${d.meltingPoint} °C'));
    if (d.boilingPoint != null) rows.add(MapEntry('Boiling Point', '${d.boilingPoint} °C'));
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