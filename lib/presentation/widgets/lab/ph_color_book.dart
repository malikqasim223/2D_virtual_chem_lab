part of chem_lab;

class PhColorBook {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (ctx) => Dialog(
        backgroundColor: LC.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 520,
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(children: [
                const Icon(Icons.menu_book, color: LC.accentBright, size: 20),
                const SizedBox(width: 10),
                const Text('pH Color Reference Chart',
                  style: TextStyle(color: LC.text, fontSize: 14,
                    fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close, color: LC.textDim, size: 18),
                ),
              ]),
              const SizedBox(height: 4),
              const Text('Compare your result with this chart',
                style: TextStyle(color: LC.textDim, fontSize: 11)),
              const SizedBox(height: 12),
              const Divider(color: LC.borderSoft, height: 1),
              const SizedBox(height: 12),
              
              // Color scale
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(14, (i) {
                      final ph = i + 1;
                      final color = PhCalculator.colorForPh(ph.toDouble());
                      final desc = PhCalculator.describe(ph.toDouble());
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(children: [
                          Container(
                            width: 50, height: 28,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            child: Center(
                              child: Text('pH $ph',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(desc,
                              style: const TextStyle(color: LC.text, fontSize: 12,
                                fontWeight: FontWeight.w500)),
                          ),
                          Text(
                            _getExample(ph),
                            style: const TextStyle(color: LC.textDim, fontSize: 11,
                              fontStyle: FontStyle.italic),
                          ),
                        ]),
                      );
                    }),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              const Divider(color: LC.borderSoft, height: 1),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.info_outline, color: LC.textDim, size: 12),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Use this chart to identify substances as Acid, Base, or Neutral',
                    style: TextStyle(color: LC.textDim, fontSize: 10),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  static String _getExample(int ph) {
    switch (ph) {
      case 1: return 'HCl, H₂SO₄';
      case 2: return 'Lemon juice';
      case 3: return 'Vinegar';
      case 4: return 'Tomato';
      case 5: return 'Coffee';
      case 6: return 'Milk';
      case 7: return 'Pure water';
      case 8: return 'Sea water';
      case 9: return 'Baking soda';
      case 10: return 'Soap';
      case 11: return 'Ammonia';
      case 12: return 'Lime water';
      case 13: return 'NaOH, KOH';
      case 14: return 'Drain cleaner';
      default: return '';
    }
  }
}
