part of chem_lab;

/// Bubble rate for reactions that produce gas.
/// Used for realistic animation intensity.
enum BubbleIntensity { none, slow, moderate, vigorous }

/// Precipitate specification for precipitation reactions.
/// Handles color, settling time, and dissolve-in-excess (e.g., Al(OH)3 + NaOH).
class PrecipitateInfo {
  final Color color;
  final double settleSec;
  final bool dissolvesInExcess;
  final Color? excessColor;

  const PrecipitateInfo({
    required this.color,
    this.settleSec = 2.0,
    this.dissolvesInExcess = false,
    this.excessColor,
  });
}

/// Explosion specification for violent reactions.
/// Handles flash color, duration, screen shake, and smoke.
class ExplosionInfo {
  final Color flashColor;
  final double flashDurationSec;
  final double shakeAmplitude;
  final Color smokeColor;

  const ExplosionInfo({
    this.flashColor = const Color(0xFFFFFFFF),
    this.flashDurationSec = 0.15,
    this.shakeAmplitude = 8.0,
    this.smokeColor = const Color(0xFF757575),
  });
}

/// A single stage in a multi-step color transition.
/// Example: purple KMnO4 → pink → colorless Mn2+.
class ColorStage {
  final double atFraction;
  final Color color;
  final String label;

  const ColorStage({
    required this.atFraction,
    required this.color,
    required this.label,
  });
}
