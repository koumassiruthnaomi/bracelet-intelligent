import 'package:flutter_test/flutter_test.dart';

import 'package:bracelet_app/main.dart';

void main() {
  testWidgets('Affiche l\'écran d\'association du bracelet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BraceletApp());

    // Vérifie que l'écran de pairing s'affiche bien au démarrage
    expect(find.text('Associer le bracelet'), findsOneWidget);
    expect(find.text('Associer mon bracelet'), findsOneWidget);
  });
}
