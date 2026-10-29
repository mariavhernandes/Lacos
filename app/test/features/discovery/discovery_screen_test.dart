import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/discovery/data/repositories/discovery_repository.dart';
import 'package:app/features/discovery/domain/models/place_activity.dart';
import 'package:app/features/discovery/presentation/screens/discovery_screen.dart';
import 'package:app/features/discovery/presentation/widgets/place_activity_card.dart';

const _places = [
  PlaceActivity(
    name: 'Academia para Idosos',
    category: 'Lazer',
    description: 'Atividades físicas e convivência.',
    city: 'Americana',
    address: 'Rua A',
    operatingHours: '08:00 - 17:00',
    rating: 4.5,
    mapsLink: '',
    imageAssetsOverride: ['missing-academia.png'],
  ),
  PlaceActivity(
    name: 'Jardim das Flores',
    category: 'Cafeterias',
    description: 'Café e jardim.',
    city: 'Campinas',
    address: 'Rua B',
    operatingHours: '08:00 - 17:00',
    rating: 4.0,
    mapsLink: '',
    imageAssetsOverride: ['missing-jardim.png'],
  ),
  PlaceActivity(
    name: 'La Boca Empanadas - Americana',
    category: 'Restaurantes',
    description: 'Restaurante familiar.',
    city: 'Sumare',
    address: 'Rua C',
    operatingHours: '11:00 - 22:00',
    rating: 4.2,
    mapsLink: '',
    imageAssetsOverride: ['missing-la-boca.png'],
  ),
];

class _FixtureDiscoveryRepository extends DiscoveryRepository {
  @override
  Future<List<PlaceActivity>> getPlaces() async => _places;
}

Finder _findPlaceTitle(String title) {
  return find.byWidgetPredicate(
    (widget) => widget is RichText && widget.text.toPlainText().contains(title),
    description: 'RichText title containing "$title"',
  );
}

void main() {
  testWidgets('filtra locais por texto de busca', (tester) async {
    final repository = _FixtureDiscoveryRepository();
    expect(await repository.getPlaces(), hasLength(3));
    await tester.pumpWidget(
      MaterialApp(
        home: DiscoveryScreen(repository: repository),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PlaceActivityCard), findsNWidgets(3));

    await tester.enterText(
      find.byKey(const ValueKey('search_text_field')),
      'academia',
    );
    await tester.pump();

    expect(_findPlaceTitle('Academia para Idosos'), findsOneWidget);
    expect(_findPlaceTitle('Jardim das Flores'), findsNothing);
  });

  testWidgets('filtra locais por categoria', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DiscoveryScreen(repository: _FixtureDiscoveryRepository()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Filtrar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lazer').last);
    await tester.pumpAndSettle();

    expect(_findPlaceTitle('Academia para Idosos'), findsOneWidget);
    expect(_findPlaceTitle('Jardim das Flores'), findsNothing);
    expect(
      _findPlaceTitle('La Boca Empanadas - Americana'),
      findsNothing,
    );
  });

  testWidgets('filtra locais por cidade', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DiscoveryScreen(repository: _FixtureDiscoveryRepository()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Filtrar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Campinas').last);
    await tester.pumpAndSettle();

    expect(_findPlaceTitle('Jardim das Flores'), findsOneWidget);
    expect(_findPlaceTitle('Academia para Idosos'), findsNothing);
    expect(
      _findPlaceTitle('La Boca Empanadas - Americana'),
      findsNothing,
    );
  });
}
