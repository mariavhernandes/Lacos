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
  
  // Parâmetro opcional caso queira passar manualmente em algum caso específico, 
  // mas por padrão será gerado de forma automática!
  final List<String>? imageAssetsOverride;

  // Propriedade inteligente que gera a lista de imagens automaticamente
  // Exemplo gerado: 'assets/images/places/Americana/Café Roma1.jpg'
  List<String> get imageAssets {
    if (imageAssetsOverride != null && imageAssetsOverride!.isNotEmpty) {
      return imageAssetsOverride!;
    }
    
    // Gera uma lista com 4 imagens por padrão usando o nome do lugar e da cidade
    return [
      'assets/images/places/$city/${name}1.jpg',
      'assets/images/places/$city/${name}2.jpg',
      'assets/images/places/$city/${name}3.jpg',
      'assets/images/places/$city/${name}4.jpg',
    ];
  }
}