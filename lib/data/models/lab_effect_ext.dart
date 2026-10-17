part of chem_lab;

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
