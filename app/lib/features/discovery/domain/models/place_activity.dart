class PlaceActivity {
  const PlaceActivity({
    required this.name,
    required this.category,
    required this.description,
    required this.location,
    required this.distanceKm,
    this.imageAsset,
    this.rating = 4.5,
    this.reviewCount = 0,
    this.operatingHours = 'Ter-Dom: 18h30 às 23h',
    this.address = 'Endereço não informado',
  });

  final String name;
  final String category;
  final String description;
  final String location;
  final int distanceKm;
  final String? imageAsset;
  final double rating;
  final int reviewCount;
  final String operatingHours;
  final String address;
}
