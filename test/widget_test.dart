import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_chem_lab/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ChemLabApp());
    expect(find.byType(ChemLabApp), findsOneWidget);
  });
}
