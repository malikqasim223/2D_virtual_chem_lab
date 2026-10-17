part of chem_lab;

class ReactionInfo {
  final String name, equation, type, description;
  final List<String> products;

  // ===== Existing fields (backward-compatible) =====
  final bool bubbles, precipitate;
  final Color? colorChange;
  final bool requiresHeat;
  final bool releasesHeat;
  final String? gasEvolution;
  final Color? precipitateColor;
  final bool producesSmoke;
  final bool foam;
  final bool isViolent;

  // ===== NEW: Real chemistry simulation fields =====
  /// Starting color of solution (before reaction).
  final Color? startColor;

  /// Final color of solution (after reaction).
  final Color? endColor;

  /// Color of evolved gas: NO2 brown, Cl2 green, SO2 pale yellow.
  final Color? gasColor;

  /// Flame color for flame tests: Na yellow, K lilac, Cu blue-green.
  final Color? flameColor;

  /// Bubble production intensity (none/slow/moderate/vigorous).
  final BubbleIntensity bubbleRate;

  /// Detailed precipitate info (color, settle time, dissolve behavior).
  final PrecipitateInfo? precipitateInfo;

  /// Explosion details for violent reactions.
  final ExplosionInfo? explosion;

  /// Multi-stage color transitions: e.g., purple → pink → colorless.
  final List<ColorStage>? colorStages;

  /// Characteristic odor: SO2, NH3, H2S, Cl2.
  final String? odor;

  /// Activation energy (kJ/mol) for Arrhenius-based timing.
  final double? activationEnergyKJ;

  /// Base duration at 25°C (seconds).
  final double? baseDurationSec;

  /// Temperature rise (°C) for exothermic reactions.
  final double? tempDeltaC;

  const ReactionInfo({
    required this.name,
    required this.equation,
    required this.type,
    required this.description,
    required this.products,
    // Existing (unchanged defaults)
    this.bubbles = false,
    this.precipitate = false,
    this.colorChange,
    this.requiresHeat = false,
    this.releasesHeat = false,
    this.gasEvolution,
    this.precipitateColor,
    this.producesSmoke = false,
    this.foam = false,
    this.isViolent = false,
    // NEW (all optional, safe defaults)
    this.startColor,
    this.endColor,
    this.gasColor,
    this.flameColor,
    this.bubbleRate = BubbleIntensity.none,
    this.precipitateInfo,
    this.explosion,
    this.colorStages,
    this.odor,
    this.activationEnergyKJ,
    this.baseDurationSec,
    this.tempDeltaC,
  });
}
