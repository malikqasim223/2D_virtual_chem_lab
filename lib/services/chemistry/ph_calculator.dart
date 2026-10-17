part of chem_lab;

class PhCalculator {
  static const Map<String, double> _phValues = {
    'HCl': 1.0, 'H2SO4': 1.0, 'HNO3': 1.0, 'HBr': 1.0, 'HI': 1.0,
    'CH3COOH': 3.0, 'H2CO3': 4.5, 'H3PO4': 2.1, 'HF': 3.2,
    'HCOOH': 3.7, 'C6H5COOH': 4.2,
    'NaHSO4': 1.5, 'KHSO4': 1.5,
    'NaCl': 7.0, 'KCl': 7.0, 'KNO3': 7.0, 'NaNO3': 7.0,
    'Na2SO4': 7.0, 'K2SO4': 7.0, 'CaCl2': 7.0, 'MgCl2': 7.0,
    'Na2CO3': 11.5, 'K2CO3': 11.5, 'NaHCO3': 8.3,
    'CH3COONa': 8.9, 'Na2S': 12.5, 'K2S': 12.5,
    'NaOH': 13.0, 'KOH': 13.0, 'LiOH': 12.5,
    'Ca(OH)2': 12.4, 'Ba(OH)2': 12.3, 'Sr(OH)2': 12.3,
    'NH4OH': 11.0, 'NH3': 11.0,
    'H2O': 7.0,
    'Zn': 7.0, 'Fe': 7.0, 'Cu': 7.0, 'Mg': 7.0, 'Al': 7.0,
    'Na': 7.0, 'K': 7.0, 'Ca': 7.0,
  };

  static double forFormula(String formula) {
    if (formula.isEmpty) return 7.0;
    if (_phValues.containsKey(formula)) return _phValues[formula]!;
    for (final entry in _phValues.entries) {
      if (entry.key.toLowerCase() == formula.toLowerCase()) return entry.value;
    }
    if (formula.startsWith('H') && formula != 'H2O') return 2.0;
    if (formula.endsWith('OH') && !formula.contains('CH3')) return 12.0;
    return 7.0;
  }

  static double blendedPh(List<String> formulas, List<double> volumes) {
    if (formulas.isEmpty || volumes.isEmpty) return 7.0;
    if (formulas.length != volumes.length) return 7.0;
    double totalH = 0;
    double totalVol = 0;
    for (int i = 0; i < formulas.length; i++) {
      final ph = forFormula(formulas[i]);
      final vol = volumes[i];
      final hConc = ph < 7 ? pow(10, -ph).toDouble() : 0.0;
      final ohConc = ph > 7 ? pow(10, -(14 - ph)).toDouble() : 0.0;
      final netH = hConc - ohConc;
      totalH += netH * vol;
      totalVol += vol;
    }
    if (totalVol == 0) return 7.0;
    final avgH = totalH / totalVol;
    if (avgH > 0) return -log(avgH) / ln10;
    if (avgH < 0) return 14 + log(-avgH) / ln10;
    return 7.0;
  }

    static Color colorForPh(double ph) {
    if (ph <= 1) return const Color(0xFFD32F2F);   // Deep red
    if (ph <= 2) return const Color(0xFFE53935);   // Red
    if (ph <= 3) return const Color(0xFFF4511E);   // Red-orange
    if (ph <= 4) return const Color(0xFFFF7043);   // Orange
    if (ph <= 5) return const Color(0xFFFFA726);   // Orange-yellow
    if (ph <= 6) return const Color(0xFFFFD54F);   // Yellow
    if (ph <= 7) return const Color(0xFF9CCC65);   // Yellow-green
    if (ph <= 8) return const Color(0xFF66BB6A);   // Green
    if (ph <= 9) return const Color(0xFF26A69A);   // Teal
    if (ph <= 10) return const Color(0xFF29B6F6);  // Light blue
    if (ph <= 11) return const Color(0xFF42A5F5);  // Blue
    if (ph <= 12) return const Color(0xFF5C6BC0);  // Deep blue
    if (ph <= 13) return const Color(0xFF7E57C2);  // Purple
    return const Color(0xFF4A148C);                 // Deep purple
  }

  static String describe(double ph) {
    if (ph < 3) return 'Strong Acid';
    if (ph < 6.5) return 'Weak Acid';
    if (ph < 7.5) return 'Neutral';
    if (ph < 11) return 'Weak Base';
    return 'Strong Base';
  }

  static String litmusResult(double ph) {
    if (ph < 5.0) return 'red';
    if (ph > 9.0) return 'blue';
    return 'purple';
  }

  static Color litmusColor(double ph) {
    final r = litmusResult(ph);
    switch (r) {
      case 'red': return const Color(0xFFE53935);
      case 'blue': return const Color(0xFF1E88E5);
      default: return const Color(0xFF7E57C2);
    }
  }
}

