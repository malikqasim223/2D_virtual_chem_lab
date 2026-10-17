part of chem_lab;

enum LabEffect { heat, cool, stir, thermometer, dropper, litmus, phPaper }

extension LabEffectX on LabEffect {
  String get label => const [
    'Bunsen', 'Ice', 'Stirrer', 'Thermo', 'Dropper', 'Litmus', 'pH Paper'
  ][index];
  IconData get icon => const [
    Icons.local_fire_department, Icons.ac_unit, Icons.rotate_right,
    Icons.thermostat, Icons.water_drop, Icons.description, Icons.colorize
  ][index];
  Color get color => const [
    Color(0xFFC99050), Color(0xFF6B92B8), Color(0xFF7C8FA3),
    Color(0xFFB85450), Color(0xFF8B7BA8), Color(0xFFE53935), Color(0xFF66BB6A)
  ][index];
}


enum EquipShape { beaker, flask, testTube, cylinder }

extension EquipShapeX on EquipShape {
  String get label => const ['Beaker','Flask','Test Tube','Cylinder'][index];
  IconData get icon => const [
    Icons.coffee, Icons.science, Icons.biotech, Icons.straighten][index];
  double get maxVol => const [250.0, 250.0, 50.0, 100.0][index];
  Size get size => const [
    Size(140, 165), Size(150, 200), Size(50, 180), Size(75, 170)][index];
}
