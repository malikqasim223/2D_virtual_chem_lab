part of chem_lab;

class ReactionInfo {
  final String name, equation, type, description;
  final List<String> products;
  final bool bubbles, precipitate;
  final Color? colorChange;
  final bool requiresHeat;
  final bool releasesHeat;
  final String? gasEvolution;
  final Color? precipitateColor;
  final bool producesSmoke;
  final bool foam;
  final bool isViolent;
  const ReactionInfo({required this.name, required this.equation, required this.type,
    required this.description, required this.products,
    this.bubbles = false, this.precipitate = false, this.colorChange,
    this.requiresHeat = false, this.releasesHeat = false,
    this.gasEvolution, this.precipitateColor, this.producesSmoke = false,
    this.foam = false,
    this.isViolent = false});
}


