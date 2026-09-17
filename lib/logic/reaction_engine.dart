import 'package:flutter/material.dart';
import '../data/models/reaction.dart';

class ReactionEngine {
  /// Saari predefined reactions yahan hain
  static final List<Reaction> _reactions = const [
    // 1. Neutralization: HCl + NaOH → NaCl + H₂O
    Reaction(
      id: 'rxn_hcl_naoh',
      name: 'Acid-Base Neutralization',
      reactants: ['hcl', 'naoh'],
      products: ['Sodium Chloride (NaCl)', 'Water (H₂O)'],
      equation: 'HCl + NaOH → NaCl + H₂O',
      type: 'Neutralization',
      bubbles: false,
      precipitate: false,
      colorChange: null,
      description:
          'Hydrochloric acid reacts with sodium hydroxide to form '
          'sodium chloride and water. This is a neutralization reaction. '
          'The solution becomes neutral.',
    ),

    // 2. Precipitation: CuSO₄ + 2NaOH → Cu(OH)₂ + Na₂SO₄
    Reaction(
      id: 'rxn_cuso4_naoh',
      name: 'Precipitation Reaction',
      reactants: ['cuso4', 'naoh'],
      products: [
        'Copper(II) Hydroxide (Cu(OH)₂)',
        'Sodium Sulfate (Na₂SO₄)',
      ],
      equation: 'CuSO₄ + 2NaOH → Cu(OH)₂ + Na₂SO₄',
      type: 'Precipitation',
      bubbles: false,
      precipitate: true,
      colorChange: Color(0xFF81D4FA), // light blue
      description:
          'Copper sulfate reacts with sodium hydroxide to form a blue '
          'precipitate of copper(II) hydroxide. The solution turns '
          'cloudy blue.',
    ),

    // 3. Gas Formation: 2HCl + Na₂CO₃ → 2NaCl + H₂O + CO₂
    Reaction(
      id: 'rxn_hcl_na2co3',
      name: 'Gas Formation (CO₂)',
      reactants: ['hcl', 'na2co3'],
      products: [
        'Sodium Chloride (NaCl)',
        'Water (H₂O)',
        'Carbon Dioxide (CO₂)',
      ],
      equation: '2HCl + Na₂CO₃ → 2NaCl + H₂O + CO₂',
      type: 'Gas Evolution',
      bubbles: true,
      precipitate: false,
      colorChange: null,
      description:
          'Hydrochloric acid reacts with sodium carbonate, producing '
          'carbon dioxide gas. You will see bubbles of gas rising from '
          'the solution.',
    ),

    // 4. Silver Chloride Precipitation: AgNO₃ + NaCl → AgCl + NaNO₃
    Reaction(
      id: 'rxn_agno3_nacl',
      name: 'White Precipitate Formation',
      reactants: ['agno3', 'nacl'],
      products: [
        'Silver Chloride (AgCl)',
        'Sodium Nitrate (NaNO₃)',
      ],
      equation: 'AgNO₃ + NaCl → AgCl + NaNO₃',
      type: 'Precipitation',
      bubbles: false,
      precipitate: true,
      colorChange: Color(0xFFF5F5F5), // white/off-white
      description:
          'Silver nitrate reacts with sodium chloride to form a white '
          'precipitate of silver chloride. This is a classic test for '
          'chloride ions.',
    ),

    // 5. Acid + Metal: Zn + 2HCl → ZnCl₂ + H₂
    Reaction(
      id: 'rxn_zn_hcl',
      name: 'Metal + Acid (Hydrogen Gas)',
      reactants: ['zn', 'hcl'],
      products: [
        'Zinc Chloride (ZnCl₂)',
        'Hydrogen Gas (H₂)',
      ],
      equation: 'Zn + 2HCl → ZnCl₂ + H₂',
      type: 'Single Displacement',
      bubbles: true,
      precipitate: false,
      colorChange: null,
      description:
          'Zinc metal reacts with hydrochloric acid to produce zinc '
          'chloride and hydrogen gas. You will see rapid bubbling.',
    ),
  ];

  /// Verify karo ke diye gaye chemicals (chemical IDs) se koi reaction banti hai
  static ReactionResult verify(List<String> chemicalIds) {
    if (chemicalIds.length < 2) {
      return const ReactionResult(
        matched: false,
        message: 'Add at least 2 chemicals to trigger a reaction.',
      );
    }

    // Unique IDs (duplicates nikaal do)
    final uniqueIds = chemicalIds.toSet().toList()..sort();

    for (final reaction in _reactions) {
      final reactants = [...reaction.reactants]..sort();

      if (reactants.length == uniqueIds.length &&
          reactants.join(',') == uniqueIds.join(',')) {
        return ReactionResult(
          matched: true,
          reaction: reaction,
          message: 'Reaction: ${reaction.name}',
        );
      }
    }

    return const ReactionResult(
      matched: false,
      message: 'No supported reaction found for this combination.',
    );
  }

  /// Saari available reactions return karo (for reference)
  static List<Reaction> getAllReactions() => _reactions;
}