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
          // Borda de 0.5px com opacidade de 20%
          border: Border.all(
            color: Colors.black.withOpacity(0.2),
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
            // Área reservada para a imagem do local
            Container(
              height: 185,
              width: double.infinity,
              color: const Color(0xFFE8F0F7),
              alignment: Alignment.center,
              child: Text(
                'Imagem do local',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF466A99),
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome do local: Cor preta, Quicksand 18
                  Text(
                    place.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Descrição: Cor preta, Raleway 16
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

                  // Localização / Distância: Raleway 12
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/elderly/location.png',
                        width: 13,
                        height: 13,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          place.location,
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