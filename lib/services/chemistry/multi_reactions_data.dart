part of chem_lab;

final Map<String, ReactionInfo> multiReactions = {
  'hcl+naoh+phenol': const ReactionInfo(
    name: 'Titration Endpoint',
    equation: 'HCl + NaOH + Phenolphthalein -> Pink',
    type: 'Titration',
    description: 'Indicator turns pink at endpoint. NaOH in excess.',
    products: ['NaCl', 'H2O', 'Pink indicator'],
    colorChange: Color(0xFFE91E63),
  ),
  'agno3+cuso4+nacl': const ReactionInfo(
    name: 'Competitive Precipitation',
    equation: 'AgNO3 + NaCl -> AgCl + NaNO3 (favored)',
    type: 'Selective Precipitation',
    description: 'AgCl precipitates first (Ksp lower). Cu stays in solution.',
    products: ['AgCl', 'NaNO3', 'CuSO4'],
    precipitate: true,
    precipitateColor: Color(0xFFF0F0F0),
    colorChange: Color(0xFF9BB8D0),
  ),
  'cuso4+hcl+naoh': const ReactionInfo(
    name: 'Sequential Neutralization',
    equation: 'HCl + NaOH -> NaCl; CuSO4 + 2NaOH -> Cu(OH)2',
    type: 'Multi-step',
    description: 'Base neutralizes acid first, then precipitates Cu(OH)2.',
    products: ['NaCl', 'Cu(OH)2', 'H2O'],
    precipitate: true,
    precipitateColor: Color(0xFF3D7FA8),
    releasesHeat: true,
  ),
  'cuso4+h2so4+naoh': const ReactionInfo(
    name: 'Complex Precipitation',
    equation: 'H2SO4 + 2NaOH -> Na2SO4; CuSO4 + 2NaOH -> Cu(OH)2',
    type: 'Multi-step',
    description: 'Blue precipitate with exothermic neutralization.',
    products: ['Na2SO4', 'Cu(OH)2', 'H2O'],
    precipitate: true,
    precipitateColor: Color(0xFF3D7FA8),
    releasesHeat: true,
  ),
  'hcl+nacl+naoh': const ReactionInfo(
    name: 'Neutralization with spectator',
    equation: 'HCl + NaOH -> NaCl + H2O',
    type: 'Neutralization',
    description: 'NaCl is spectator ion. Reaction proceeds normally.',
    products: ['NaCl', 'H2O'],
    releasesHeat: true,
    colorChange: Color(0xFFC5D8E5),
  ),
  'hcl+naoh+phenolphthalein': const ReactionInfo(
    name: 'Neutralization (Phenolphthalein)',
    equation: 'HCl + NaOH + Phenolphthalein -> NaCl + H2O (Pink to Colorless)',
    type: 'Neutralization',
    description: 'Acid neutralizes base, indicator changes from pink to colorless.',
    products: ['NaCl', 'H2O'],
    colorChange: Color(0x00FFFFFF),
    startColor: Color(0xFFE91E63),
    endColor: Color(0x00FFFFFF),
    baseDurationSec: 2.0,
  ),
  'cuso4+naoh+hcl': const ReactionInfo(
    name: 'Copper Complex Dissolves',
    equation: 'Cu(OH)2 + 2HCl -> CuCl2 + 2H2O',
    type: 'Acid Dissolution',
    description: 'Blue precipitate dissolves in excess acid to form green/blue solution.',
    products: ['CuCl2', 'H2O'],
    colorChange: Color(0xFF4CAF50),
    startColor: Color(0xFF5DADE2),
    endColor: Color(0xFF4CAF50),
    baseDurationSec: 3.0,
  ),
  'agno3+nacl+nh4oh': const ReactionInfo(
    name: 'Silver Complex Formation',
    equation: 'AgCl + 2NH4OH -> [Ag(NH3)2]Cl + 2H2O',
    type: 'Complexation',
    description: 'White AgCl precipitate dissolves in ammonia.',
    products: ['[Ag(NH3)2]Cl', 'H2O'],
    colorChange: Color(0x00FFFFFF),
    startColor: Color(0xFFFFFFFF),
    endColor: Color(0x00FFFFFF),
    baseDurationSec: 3.0,
  ),
};
 
// ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â ... [Corrupted comment cleaned]
// WRONG COMBINATIONS -> SIDE EFFECTS
// ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â ... [Corrupted comment cleaned]


