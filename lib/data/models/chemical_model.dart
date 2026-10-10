part of chem_lab;

class Chemical {
  final String id, name, formula, state, category;
  final Color color;
  const Chemical({required this.id, required this.name, required this.formula,
    required this.state, required this.category, required this.color});
}


class ChemLayer {
  final String chemId;
  final Color color;
  double volume;
  final bool isSolid;
  double dissolveProgress;
  ChemLayer({required this.chemId, required this.color, required this.volume, this.isSolid = false, this.dissolveProgress = 0.0});
}


class ChemDetail {
  final String uses, properties, safety, occurrence;
  final String? industrial, history, commonName, appearance, reactions;
  final double? molarMass, boilingPoint, meltingPoint, density;
  final String? ph;
  final List<String> hazards; // hazard symbols: corrosive, toxic, flammable, oxidizer, carcinogen, irritant
  final List<MoleculeAtom>? atoms; // for structure drawing
  final List<MoleculeBond>? bonds;
  const ChemDetail({
    required this.uses,
    required this.properties,
    required this.safety,
    required this.occurrence,
    this.industrial,
    this.history,
    this.commonName,
    this.appearance,
    this.reactions,
    this.molarMass,
    this.boilingPoint,
    this.meltingPoint,
    this.density,
    this.ph,
    this.hazards = const [],
    this.atoms,
    this.bonds,
  });
}


