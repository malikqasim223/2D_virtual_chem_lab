part of chem_lab;


class HeatingEffect {
  final String label;
  final String equation;
  final double startTemp;
  final bool bubbles;
  final bool smoke;
  final bool brownFumes;
  final Color? colorChange;
  const HeatingEffect({
    required this.label,
    required this.equation,
    required this.startTemp,
    this.bubbles = false,
    this.smoke = false,
    this.brownFumes = false,
    this.colorChange,
  });
}

