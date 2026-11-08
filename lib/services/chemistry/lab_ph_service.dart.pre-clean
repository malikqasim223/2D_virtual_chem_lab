part of chem_lab;

class LabPhService {
  /// Reaction products → pH mapping
  /// When reaction is complete, pH comes from the products (not starting chemicals)
  static const Map<String, double> _productPh = {
    // === NEUTRALIZATION (Acid + Base) → Neutral salt + water ===
    'NaCl': 7.0, 'KCl': 7.0, 'NaNO3': 7.0, 'KNO3': 7.0,
    'Na2SO4': 7.0, 'K2SO4': 7.0, 'CaCl2': 7.0, 'MgCl2': 7.0,
    'BaCl2': 7.0, 'Ca(NO3)2': 7.0, 'MgSO4': 7.0, 'BaSO4': 7.0,
    'AgCl': 7.0, 'AgNO3': 7.0, 'PbCl2': 7.0, 'PbSO4': 7.0,
    'Pb(NO3)2': 7.0, 'NaBr': 7.0, 'KI': 7.0, 'KBr': 7.0,
    'AgI': 7.0, 'AgBr': 7.0, 'PbI2': 7.0,

    // === ACIDIC SALTS (Weak base + Strong acid) ===
    'NH4Cl': 5.0,     // Ammonium chloride — acidic
    'NH4NO3': 5.0,    // Ammonium nitrate — acidic
    '(NH4)2SO4': 5.0, // Ammonium sulfate — acidic
    'FeCl3': 2.5,     // Iron(III) chloride — strongly acidic
    'FeCl2': 4.5,     // Iron(II) chloride — acidic
    'CuCl2': 4.5,     // Copper(II) chloride — acidic
    'CuSO4': 4.0,     // Copper sulfate — acidic
    'ZnCl2': 5.0,     // Zinc chloride — acidic
    'ZnSO4': 5.0,     // Zinc sulfate — acidic
    'AlCl3': 3.5,     // Aluminum chloride — acidic
    'FeSO4': 4.5,     // Iron(II) sulfate — acidic

    // === BASIC SALTS (Strong base + Weak acid) ===
    'Na2CO3': 11.5,   // Sodium carbonate — basic
    'K2CO3': 11.5,    // Potassium carbonate — basic
    'NaHCO3': 8.3,    // Sodium bicarbonate — slightly basic
    'CH3COONa': 8.9,  // Sodium acetate — basic
    'Na2S': 12.5,     // Sodium sulfide — strongly basic
    'K2S': 12.5,      // Potassium sulfide — strongly basic
    'Na3PO4': 12.0,   // Sodium phosphate — basic
    'NaF': 8.5,       // Sodium fluoride — basic
    'CaCO3': 9.0,     // Calcium carbonate — basic (slightly soluble)
    'BaCO3': 9.0,     // Barium carbonate — basic
    'Cu(OH)2': 9.0,   // Copper hydroxide — basic
    'Fe(OH)3': 8.5,   // Iron(III) hydroxide — basic
    'Fe(OH)2': 9.0,   // Iron(II) hydroxide — basic
    'Al(OH)3': 8.5,   // Aluminum hydroxide — amphoteric, slightly basic
    'Mg(OH)2': 9.5,   // Magnesium hydroxide — basic
    'Ca(OH)2': 12.4,  // Calcium hydroxide — strongly basic
    'Ba(OH)2': 12.3,  // Barium hydroxide — strongly basic
    'NaOH': 13.0, 'KOH': 13.0, 'LiOH': 12.5,
    'NH4OH': 11.0,    // Ammonium hydroxide — weak base
    'NH3': 11.0,      // Ammonia — weak base

    // === WATER & GASES ===
    'H2O': 7.0,
    'CO2': 5.6,       // CO2 in water → carbonic acid
    'SO2': 2.9,       // SO2 in water → sulfurous acid
    'H2S': 4.5,       // H2S in water → weak acid
    'NO2': 3.0,       // NO2 + water → nitric acid + NO
    'NH3(g)': 11.0,   // Ammonia gas dissolved
  };

  /// Calculate pH considering reaction state
  static double? calculatePh(EquipItem eq) {
    if (eq.layers.isEmpty) return null;

    // Filter liquid/soluble layers
    final liquidLayers = eq.layers.where((l) =>
      !l.isSolid || l.dissolveProgress >= 0.5).toList();
    if (liquidLayers.isEmpty) return null;

    // === REACTION COMPLETE: Use product-based pH ===
    if (eq.reactionComplete && eq.layers.length >= 2) {
      return _reactionProductPh(eq, liquidLayers);
    }

    // === NO REACTION YET: Use blended pH of starting chemicals ===
    final formulas = liquidLayers.map((l) => l.chemId).toList();
    final volumes = liquidLayers.map((l) => l.volume).toList();
    return PhCalculator.blendedPh(formulas, volumes);
  }

