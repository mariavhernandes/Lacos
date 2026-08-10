import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/features/discovery/domain/models/place_activity.dart';

void main() {
  group('DetailScreen Model', () {
    test('PlaceActivity model initializes with correct values', () {
      const place = PlaceActivity(
        name: 'La Boca Empanadas - Americana',
        category: 'Lazer',
        description:
            'O La Boca Empanadas oferece empanadas argentinas artesanais em um ambiente acolhedor.',
        location: '10 km de distância',
        distanceKm: 10,
        rating: 4.97,
        reviewCount: 100,
        operatingHours: 'Ter-Dom: 18h30 às 23h',
        address: 'Rua Hermann Müller Carioba, 165',
      );

      expect(place.name, 'La Boca Empanadas - Americana');
      expect(place.category, 'Lazer');
      expect(place.rating, 4.97);
      expect(place.reviewCount, 100);
      expect(place.operatingHours, 'Ter-Dom: 18h30 às 23h');
      expect(place.address, 'Rua Hermann Müller Carioba, 165');
      expect(place.distanceKm, 10);
    });

    test('PlaceActivity with default values', () {
      const place = PlaceActivity(
        name: 'Test Place',
        category: 'Lazer',
        description: 'Test Description',
        location: '5 km',
        distanceKm: 5,
      );

      expect(place.rating, 4.5);
      expect(place.reviewCount, 0);
      expect(place.operatingHours, 'Ter-Dom: 18h30 às 23h');
      expect(place.address, 'Endereço não informado');
    });
  });
}
