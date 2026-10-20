part of chem_lab;

class SideEffect {
  final String label;
  final String description;
  final bool fizz;
  final bool smoke;
  final bool colorPulse;
  final bool smallPop;
  final bool heatUp;
  final bool coolDown;
  final Color? tintColor;
  const SideEffect({
    required this.label,
    required this.description,
    this.fizz = false,
    this.smoke = false,
    this.colorPulse = false,
    this.smallPop = false,
    this.heatUp = false,
    this.coolDown = false,
    this.tintColor,
  });
}

SideEffect? detectSideEffect(List<String> chemIds) {
  final set = chemIds.toSet();

  
  if (set.contains('agno3') && set.contains('hcl') && set.contains('naoh')) {
    return const SideEffect(
      label: 'Ag2O PRECIPITATE',
      description: 'AgCl first, then AgOH -> Ag2O brown ppt with excess NaOH.',
      fizz: true, colorPulse: true,
      tintColor: Color(0xFF8D6E63),
    );
  }
  if (set.contains('h2so4') && set.contains('naoh') && set.contains('agno3')) {
    return const SideEffect(
      label: 'AG2SO4 FORMATION',
      description: 'Silver sulfate precipitates, heat released.',
      smoke: true, heatUp: true,
      tintColor: Color(0xFFE0E0E0),
    );
  }
  if (set.contains('nacl') && set.contains('h2so4') && set.contains('cuso4')) {
    return const SideEffect(
      label: 'SO2 GAS RISK',
      description: 'Concentrated H2SO4 + NaCl -> HCl; heating may release SO2.',
      fizz: true, smoke: true,
      tintColor: Color(0xFFCFD8DC),
    );
  }
  return null;
}

// ÃƒÆ’Ã†â€™Ãƒâ€ â‚¬â„¢ÃƒÆ’â‚¬Â ÃƒÂ¢â€šÂ¬â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢â€šÂ¬Â ÃƒÆ’Â¢ÃƒÂ¢â‚¬Å¡Â ... [Corrupted comment cleaned]
// FALLBACK: Unknown combos -> tiny fizz + warmth (realistic "mixing")
// ÃƒÆ’Ã†â€™Ãƒâ€ â‚¬â„¢ÃƒÆ’â‚¬Â ÃƒÂ¢â€šÂ¬â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢â€šÂ¬Â ÃƒÆ’Â¢ÃƒÂ¢â‚¬Å¡Â ... [Corrupted comment cleaned]
SideEffect defaultMixingEffect(List<String> chemIds) {
  return const SideEffect(
    label: 'MIXING',
    description: 'Chemicals mix without reaction. Slight heat from solution.',
    heatUp: true,
    tintColor: Color(0xFFB0BEC5),
  );
}

// ÃƒÆ’Ã†â€™Ãƒâ€ â‚¬â„¢ÃƒÆ’â‚¬Â ÃƒÂ¢â€šÂ¬â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢â€šÂ¬Â ÃƒÆ’Â¢ÃƒÂ¢â‚¬Å¡Â ... [Corrupted comment cleaned]
// PREDEFINED EXPERIMENTS (Manual Lab Guide)
// ÃƒÆ’Ã†â€™Ãƒâ€ â‚¬â„¢ÃƒÆ’â‚¬Â ÃƒÂ¢â€šÂ¬â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢â€šÂ¬Â ÃƒÆ’Â¢ÃƒÂ¢â‚¬Å¡Â ... [Corrupted comment cleaned]


