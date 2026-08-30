import '../../domain/models/place_activity.dart';

class DiscoveryRepository {
  const DiscoveryRepository();

  List<PlaceActivity> getPlaces() {
    return const [
      PlaceActivity(
        name: 'La Boca Empanadas - Americana',
        category: 'Lazer',
        description:
            'O La Boca Empanadas oferece empanadas argentinas artesanais em um ambiente acolhedor. Com sabores tradicionais e opções diferenciadas.',
        location: '10 km de distância',
        distanceKm: 10,
        rating: 4.97,
        reviewCount: 100,
        operatingHours: 'Ter-Dom: 18h30 às 23h',
        address: 'Rua Hermann Müller Carioba, 165',
      ),
      PlaceActivity(
        name: 'Academia para Idosos',
        category: 'Esporte',
        description:
            'Atividades físicas acompanhadas e adaptadas para pessoas idosas. Equipamentos modernos e instrutores especializados.',
        location: '4 km de distância',
        distanceKm: 4,
        rating: 4.5,
        reviewCount: 45,
        operatingHours: 'Seg-Sex: 08h às 18h',
        address: 'Av. Paulista, 1000',
      ),
      PlaceActivity(
        name: 'Jardim das Flores',
        category: 'Lazer',
        description:
            'Espaço tranquilo para caminhadas, encontros e atividades ao ar livre. Com bancos para descanso e áreas com sombra.',
        location: '7 km de distância',
        distanceKm: 7,
        rating: 4.8,
        reviewCount: 67,
        operatingHours: 'Todos os dias: 06h às 18h',
        address: 'Rua das Flores, 500',
      ),
    ];
  }
}
