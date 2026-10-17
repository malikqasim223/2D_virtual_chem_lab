part of chem_lab;

extension EquipShapeX on EquipShape {
  String get label => const ['Beaker','Flask','Test Tube','Cylinder'][index];
  IconData get icon => const [
    Icons.coffee, Icons.science, Icons.biotech, Icons.straighten][index];
  double get maxVol => const [250.0, 250.0, 50.0, 100.0][index];
  Size get size => const [
    Size(140, 165), Size(150, 200), Size(50, 180), Size(75, 170)][index];
}
