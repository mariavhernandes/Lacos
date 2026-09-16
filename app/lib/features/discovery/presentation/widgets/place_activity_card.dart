import 'package:flutter/material.dart';

import '../../domain/models/place_activity.dart';
import '../../presentation/screens/detail_screen.dart';

class PlaceActivityCard extends StatelessWidget {
  const PlaceActivityCard({
    required this.place,
    super.key,
  });

  final PlaceActivity place;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(place: place),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.2),
            width: 0.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 185,
              width: double.infinity,
              color: const Color(0xFFE8F0F7),
              child: place.imageAssets.isNotEmpty
                  ? Image.asset(
                      place.imageAssets.first,
                      width: double.infinity,
                      height: 185,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text(
                            'Imagem não encontrada',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 14,
                              color: Color(0xFF466A99),
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'Imagem do local',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 14,
                          color: Color(0xFF466A99),
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: place.name,
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        if (place.category.isNotEmpty)
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Icon(
                                _iconForCategory(place.category),
                                size: 18,
                                color: const Color(0xFF033B63),
                              ),
                            ),
                          ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    place.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 14,
                      height: 1.3,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/elderly/location.png',
                        width: 13,
                        height: 13,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.location_on,
                          size: 13,
                          color: Color(0xFF466A99),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${place.city} - ${place.address}',
                          style: const TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Mapeia o nome da categoria (salvo no Firestore) pro ícone correspondente.
//
// Se aparecer uma categoria nova que não está no mapa, cai no ícone padrão.
IconData _iconForCategory(String category) {
  switch (category) {
    case 'Cafeterias':
      return Icons.local_cafe;
    case 'Restaurantes':
      return Icons.restaurant; // ícone de garfo e faca
    case 'Lazer':
      return Icons.park; // veja outras opções no comentário abaixo
    default:
      return Icons.place;
  }
}
