import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_chem_lab/main.dart';

void main() {
  test('Reaction keys are unique', () {
    expect(reactions.length, reactions.keys.toSet().length, reason: 'No duplicate keys');
  });

  test('No duplicate keys in multiReactions', () {
    expect(multiReactions.length, multiReactions.keys.toSet().length);
  });

  test('Phenolphthalein reactions exist', () {
    expect(reactions.containsKey('naoh+phenolphthalein'), true);
    expect(reactions.containsKey('hcl+phenolphthalein'), true);
  });

  test('Critical reaction exists', () {
    expect(reactions.containsKey('hcl+naoh'), true);
  });
}
