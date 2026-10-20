part of chem_lab;

class LitmusColorBook {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Color(0xFF94A3B8).withValues(alpha: 0.2),
      builder: (ctx) => Dialog(
        backgroundColor: LC.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 480,
          constraints: const BoxConstraints(maxHeight: 550),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.menu_book, color: LC.accentBright, size: 20),
                const SizedBox(width: 10),
                const Text('Litmus Paper Reference',
                  style: TextStyle(color: LC.text, fontSize: 14,
                    fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close, color: LC.textDim, size: 18),
                ),
              ]),
              const SizedBox(height: 4),
              const Text('Litmus paper shows only 3 colors — Acid / Base / Neutral',
                style: TextStyle(color: LC.textDim, fontSize: 11)),
              const SizedBox(height: 16),

              // RED — Acid
              _row(
                color: const Color(0xFFE53935),
                label: 'RED',
                result: 'ACID',
                phRange: 'pH 1 - 4',
                examples: 'HCl, H₂SO₄, Vinegar',
              ),
              const SizedBox(height: 12),

              // PURPLE — Neutral
              _row(
                color: const Color(0xFF7E57C2),
                label: 'PURPLE',
                result: 'NEUTRAL',
                phRange: 'pH 5 - 8',
                examples: 'Water, NaCl solution',
              ),
              const SizedBox(height: 12),

              // BLUE — Base
              _row(
                color: const Color(0xFF1E88E5),
                label: 'BLUE',
                result: 'BASE',
                phRange: 'pH 9 - 14',
                examples: 'NaOH, KOH, Soap',
              ),
              const SizedBox(height: 16),

              // Info
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: LC.panelElev,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: LC.borderSoft),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(children: [
                      Icon(Icons.science, color: LC.accentBright, size: 12),
                      SizedBox(width: 6),
                      Text('How Litmus Works',
                        style: TextStyle(color: LC.accentBright, fontSize: 11,
                          fontWeight: FontWeight.w600)),
                    ]),
                    SizedBox(height: 6),
                    Text(
                      'Litmus is a natural dye from lichens. It is the simplest pH test — '
                      'only tells if a substance is Acid, Base, or Neutral.\n\n'
                      'Red litmus → turns BLUE in base\n'
                      'Blue litmus → turns RED in acid',
                      style: TextStyle(color: LC.textSub, fontSize: 10, height: 1.5),
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

  static Widget _row({
    required Color color,
    required String label,
    required String result,
    required String phRange,
    required String examples,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Center(
            child: Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 10,
                fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result,
                style: TextStyle(color: color, fontSize: 14,
                  fontWeight: FontWeight.w700, letterSpacing: 1.0)),
              const SizedBox(height: 3),
              Text(phRange,
                style: const TextStyle(color: LC.text, fontSize: 11,
                  fontWeight: FontWeight.w500)),
              const SizedBox(height: 3),
              Text('Examples: $examples',
                style: const TextStyle(color: LC.textDim, fontSize: 10,
                  fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ]),
    );
  }
}
