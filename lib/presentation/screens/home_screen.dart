part of chem_lab;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B101E),
      body: Stack(
        children: [
          const Positioned.fill(child: _LiveBackground()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HERO BANNER
                  Container(
                    height: 280,
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
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xFF0B101E),
                                  Color(0xFF0B101E),
                                  Color(0xB30B101E),
                                  Color(0x000B101E),
                                ],
                                stops: [0.0, 0.4, 0.6, 1.0],
                              ),
                            ),
                          ),
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
                                    const Text(
                                      'Welcome to',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Virtual Chemistry Lab',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 34,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Explore chemical reactions with interactive\nexperiments and stunning visuals.',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const LabScreen(),
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF00E5FF),
                                              Color(0xFF2979FF),
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x4D00E5FF),
                                              blurRadius: 12,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.rocket_launch,
                                              color: Colors.black,
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Open Virtual Lab',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'CHOOSE A FEATURE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // NAV CARDS
                  Row(
                    children: [
                      Expanded(
                        child: _NavHoverCard(
                          title: 'Virtual Lab',
                          color: const Color(0xFF3B82F6),
                          imagePath: 'assets/images/lab_card.jpg',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LabScreen(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _NavHoverCard(
                          title: 'Chem Info',
                          color: const Color(0xFF8B5CF6),
                          imagePath: 'assets/images/chem_card.jpg',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChemInfoScreen(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _NavHoverCard(
                          title: 'History',
                          color: const Color(0xFF176571),
                          imagePath: 'assets/images/history_card.jpg',
                          imageOpacity: 1.0,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HistoryScreen(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _NavHoverCard(
                          title: 'Settings',
                          color: const Color(0xFF8877A8),
                          imagePath: 'assets/images/settings_card.jpg',
                          useTexture: true,
                          imageOpacity: 1.0,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  const Text(
                    'QUICK OVERVIEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // STATS (Expanded for Centering)
                  Container(
                    width: double.infinity,
                    height: 90,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF1F2937),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: _statItem(
                            'CHEMICALS',
                            '${allChemicals.length}',
                            Icons.science,
                            const Color(0xFF3B82F6),
                          ),
                        ),
                        Expanded(
                          child: _statItem(
                            'REACTIONS',
                            '${reactions.length + multiReactions.length}',
                            Icons.menu_book,
                            const Color(0xFF8B5CF6),
                          ),
                        ),
                        Expanded(
                          child: _statItem(
                            'VERSION',
                            'v1.0.0',
                            Icons.info_outline,
                            const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

// CONCEPT 2: STUDIO SPLIT-PANE
// CHEM INFO SCREEN (FIXED & CLEAN)
// CHEM INFO SCREEN (REBUILT & FIXED)
class ChemInfoScreen extends StatefulWidget {
  const ChemInfoScreen({super.key});
  @override
  State<ChemInfoScreen> createState() => _ChemInfoScreenState();
}

class _ChemInfoScreenState extends State<ChemInfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _chemSearch = '';
  String _rxnSearch = '';
  String _selectedChemCat = 'All';
  String _selectedRxnType = 'All';
  String? _pinnedChemId;
  String? _pinnedRxnKey;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _catColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'acids':
        return const Color(0xFF8B5CF6);
      case 'bases':
        return const Color(0xFF3B82F6);
      case 'salts':
        return const Color(0xFF06B6D4);
      case 'indicator':
        return const Color(0xFFD946EF);
      case 'others':
        return const Color(0xFF94A3B8);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  IconData _catIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'acids':
        return Icons.water_drop_outlined;
      case 'bases':
        return Icons.science_outlined;
      case 'salts':
        return Icons.grain;
      case 'indicator':
        return Icons.palette_outlined;
      case 'all':
        return Icons.apps;
      default:
        return Icons.category_outlined;
    }
  }

  Color _rxnTypeColor(String type) {
    if (type.contains('Precipitation')) return const Color(0xFF06B6D4);
    if (type.contains('Neutralization')) return const Color(0xFF8B5CF6);
    if (type.contains('Redox')) return const Color(0xFFF59E0B);
    if (type.contains('Displacement')) return const Color(0xFFD946EF);
    if (type.contains('Gas')) return const Color(0xFF38BDF8);
    if (type.contains('Decomposition')) return const Color(0xFFF43F5E);
    if (type.contains('Complex')) return const Color(0xFFA78BFA);
    if (type.contains('Thermite') ||
        type.contains('Explosive') ||
        type.contains('Combustion'))
      return const Color(0xFFFB923C);
    return LC.accentBright;
  }

  List<String> get _chemCats {
    final cats = <String>{'All'};
    for (final c in allChemicals) {
      cats.add(c.category);
    }
    final list = cats.toList()
      ..remove('All')
      ..sort();
    return ['All', ...list];
  }

  List<String> get _rxnTypes {
    final types = <String>{'All'};
    for (final r in reactions.values) {
      types.add(r.type);
    }
    for (final r in multiReactions.values) {
      types.add(r.type);
    }
    final list = types.toList()
      ..remove('All')
      ..sort();
    return ['All', ...list];
  }

  List<Chemical> get _filteredChems {
    final q = _chemSearch.toLowerCase().trim();
    return allChemicals.where((c) {
      final ms =
          q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          c.formula.toLowerCase().contains(q);
      final mc = _selectedChemCat == 'All' || c.category == _selectedChemCat;
      return ms && mc;
    }).toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  List<MapEntry<String, ReactionInfo>> get _filteredRxns {
    final q = _rxnSearch.toLowerCase().trim();
    final res = <MapEntry<String, ReactionInfo>>[];
    for (final e in reactions.entries) {
      if ((q.isEmpty ||
              e.value.name.toLowerCase().contains(q) ||
              e.value.equation.toLowerCase().contains(q)) &&
          (_selectedRxnType == 'All' || e.value.type == _selectedRxnType))
        res.add(e);
    }
    for (final e in multiReactions.entries) {
      if ((q.isEmpty ||
              e.value.name.toLowerCase().contains(q) ||
              e.value.equation.toLowerCase().contains(q)) &&
          (_selectedRxnType == 'All' || e.value.type == _selectedRxnType))
        res.add(e);
    }
    return res..sort((a, b) => a.value.name.compareTo(b.value.name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LC.bgDeep,
      body: Stack(
        children: [
          const Positioned.fill(child: _LiveBackground()),
          SafeArea(
            child: Column(
              children: [
                _buildHeroHeader(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildChemsTab(), _buildRxnsTab()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Container(
        height: 190,
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/chem_banner.png',
                fit: BoxFit.cover,
                alignment: Alignment.bottomRight,
                errorBuilder: (_, __, ___) => Container(color: LC.bgDeep),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF0B101E),
                      Color(0xFF0B101E),
                      Color(0x990B101E),
                      Color(0x000B101E),
                    ],
                    stops: [0.0, 0.25, 0.5, 0.75],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chemical Encyclopedia',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 8),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Explore 79 chemicals & 104 reactions',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 4),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _BannerButton(
                              label: 'Chemicals',
                              icon: Icons.science_outlined,
                              isSelected: _tabController.index == 0,
                              onTap: () => _tabController.animateTo(0),
                            ),
                            const SizedBox(width: 12),
                            _BannerButton(
                              label: 'Reactions',
                              icon: Icons.bolt_outlined,
                              isSelected: _tabController.index == 1,
                              onTap: () => _tabController.animateTo(1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(
    String hint,
    ValueChanged<String> onChanged,
    String val,
    VoidCallback onClear,
  ) {
    return _FloatingSearchBar(
      hint: hint,
      onChanged: onChanged,
      val: val,
      onClear: onClear,
    );
  }

  Widget _buildFilters(
    List<String> options,
    String selected,
    Function(String) onSelect,
    IconData Function(String) getIcon,
    Color Function(String) getColor,
  ) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final opt = options[i];
          return _FloatingFilterChip(
            label: opt,
            icon: getIcon(opt),
            isSelected: selected == opt,
            color: getColor(opt),
            onTap: () => onSelect(opt),
          );
        },
      ),
    );
  }

  Widget _emptyState(String title, String sub) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: LC.textDim.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: LC.textSub,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(color: LC.textDim, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildChemsTab() {
    final chems = _filteredChems;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: _buildSearchBar(
                  'Search chemicals...',
                  (v) => setState(() => _chemSearch = v),
                  _chemSearch,
                  () => setState(() => _chemSearch = ''),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 6,
                child: _buildFilters(
                  _chemCats,
                  _selectedChemCat,
                  (v) => setState(() => _selectedChemCat = v),
                  _catIcon,
                  _catColor,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
          child: Row(
            children: [
              Text(
                '${chems.length} result${chems.length == 1 ? '' : 's'}',
                style: TextStyle(
                  color: LC.textDim,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSidebar(),
              Expanded(
                child: chems.isEmpty
                    ? _emptyState(
                        'No chemicals found',
                        'Try changing search or category filter',
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context)
                                .copyWith(scrollbars: false),
                            child: GridView.builder(
                              padding: const EdgeInsets.fromLTRB(0, 12, 24, 24),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    mainAxisExtent: 70,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                  ),
                              itemCount: chems.length,
                              itemBuilder: (ctx, i) => _LabStyleTile(
                                c: chems[i],
                                onTap: () => Navigator.push(
                                  ctx,
                                  MaterialPageRoute(
                                    builder: (_) => ChemDetailPage(
                                      chem: chems[i],
                                      detail: chemDetails[chems[i].id],
                                      isPinned: _pinnedChemId == chems[i].id,
                                      onPin: () => setState(
                                        () => _pinnedChemId =
                                            _pinnedChemId == chems[i].id
                                            ? null
                                            : chems[i].id,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    final featured = _pinnedChemId != null
        ? allChemicals.firstWhere(
            (c) => c.id == _pinnedChemId,
            orElse: () => allChemicals.first,
          )
        : null;
    return Container(
      width: 260,
      margin: const EdgeInsets.fromLTRB(24, 12, 16, 24),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // <--- EQUAL WIDTH
            children: [
              // CARD 1
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: LC.darkPanelElev,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: LC.darkBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CHEMICAL OVERVIEW',
                      style: TextStyle(
                        color: LC.textDim,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 5,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${allChemicals.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Total Chemicals',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 5,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // CARD 2
              const Text(
                'PINNED CHEMICAL',
                style: TextStyle(
                  color: LC.textDim,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 5,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              if (featured != null && _pinnedChemId != null)
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChemDetailPage(
                        chem: featured,
                        detail: chemDetails[featured.id],
                        isPinned: true,
                        onPin: () => setState(() => _pinnedChemId = null),
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          LC.accent.withValues(alpha: 0.2),
                          LC.darkPanelElev,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: LC.accent.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 30,
                              height: 45,
                              child: CustomPaint(
                                painter: MiniBottlePainter(
                                  color: featured.color,
                                  state: featured.state,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    featured.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    featured.formula,
                                    style: TextStyle(
                                      color: LC.accentBright,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Consolas',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: LC.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: Text(
                              'View Details →',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: LC.darkPanelElev,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: LC.darkBorder),
                  ),
                  child: const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Center content
                    children: [
                      Icon(
                        Icons.push_pin_outlined,
                        size: 22,
                        color: LC.textDim,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'No Chemical Pinned',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 5,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '"Chemistry is the study of change."',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: LC.textSub,
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),

              // CARD 3 (Redesigned, Taller)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF8B5CF6).withValues(alpha: 0.18),
                      LC.darkPanelElev,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.45),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6)
                                .withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lightbulb,
                            color: Color(0xFF8B5CF6),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'DID YOU KNOW?',
                          style: TextStyle(
                            color: Color(0xFF8B5CF6),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 5,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'The only element with no stable isotopes is Technetium (Tc).',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRxnsTab() {
    final rxns = _filteredRxns;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: _buildSearchBar(
                  'Search reactions...',
                  (v) => setState(() => _rxnSearch = v),
                  _rxnSearch,
                  () => setState(() => _rxnSearch = ''),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 6,
                child: _buildFilters(
                  _rxnTypes,
                  _selectedRxnType,
                  (v) => setState(() => _selectedRxnType = v),
                  (_) => Icons.bolt_outlined,
                  _rxnTypeColor,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
          child: Row(
            children: [
              Text(
                '${rxns.length} result${rxns.length == 1 ? '' : 's'}',
                style: TextStyle(
                  color: LC.textDim,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRxnSidebar(),
              Expanded(
                child: rxns.isEmpty
                    ? _emptyState(
                        'No reactions found',
                        'Try changing search or type filter',
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context)
                                .copyWith(scrollbars: false),
                            child: GridView.builder(
                              padding: const EdgeInsets.fromLTRB(0, 12, 24, 24),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisExtent: 95,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                  ),
                              itemCount: rxns.length,
                              itemBuilder: (ctx, i) => _LabStyleRxnTile(
                                r: rxns[i],
                                color: _rxnTypeColor(rxns[i].value.type),
                                onTap: () => Navigator.push(
                                  ctx,
                                  MaterialPageRoute(
                                    builder: (_) => ReactionDetailPage(
                                      reactionKey: rxns[i].key,
                                      reaction: rxns[i].value,
                                      isPinned: _pinnedRxnKey == rxns[i].key,
                                      onPin: () => setState(
                                        () => _pinnedRxnKey =
                                            _pinnedRxnKey == rxns[i].key
                                            ? null
                                            : rxns[i].key,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRxnSidebar() {
    final pinnedRxn = _pinnedRxnKey != null
        ? (reactions[_pinnedRxnKey] ?? multiReactions[_pinnedRxnKey])
        : null;
    final displayKey = _pinnedRxnKey;
    return Container(
      width: 260,
      margin: const EdgeInsets.fromLTRB(24, 12, 16, 24),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // <--- EQUAL WIDTH
            children: [
              // CARD 1
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: LC.darkPanelElev,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: LC.darkBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'REACTION OVERVIEW',
                      style: TextStyle(
                        color: LC.textDim,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 5,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${reactions.length + multiReactions.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Total Reactions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 5,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // CARD 2
              const Text(
                'PINNED REACTION',
                style: TextStyle(
                  color: LC.textDim,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 5,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              if (pinnedRxn != null && displayKey != null)
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReactionDetailPage(
                        reactionKey: displayKey,
                        reaction: pinnedRxn,
                        isPinned: true,
                        onPin: () => setState(() => _pinnedRxnKey = null),
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          LC.accent.withValues(alpha: 0.2),
                          LC.darkPanelElev,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: LC.accent.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pinnedRxn.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pinnedRxn.equation,
                          style: TextStyle(
                            color: LC.accentBright,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Consolas',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: LC.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: Text(
                              'View Details →',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: LC.darkPanelElev,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: LC.darkBorder),
                  ),
                  child: const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Center content
                    children: [
                      Icon(
                        Icons.push_pin_outlined,
                        size: 22,
                        color: LC.textDim,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'No Reaction Pinned',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 5,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '"Every reaction tells a story."',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: LC.textSub,
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),

              // CARD 3 (Redesigned, Taller - Blue Theme)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF3B82F6).withValues(alpha: 0.18),
                      LC.darkPanelElev,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.45),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6)
                                .withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.science,
                            color: Color(0xFF3B82F6),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'DID YOU KNOW?',
                          style: TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 5,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'A catalyst speeds up a reaction without being consumed.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _BannerButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });
  @override
  State<_BannerButton> createState() => _BannerButtonState();
}

class _BannerButtonState extends State<_BannerButton> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    final sel = widget.isSelected;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: sel
                ? LC.accent.withValues(alpha: 0.9)
                : (_isHovered ? LC.panelElev : LC.panel.withValues(alpha: 0.8)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: sel
                  ? LC.accentBright
                  : (_isHovered
                        ? LC.accentBright.withValues(alpha: 0.6)
                        : LC.border),
              width: sel ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: sel
                    ? LC.accent.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: _isHovered ? 0.4 : 0.2),
                blurRadius: sel ? 12 : (_isHovered ? 10 : 4),
                offset: Offset(0, sel ? 4 : (_isHovered ? 4 : 2)),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: sel
                    ? Colors.white
                    : (_isHovered ? Colors.white : LC.textSub),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: sel
                      ? Colors.white
                      : (_isHovered ? Colors.white : LC.textSub),
                  fontSize: 13,
                  fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: 0.3,
                  shadows: sel || _isHovered
                      ? [
                          const Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ]
                      : [],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingSearchBar extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final String val;
  final VoidCallback onClear;
  const _FloatingSearchBar({
    required this.hint,
    required this.onChanged,
    required this.val,
    required this.onClear,
  });
  @override
  State<_FloatingSearchBar> createState() => _FloatingSearchBarState();
}

class _FloatingSearchBarState extends State<_FloatingSearchBar> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.text,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
        height: 40,
        decoration: BoxDecoration(
          color: LC.panel,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _isHovered ? LC.accentBright : LC.border,
            width: _isHovered ? 1.2 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.4 : 0.2),
              blurRadius: _isHovered ? 10 : 6,
              offset: Offset(0, _isHovered ? 4 : 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: widget.onChanged,
          style: const TextStyle(color: LC.text, fontSize: 13),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: LC.textDim, fontSize: 13),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _isHovered ? LC.accentBright : LC.textSub,
              size: 16,
            ),
            suffixIcon: widget.val.isNotEmpty
                ? GestureDetector(
                    onTap: widget.onClear,
                    child: Icon(
                      Icons.close_rounded,
                      color: LC.textSub,
                      size: 16,
                    ),
                  )
                : null,
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }
}

class _FloatingFilterChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  const _FloatingFilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });
  @override
  State<_FloatingFilterChip> createState() => _FloatingFilterChipState();
}

class _FloatingFilterChipState extends State<_FloatingFilterChip> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    final sel = widget.isSelected;
    final col = widget.color;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            gradient: sel
                ? LinearGradient(colors: [col, col.withValues(alpha: 0.75)])
                : null,
            color: sel ? null : (_isHovered ? LC.panelElev : LC.panel),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: sel
                  ? col
                  : (_isHovered ? col.withValues(alpha: 0.5) : LC.border),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: sel
                    ? col.withValues(alpha: 0.35)
                    : Colors.black.withValues(alpha: _isHovered ? 0.3 : 0.1),
                blurRadius: sel ? 8 : (_isHovered ? 8 : 4),
                offset: Offset(0, sel ? 2 : (_isHovered ? 4 : 1)),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 13,
                color: sel
                    ? Colors.white
                    : (_isHovered ? Colors.white : LC.textSub),
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: sel
                      ? Colors.white
                      : (_isHovered ? Colors.white : LC.textSub),
                  fontSize: 11.5,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabStyleTile extends StatefulWidget {
  final Chemical c;
  final VoidCallback onTap;
  const _LabStyleTile({required this.c, required this.onTap});
  @override
  State<_LabStyleTile> createState() => _LabStyleTileState();
}

class _LabStyleTileState extends State<_LabStyleTile> {
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
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFF252B3B) : LC.darkPanelElev,
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
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                height: 40,
                child: CustomPaint(
                  painter: MiniBottlePainter(
                    color: widget.c.color,
                    state: widget.c.state,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.c.formula,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabStyleRxnTile extends StatefulWidget {
  final MapEntry<String, ReactionInfo> r;
  final Color color;
  final VoidCallback onTap;
  const _LabStyleRxnTile({
    required this.r,
    required this.color,
    required this.onTap,
  });
  @override
  State<_LabStyleRxnTile> createState() => _LabStyleRxnTileState();
}

class _LabStyleRxnTileState extends State<_LabStyleRxnTile> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    final col = widget.color;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFF252B3B) : LC.darkPanelElev,
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
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: col.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.r.value.type.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (widget.r.value.isViolent)
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFFFBD2E),
                      size: 11,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  widget.r.value.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Text(
                  widget.r.value.equation,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Consolas',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChemDetailPage extends StatefulWidget {
  final Chemical chem;
  final ChemDetail? detail;
  final bool isPinned;
  final VoidCallback? onPin;
  const ChemDetailPage({
    super.key,
    required this.chem,
    required this.detail,
    this.isPinned = false,
    this.onPin,
  });
  @override
  State<ChemDetailPage> createState() => _ChemDetailPageState();
}

class _ChemDetailPageState extends State<ChemDetailPage> {
  late bool _isPinned;

  @override
  void initState() {
    super.initState();
    _isPinned = widget.isPinned;
  }

  void _togglePin() {
    setState(() => _isPinned = !_isPinned);
    widget.onPin?.call();
  }

  Color _categoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'acids':
        return const Color(0xFF8B5CF6);
      case 'bases':
        return const Color(0xFF3B82F6);
      case 'salts':
        return const Color(0xFF06B6D4);
      case 'indicator':
        return const Color(0xFFD946EF);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chem = widget.chem;
    final detail = widget.detail;
    final catColor = _categoryColor(chem.category);
    return Scaffold(
      backgroundColor: LC.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [catColor.withValues(alpha: 0.2), LC.panel],
                ),
                border: Border(bottom: BorderSide(color: LC.border)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: LC.bgDeep.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: LC.border),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: LC.text,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chem.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              chem.formula,
                              style: TextStyle(
                                color: catColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Consolas',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: LC.bgDeep,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: LC.border),
                              ),
                              child: Text(
                                chem.state,
                                style: TextStyle(
                                  color: LC.textSub,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (widget.onPin != null)
                    _PinButton(isPinned: _isPinned, onTap: _togglePin),
                ],
              ),
            ),
            Expanded(
              child: detail == null
                  ? Center(
                      child: Text(
                        'No detailed info available',
                        style: TextStyle(color: LC.textSub),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (detail.commonName != null)
                            _infoSection(
                              'Common Names',
                              detail.commonName!,
                              Icons.local_offer_outlined,
                              catColor,
                            ),
                          if (detail.appearance != null)
                            _infoSection(
                              'Appearance',
                              detail.appearance!,
                              Icons.palette_outlined,
                              catColor,
                            ),
                          _infoSection(
                            'Uses',
                            detail.uses,
                            Icons.shopping_bag_outlined,
                            catColor,
                          ),
                          _infoSection(
                            'Properties',
                            detail.properties,
                            Icons.build_outlined,
                            catColor,
                          ),
                          _infoSection(
                            'Safety',
                            detail.safety,
                            Icons.security_outlined,
                            catColor,
                          ),
                          _infoSection(
                            'Occurrence',
                            detail.occurrence,
                            Icons.public,
                            catColor,
                          ),
                          if (detail.industrial != null)
                            _infoSection(
                              'Industrial Production',
                              detail.industrial!,
                              Icons.factory_outlined,
                              catColor,
                            ),
                          if (detail.history != null)
                            _infoSection(
                              'History',
                              detail.history!,
                              Icons.history_edu_outlined,
                              catColor,
                            ),
                          if (detail.reactions != null)
                            _infoSection(
                              'Known Reactions',
                              detail.reactions!,
                              Icons.science_outlined,
                              catColor,
                            ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoSection(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LC.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: LC.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(color: LC.textSub, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class ReactionDetailPage extends StatefulWidget {
  final String reactionKey;
  final ReactionInfo reaction;
  final bool isPinned;
  final VoidCallback? onPin;
  const ReactionDetailPage({
    super.key,
    required this.reactionKey,
    required this.reaction,
    this.isPinned = false,
    this.onPin,
  });
  @override
  State<ReactionDetailPage> createState() => _ReactionDetailPageState();
}

class _ReactionDetailPageState extends State<ReactionDetailPage> {
  late bool _isPinned;

  @override
  void initState() {
    super.initState();
    _isPinned = widget.isPinned;
  }

  void _togglePin() {
    setState(() => _isPinned = !_isPinned);
    widget.onPin?.call();
  }

  Color _reactionTypeColor(String type) {
    if (type.contains('Precipitation')) return const Color(0xFF06B6D4);
    if (type.contains('Neutralization')) return const Color(0xFF8B5CF6);
    if (type.contains('Redox')) return const Color(0xFFF59E0B);
    if (type.contains('Displacement')) return const Color(0xFFD946EF);
    if (type.contains('Gas')) return const Color(0xFF38BDF8);
    if (type.contains('Decomposition')) return const Color(0xFFF43F5E);
    if (type.contains('Complex')) return const Color(0xFFA78BFA);
    return LC.accentBright;
  }

  @override
  Widget build(BuildContext context) {
    final reaction = widget.reaction;
    final typeColor = _reactionTypeColor(reaction.type);
    return Scaffold(
      backgroundColor: LC.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [typeColor.withValues(alpha: 0.2), LC.panel],
                ),
                border: Border(bottom: BorderSide(color: LC.border)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: LC.bgDeep.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: LC.border),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: LC.text,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reaction.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reaction.type,
                          style: TextStyle(
                            color: typeColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.onPin != null)
                    _PinButton(isPinned: _isPinned, onTap: _togglePin),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: LC.panel,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: typeColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          reaction.equation,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: typeColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Consolas',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _infoCard(
                      'Description',
                      reaction.description,
                      Icons.info_outline,
                      typeColor,
                    ),
                    _infoCard(
                      'Products',
                      reaction.products.join(' + '),
                      Icons.inventory_2_outlined,
                      typeColor,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String content, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LC.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: LC.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(color: LC.textSub, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinButton extends StatefulWidget {
  final bool isPinned;
  final VoidCallback onTap;
  const _PinButton({required this.isPinned, required this.onTap});
  @override
  State<_PinButton> createState() => _PinButtonState();
}

class _PinButtonState extends State<_PinButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isPinned
                ? LC.accent
                : (_isHovered ? LC.panelElev : LC.panel),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isPinned
                  ? LC.accentBright
                  : (_isHovered
                        ? LC.accentBright.withValues(alpha: 0.5)
                        : LC.border),
              width: widget.isPinned ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isPinned
                    ? LC.accent.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: _isHovered ? 0.4 : 0.2),
                blurRadius: _isHovered ? 12 : 6,
                offset: Offset(0, _isHovered ? 6 : 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  key: ValueKey(widget.isPinned),
                  color: widget.isPinned
                      ? Colors.white
                      : (_isHovered ? Colors.white : LC.textSub),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  widget.isPinned ? 'Unpin' : 'Pin',
                  key: ValueKey(widget.isPinned),
                  style: TextStyle(
                    color: widget.isPinned
                        ? Colors.white
                        : (_isHovered ? Colors.white : LC.textSub),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// RECOVERED: _NavHoverCard (Home Screen 4 buttons)
// ============================================================
class _NavHoverCard extends StatefulWidget {
  final String title;
  final IconData? icon;
  final Color color;
  final VoidCallback onTap;
  final String? imagePath;
  final bool useTexture;
  final double imageOpacity;

  const _NavHoverCard({
    required this.title,
    this.icon,
    required this.color,
    required this.onTap,
    this.imagePath,
    this.useTexture = false,
    this.imageOpacity = 0.65,
  });

  @override
  State<_NavHoverCard> createState() => _NavHoverCardState();
}

class _NavHoverCardState extends State<_NavHoverCard> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered
                    ? (widget.color.computeLuminance() < 0.3
                          ? Color.lerp(widget.color, Colors.white, 0.2)!
                          : widget.color.withValues(alpha: 0.9))
                    : widget.color.withValues(alpha: 0.15),
                width: _isHovered ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? (widget.color.computeLuminance() < 0.3
                            ? Color.lerp(
                                widget.color,
                                Colors.white,
                                0.1,
                              )!.withValues(alpha: 0.5)
                            : widget.color.withValues(alpha: 0.4))
                      : Colors.black.withValues(alpha: 0.6),
                  blurRadius: _isHovered ? 22 : 12,
                  spreadRadius: _isHovered ? 3 : 0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.imagePath != null)
                    Opacity(
                      opacity: widget.imageOpacity,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          widget.color,
                          BlendMode.color,
                        ),
                        child: Image.asset(
                          widget.imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: widget.color.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                    ),
                  if (widget.imagePath != null)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5],
                        ),
                      ),
                    ),
                  if (widget.imagePath == null)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.color.withValues(
                              alpha: widget.useTexture ? 0.4 : 0.2,
                            ),
                            const Color(0xFF0B101E),
                          ],
                        ),
                      ),
                    ),
                  if (widget.useTexture)
                    Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.2,
                          colors: [
                            widget.color.withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon!, color: Colors.white, size: 28),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                              Shadow(
                                color: Colors.black,
                                blurRadius: 16,
                                offset: Offset(0, 0),
                              ),
                              Shadow(
                                color: Colors.black87,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// RECOVERED: _LiveBackground (Floating Dots)
// ============================================================
class _FloatingDot {
  final double startX;
  final double startY;
  final double offset;
  final double radius;
  final double opacity;
  final double speedMultiplier;
  final Color color;
  _FloatingDot({
    required this.startX,
    required this.startY,
    required this.offset,
    required this.radius,
    required this.opacity,
    required this.speedMultiplier,
    required this.color,
  });
}

class _LiveBackground extends StatefulWidget {
  const _LiveBackground();
  @override
  State<_LiveBackground> createState() => _LiveBackgroundState();
}

class _LiveBackgroundState extends State<_LiveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final DateTime _startTime = DateTime.now();
  final List<_FloatingDot> _backDots = [];
  final List<_FloatingDot> _midDots = [];
  final List<_FloatingDot> _frontDots = [];
  final Random _rng = Random(42);

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 60; i++) {
      _backDots.add(
        _FloatingDot(
          startX: _rng.nextDouble(),
          startY: _rng.nextDouble(),
          offset: _rng.nextDouble() * 10,
          radius: 0.5 + _rng.nextDouble() * 0.8,
          opacity: 0.2,
          speedMultiplier: 0.4,
          color: i % 2 == 0 ? Colors.white : const Color(0xFF3B82F6),
        ),
      );
    }
    for (int i = 0; i < 40; i++) {
      _midDots.add(
        _FloatingDot(
          startX: _rng.nextDouble(),
          startY: _rng.nextDouble(),
          offset: _rng.nextDouble() * 10,
          radius: 1.0 + _rng.nextDouble() * 1.2,
          opacity: 0.5,
          speedMultiplier: 0.8,
          color: i % 2 == 0 ? const Color(0xFF8B5CF6) : Colors.white,
        ),
      );
    }
    for (int i = 0; i < 20; i++) {
      _frontDots.add(
        _FloatingDot(
          startX: _rng.nextDouble(),
          startY: _rng.nextDouble(),
          offset: _rng.nextDouble() * 10,
          radius: 1.8 + _rng.nextDouble() * 1.5,
          opacity: 0.9,
          speedMultiplier: 1.2,
          color: i % 3 == 0 ? const Color(0xFF00E5FF) : Colors.white,
        ),
      );
    }
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t =
              DateTime.now().difference(_startTime).inMilliseconds / 1000.0;
          return CustomPaint(
            painter: _SmoothParticlePainter(
              backDots: _backDots,
              midDots: _midDots,
              frontDots: _frontDots,
              timeSeconds: t,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _SmoothParticlePainter extends CustomPainter {
  final List<_FloatingDot> backDots;
  final List<_FloatingDot> midDots;
  final List<_FloatingDot> frontDots;
  final double timeSeconds;
  _SmoothParticlePainter({
    required this.backDots,
    required this.midDots,
    required this.frontDots,
    required this.timeSeconds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawLayer(canvas, size, backDots);
    _drawLayer(canvas, size, midDots);
    _drawLayer(canvas, size, frontDots);
  }

  void _drawLayer(Canvas canvas, Size size, List<_FloatingDot> dots) {
    final paint = Paint();
    for (final dot in dots) {
      final t = timeSeconds * dot.speedMultiplier;
      final wobble = sin(t * 1.5 + dot.offset) * 0.02;
      final dx = ((dot.startX + t * 0.005 + wobble) % 1.0 + 1.0) % 1.0;
      final dy = ((dot.startY + t * 0.01) % 1.0 + 1.0) % 1.0;
      paint.color = dot.color.withValues(alpha: dot.opacity);
      canvas.drawCircle(
        Offset(dx * size.width, dy * size.height),
        dot.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SmoothParticlePainter oldDelegate) =>
      oldDelegate.timeSeconds != timeSeconds;
}

// ============================================================
// RECOVERED: HistoryScreen & SettingsScreen (from backup)
// ============================================================
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
                  Expanded(
                    child: Text(
                      item['name'] ?? 'Experiment Details',
                      style: const TextStyle(
                        color: LC.accentBright,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: LC.textDim, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(color: LC.border),
              const SizedBox(height: 12),
              const Text(
                'EQUIPMENT & CHEMICALS',
                style: TextStyle(
                  color: LC.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
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
                          Text(
                            eq['label'] ?? 'Equipment',
                            style: const TextStyle(
                              color: LC.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...layers.map((l) {
                            final chem = allChemicals.firstWhere(
                              (c) => c.id == l['chemId'],
                              orElse: () => allChemicals.first,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                bottom: 2,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: chem.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${chem.name} (${l['volume']} mL)',
                                    style: const TextStyle(
                                      color: LC.text,
                                      fontSize: 12,
                                    ),
                                  ),
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
                const SizedBox(height: 10),
                const Text(
                  'REACTION ANALYSIS',
                  style: TextStyle(
                    color: LC.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
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
                      Text(
                        rxn.name,
                        style: const TextStyle(
                          color: LC.success,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rxn.equation,
                        style: const TextStyle(
                          color: LC.accentBright,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        rxn.description,
                        style: const TextStyle(
                          color: LC.textSub,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                      if (rxn.products.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Products: ${rxn.products.join(", ")}',
                          style: const TextStyle(
                            color: LC.warning,
                            fontSize: 11,
                          ),
                        ),
                      ],
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: const Text(
                    'Load in Lab',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LabScreen(loadData: item),
                      ),
                    );
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
        title: const Text(
          'Experiment History',
          style: TextStyle(color: LC.text),
        ),
        elevation: 0,
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _clearHistory,
              tooltip: 'Clear All History',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: LC.accentBright),
            )
          : _history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: LC.textDim),
                  const SizedBox(height: 10),
                  const Text(
                    'No experiments saved yet.',
                    style: TextStyle(color: LC.textSub, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Go to Lab, do an experiment, and press Save.',
                    style: TextStyle(color: LC.textDim, fontSize: 12),
                  ),
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
                for (var eq in eqList) {
                  chemCount += (eq['layers'] as List).length;
                }

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
                          decoration: BoxDecoration(
                            color: LC.accent.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.science,
                            color: LC.accentBright,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: LC.text,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  color: LC.textDim,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$chemCount chemicals mixed',
                                style: const TextStyle(
                                  color: LC.accent,
                                  fontSize: 12,
                                ),
                              ),
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
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: LC.text,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configuration coming soon',
              style: TextStyle(fontSize: 18, color: LC.textSub),
            ),
          ],
        ),
      ),
    );
  }
}
