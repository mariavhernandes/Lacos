import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/place_activity.dart';

class DiscoveryRepository {
  const DiscoveryRepository();

  Future<List<PlaceActivity>> getPlaces() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('locais').get();

    final places = <PlaceActivity>[];

    for (final doc in snapshot.docs) {
      try {
        places.add(_placeFromDoc(doc));
      } catch (e) {
        // Não derruba a lista inteira: avisa qual documento tem
        // problema (id + dados brutos) e pula pro próximo.
        debugPrint('⚠️ Documento com erro (id: ${doc.id}): $e');
        debugPrint('   Dados do documento: ${doc.data()}');
      }
    }

    return places;
  }

  PlaceActivity _placeFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    final name = data['nome'] as String? ?? 'Sem nome';
    final city = data['cidade'] as String? ?? '';
    final category = data['categoria'] as String? ?? '';

    // ID único gerado pelo Firebase
    final docId = doc.id;

    // Gera automaticamente os 4 caminhos das imagens.
    // Exemplo:
    // G8UHXn3eDB7jN1ElaXng_1.jpg
    // G8UHXn3eDB7jN1ElaXng_2.jpg
    // G8UHXn3eDB7jN1ElaXng_3.jpg
    // G8UHXn3eDB7jN1ElaXng_4.jpg
    final generatedImages = List.generate(4, (index) {
      final imageNumber = index + 1;
      return 'assets/Lugares/$city/$category/${docId}_$imageNumber.jpg';
    });

    return PlaceActivity(
      name: name,
      category: category,
      description: data['descricao'] as String? ?? '',
      city: city,
      address: data['endereco'] as String? ?? '',
      operatingHours: data['horario'] as String? ?? '',
      rating: (data['avaliacao'] as num?)?.toDouble() ?? 0.0,
      mapsLink: data['linkMaps'] as String? ?? '',
      imageAssetsOverride: generatedImages,
    );
  }
}