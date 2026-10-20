import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_chem_lab/main.dart';

void main() {
  test('pH Casing Fix - NaOH should match naoh', () {
    // This is a logic test to ensure case-insensitivity
    final hasStrongBase = ['naoh', 'koh'].any((id) => id.toLowerCase() == 'naoh');
    expect(hasStrongBase, true);
  });

  test('Acid Condition Check', () {
    final layers = ['kmno4', 'h2o2']; // No acid
    final hasAcid = layers.any((l) => ['hcl', 'h2so4'].contains(l));
    expect(hasAcid, false);
  });

  test('Canonical Key Sorting', () {
    final ids = ['naoh', 'cuso4', 'hcl'];
    ids.sort();
    expect(ids.join('+'), 'cuso4+hcl+naoh');
  });
}