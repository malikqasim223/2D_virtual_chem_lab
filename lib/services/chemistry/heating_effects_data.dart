part of chem_lab;

const Map<String, HeatingEffect> heatingEffects = {
  'cuso4': HeatingEffect(
    label: 'Dehydration',
    equation: 'CuSO4.5H2O -> CuSO4 + 5H2O',
    startTemp: 60,
    colorChange: Color(0xFFF5F5F5),
  ),
  'nahco3': HeatingEffect(
    label: 'Thermal Decomposition',
    equation: '2 NaHCO3 -> Na2CO3 + H2O + CO2',
    startTemp: 50,
    bubbles: true,
  ),
  'caco3': HeatingEffect(
    label: 'Calcination',
    equation: 'CaCO3 -> CaO + CO2',
    startTemp: 150,
    bubbles: true,
  ),
  'agno3': HeatingEffect(
    label: 'Decomposition',
    equation: '2 AgNO3 -> 2 Ag + 2 NO2 + O2',
    startTemp: 200,
    brownFumes: true,
    smoke: true,
    colorChange: Color(0xFF8D6E63),
  ),
  'ethanol': HeatingEffect(
    label: 'Evaporation',
    equation: 'C2H5OH (l) -> C2H5OH (g)  [bp 78C]',
    startTemp: 78,
    bubbles: true,
    smoke: true,
  ),
};
