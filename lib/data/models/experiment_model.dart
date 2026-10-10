part of chem_lab;

class LabExperiment {
  final String name;
  final String description;
  final List<String> steps;
  final List<String> chemicals;
  final String expectedResult;
  const LabExperiment({
    required this.name,
    required this.description,
    required this.steps,
    required this.chemicals,
    required this.expectedResult,
  });
}

const List<LabExperiment> allExperiments = [
  LabExperiment(
    name: 'Acid-Base Neutralization',
    description: 'Mix HCl with NaOH to form salt and water. Exothermic.',
    steps: ['Add HCl to beaker', 'Add NaOH to same beaker', 'Watch temperature rise'],
    chemicals: ['HCl', 'NaOH'],
    expectedResult: 'Salt + Water, warm solution',
  ),
  LabExperiment(
    name: 'AgCl Precipitation',
    description: 'Silver nitrate + sodium chloride gives curdy white precipitate.',
    steps: ['Add AgNO3 to beaker', 'Add NaCl', 'White precipitate settles'],
    chemicals: ['AgNO3', 'NaCl'],
    expectedResult: 'White AgCl precipitate at bottom',
  ),
  LabExperiment(
    name: 'Cu(OH)2 Precipitation',
    description: 'Copper sulfate + sodium hydroxide gives blue gelatinous precipitate.',
    steps: ['Add CuSO4 (blue) to beaker', 'Add NaOH', 'Blue precipitate forms'],
    chemicals: ['CuSO4', 'NaOH'],
    expectedResult: 'Blue Cu(OH)2 precipitate',
  ),
  LabExperiment(
    name: 'Phenolphthalein Titration',
    description: 'Indicator turns pink in basic solution.',
    steps: ['Add HCl + Phenolphthalein', 'Add NaOH dropwise', 'Pink endpoint appears'],
    chemicals: ['HCl', 'NaOH', 'Phenolphthalein'],
    expectedResult: 'Deep pink solution',
  ),
  LabExperiment(
    name: 'Dehydration of CuSO4',
    description: 'Heat blue hydrated copper sulfate to get white anhydrous form.',
    steps: ['Add CuSO4 to beaker', 'Attach Bunsen burner', 'Heat past 60C'],
    chemicals: ['CuSO4'],
    expectedResult: 'Blue -> White (anhydrous)',
  ),
  LabExperiment(
    name: 'Thermal Decomposition of NaHCO3',
    description: 'Heating baking soda releases CO2.',
    steps: ['Add NaHCO3', 'Attach Bunsen', 'Watch CO2 bubbles'],
    chemicals: ['NaHCO3'],
    expectedResult: 'Vigorous CO2 bubbling',
  ),
  LabExperiment(
    name: 'HCl Gas Evolution',
    description: 'NaCl + concentrated H2SO4 releases HCl gas.',
    steps: ['Add NaCl', 'Add H2SO4', 'White fumes rise'],
    chemicals: ['NaCl', 'H2SO4'],
    expectedResult: 'White HCl fumes',
  ),
  LabExperiment(
    name: 'Violent AgNO3 + NaOH + H2SO4',
    description: 'Dangerous combo producing heat and brown Ag2O.',
    steps: ['Add H2SO4', 'Add AgNO3', 'Add NaOH'],
    chemicals: ['H2SO4', 'AgNO3', 'NaOH'],
    expectedResult: 'Heat + brown precipitate + fizz',
  ),
];
// ===== AMOUNT PICKER DIALOG (date-picker style wheel) =====

