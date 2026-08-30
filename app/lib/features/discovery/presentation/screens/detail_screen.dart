import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_footer.dart';
import '../../domain/models/place_activity.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    required this.place,
    super.key,
  });

  final PlaceActivity place;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late PageController _imageController;
  int _currentImageIndex = 0;
  final int _totalImages = 3;

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ==================================================
                  // FOTOS
                  // ==================================================
                  Stack(
                    children: [
                      SizedBox(
                        height: 350,
                        width: double.infinity,
                        child: PageView(
                          controller: _imageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          children: [
                            _buildImagePlaceholder(
                              color: const Color.fromARGB(
                                255,
                                217,
                                128,
                                183,
                              ),
                              text: 'Foto 1',
                            ),
                            _buildImagePlaceholder(
                              color: const Color.fromARGB(
                                255,
                                144,
                                30,
                                205,
                              ),
                              text: 'Foto 2',
                            ),
                            _buildImagePlaceholder(
                              color: const Color.fromARGB(
                                255,
                                174,
                                133,
                                221,
                              ),
                              text: 'Foto 3',
                            ),
                          ],
                        ),
                      ),

                      // ==================================================
                      // BOTÃO VOLTAR
                      // ==================================================
                      Positioned(
                        top: 16,
                        left: 20,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Image.asset(
                            'assets/icons/navigation/back_icon.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDCEAF5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 18,
                                  color: Color(0xFF033B63),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // ==================================================
                      // CONTADOR DE FOTOS
                      // ==================================================
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_currentImageIndex + 1}/$_totalImages',
                            style: const TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // CARD DE AVALIAÇÃO
                  // ==================================================
                  Container(
                    width: 335,
                    height: 74,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFDCDCDC),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Text(
                                '${widget.place.rating}',
                                style: const TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Image.asset(
                                'assets/images/elderly/five_stars_rating.png',
                                width: 62,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 42,
                          color: const Color(0xFFE5E5E5),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Melhor',
                                style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Avaliado',
                                style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 42,
                          color: const Color(0xFFE5E5E5),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Text(
                                '${widget.place.reviewCount}',
                                style: const TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Comentários',
                                style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // CARD DE INFORMAÇÕES
                  // ==================================================
                  Container(
                    width: 335,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFDCDCDC),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // NOME
                          Text(
                            widget.place.name,
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // DESCRIÇÃO
                          Text(
                            widget.place.description,
                            style: const TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 16,
                              height: 1.45,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 22),

                          // HORÁRIO
                          const Text(
                            'Horário de Funcionamento:',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Image.asset(
                                'assets/images/elderly/opening_hours.png',
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  widget.place.operatingHours,
                                  style: const TextStyle(
                                    fontFamily: 'Raleway',
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ENDEREÇO
                          const Text(
                            'Endereço:',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/elderly/location.png',
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  widget.place.address,
                                  style: const TextStyle(
                                    fontFamily: 'Raleway',
                                    fontSize: 16,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ==================================================
                  // BOTÃO VER NO MAPA
                  // ==================================================
                  SizedBox(
                    width: 170,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implementar navegação para o mapa.
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF003C6A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Ver no Mapa',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ==========================================================
          // RODAPÉ PADRÃO
          // ==========================================================
          const CustomFooter(
            currentIndex: 1,
          ),
        ],
      ),
    );
  }

  // ================================================================
  // PLACEHOLDER DAS IMAGENS
  // ================================================================
  Widget _buildImagePlaceholder({
    required Color color,
    required String text,
  }) {
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Raleway',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}