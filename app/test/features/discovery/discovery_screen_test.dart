import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/discovery/presentation/screens/discovery_screen.dart';

void main() {
  testWidgets('filtra locais por texto de busca', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DiscoveryScreen()));

    await tester.enterText(
      find.byKey(const ValueKey('search_text_field')),
      'academia',
    );
    await tester.pump();

    expect(find.text('Academia para Idosos'), findsOneWidget);
    expect(find.text('Jardim das Flores'), findsNothing);
  });

  testWidgets('filtra locais por categoria', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DiscoveryScreen()));

    await tester.tap(find.byKey(const ValueKey('category_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Esporte').last);
    await tester.pumpAndSettle();

    expect(find.text('Academia para Idosos'), findsOneWidget);
    expect(find.text('Jardim das Flores'), findsNothing);
  });

  testWidgets('filtra locais por distância', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DiscoveryScreen()));

    await tester.tap(find.text('Cidade'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Até 5 km'));
    await tester.pumpAndSettle();

    expect(find.text('Academia para Idosos'), findsOneWidget);
    expect(find.text('La Boca Empanadas - Americana'), findsNothing);
  });
}