  /// Calculate pH after reaction based on products
  static double _reactionProductPh(EquipItem eq, List<ChemLayer> liquidLayers) {
    final ids = eq.layers.map((l) => l.chemId).toSet();

    // === 1. Check for NEUTRALIZATION (Acid + Base) ===
    final hasStrongAcid = ids.any((id) => 
      id == 'hcl' || id == 'h2so4' || id == 'hno3' || id == 'hbr' || id == 'hi');
    final hasStrongBase = ids.any((id) => 
      id == 'naoh' || id == 'koh' || id == 'lioh' || id == 'baoh2' || id == 'caoh2');
    final hasWeakBase = ids.contains('nh4oh') || ids.contains('nh3');
    final hasWeakAcid = ids.any((id) => 
      id == 'ch3cooh' || id == 'h2co3' || id == 'hcooh');

    if ((hasStrongAcid || hasWeakAcid) && (hasStrongBase || hasWeakBase)) {
      // Calculate excess volume
      final acidVol = eq.layers.where((l) =>
        l.chemId == 'hcl' || l.chemId == 'h2so4' || l.chemId == 'hno3' ||
        l.chemId == 'hbr' || l.chemId == 'hi' || l.chemId == 'ch3cooh' ||
        l.chemId == 'h2co3' || l.chemId == 'hcooh')
        .fold(0.0, (a, b) => a + b.volume);
      
      final baseVol = eq.layers.where((l) =>
        l.chemId.toLowerCase() == 'naoh' || l.chemId.toLowerCase() == 'koh' || l.chemId.toLowerCase() == 'lioh' ||
        l.chemId.toLowerCase() == 'baoh2' || l.chemId.toLowerCase() == 'caoh2' ||
        l.chemId.toLowerCase() == 'nh4oh' || l.chemId.toLowerCase() == 'nh3')
        .fold(0.0, (a, b) => a + b.volume);

      final diff = acidVol - baseVol;

      // Neutralized (within 5 mL)
      if (diff.abs() < 5) {
        // Weak acid/base give slightly off-neutral
        if (hasWeakBase && !hasStrongBase) return 8.0; // NH4OH excess effect
        if (hasWeakAcid && !hasStrongAcid) return 6.5;
        return 7.0;
      }
      
      // Acid excess
      if (diff > 0) {
        // More acid = lower pH
        if (diff > 50) return 1.5;
        if (diff > 25) return 2.5;
        if (diff > 10) return 4.0;
        return 5.5;
      }
      
      // Base excess
      if (diff < 0) {
        final absDiff = diff.abs();
        if (absDiff > 50) return 13.0;
        if (absDiff > 25) return 12.0;
        if (absDiff > 10) return 10.5;
        return 8.5;
      }
    }

    // === 2. Check for ACID + CARBONATE (CO2 produced) ===
    final hasCarbonate = ids.any((id) =>
      id == 'CaCO3' || id == 'Na2CO3' || id == 'K2CO3' || id == 'NaHCO3');
    if (hasStrongAcid && hasCarbonate) {
      return 6.5; // Salt slightly acidic (CO2 escapes)
    }

    // === 3. Check for ACID + METAL ===
    final hasMetal = ids.any((id) =>
      id == 'Zn' || id == 'Fe' || id == 'Mg' || id == 'Al' ||
      id == 'Zn' || id == 'Mn');
    if (hasStrongAcid && hasMetal) {
      // Metal chloride/sulfate forms — slightly acidic
      return 5.0;
    }

    // === 4. Check for PRECIPITATION (Salt + Salt) ===
    final saltPairs = [
      ['AgNO3', 'NaCl'], ['AgNO3', 'KI'], ['AgNO3', 'KBr'], ['AgNO3', 'HCl'],
      ['BaCl2', 'Na2SO4'], ['BaCl2', 'H2SO4'],
      ['Pb(NO3)2', 'KI'], ['Pb(NO3)2', 'NaCl'],
      ['CuSO4', 'H2S'], ['ZnSO4', 'H2S'],
    ];
    
    for (final pair in saltPairs) {
      if (ids.contains(pair[0]) && ids.contains(pair[1])) {
        return 7.0; // Precipitate + neutral salt solution
      }
    }

    // === 5. Check for BASE + SALT (Insoluble hydroxide precipitate) ===
    final hasBase = ids.any((id) =>
      id == 'NaOH' || id == 'KOH' || id == 'LiOH' || id == 'Ba(OH)2');
    final hasMetalSalt = ids.any((id) =>
      id == 'CuSO4' || id == 'FeCl3' || id == 'FeSO4' || id == 'AlCl3' ||
      id == 'MgCl2' || id == 'ZnCl2');
    
    if (hasBase && hasMetalSalt) {
      return 8.5; // Slight base excess (precipitate consumes some)
    }

    // === 6. NO SPECIFIC REACTION: Blended pH ===
    final formulas = liquidLayers.map((l) => l.chemId).toList();
    final volumes = liquidLayers.map((l) => l.volume).toList();
    return PhCalculator.blendedPh(formulas, volumes);
  }

  static Map<String, dynamic>? litmusTest(EquipItem eq) {
    final ph = calculatePh(eq);
    if (ph == null) return null;
    final result = PhCalculator.litmusResult(ph);
    return {
      'ph': ph,
      'result': result,
      'color': PhCalculator.litmusColor(ph),
      'description': result == 'red' ? 'Acid'
          : result == 'blue' ? 'Base' : 'Neutral',
    };
  }

  static Map<String, dynamic>? phPaperTest(EquipItem eq) {
    final ph = calculatePh(eq);
    if (ph == null) return null;
    return {
      'ph': ph,
      'color': PhCalculator.colorForPh(ph),
      'description': PhCalculator.describe(ph),
    };
  }
}
