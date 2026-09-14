class PlaceActivity {
  const PlaceActivity({
    required this.name,
    required this.category,
    required this.description,
    required this.city,
    required this.address,
    required this.operatingHours,
    required this.rating,
    required this.mapsLink,
    this.reviewCount = 0,
    this.imageAssetsOverride,
  });

  final String name;
  final String category;
  final String description;
  final String city;
  final String address;
  final String operatingHours;
  final double rating;
  final String mapsLink;
  final int reviewCount;

  // Parâmetro opcional caso queira passar manualmente em algum caso específico
  final List<String>? imageAssetsOverride;

  // Getter para compatibilidade com telas que chamam reviewsCount
  int get reviewsCount => reviewCount;

  // Propriedade inteligente que gera a lista de imagens automaticamente
  List<String> get imageAssets {
    if (imageAssetsOverride != null && imageAssetsOverride!.isNotEmpty) {
      return imageAssetsOverride!;
    }

    return [
      'assets/images/places/$city/${name}1.jpg',
      'assets/images/places/$city/${name}2.jpg',
      'assets/images/places/$city/${name}3.jpg',
      'assets/images/places/$city/${name}4.jpg',
    ];
  }
}