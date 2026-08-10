import 'package:flutter/material.dart';

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
  final int _totalImages = 3; // Quantidade total de fotos

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
      backgroundColor: const Color(0xFFFFFFFF),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      // Área das Fotos
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
                              color: const Color.fromARGB(255, 217, 128, 183),
                              text: 'Foto 1',
                            ),
                            _buildImagePlaceholder(
                              color: const Color.fromARGB(255, 144, 30, 205),
                              text: 'Foto 2',
                            ),
                            _buildImagePlaceholder(
                              color: const Color.fromARGB(255, 174, 133, 221),
                              text: 'Foto 3',
                            ),
                          ],
                        ),
                      ),

                      // Ícone "Voltar"
                  Positioned(
                    top: 54, // Ajuste conforme necessário
                    left: 24, // Ajuste conforme necessário
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      // Exibe apenas a imagem pura. Como o PNG é transparente,
                      // o fundo azul das fotos aparecerá atrás dele.
                      child: Image.asset(
                        'assets/icons/navigation/back_icon.png',
                        width: 38, // Tamanho da imagem
                        height: 38,
                        fit: BoxFit
                            .contain, // Garante que a imagem não seja cortada
                      ),
                    ),
                  ),

                  // Contador de Imagem (ex: 1/3)
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

                  // Rating Card
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
                            mainAxisAlignment: MainAxisAlignment.center,
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
                            mainAxisAlignment: MainAxisAlignment.center,
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
                            mainAxisAlignment: MainAxisAlignment.center,
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

                  // Information Card
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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

                  // View on map button
                  SizedBox(
                    width: 170,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement map navigation
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

          // Footer Navigation
          Container(
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _FooterItem(
                    asset: 'assets/icons/icons_footer/footer_home_icon.png',
                    label: 'Início',
                    onTap: () => Navigator.pop(context),
                  ),
                  _FooterItem(
                    asset: 'assets/icons/icons_footer/footer_location_icon.png',
                    label: 'Lugares',
                    selected: true,
                  ),
                  _FooterItem(
                    asset: 'assets/icons/icons_footer/footer_chat_icon.png',
                    label: 'Conversas',
                  ),
                  _FooterItem(
                    asset: 'assets/icons/icons_footer/footer_profile_icon.png',
                    label: 'Perfil',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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

class _FooterItem extends StatelessWidget {
  const _FooterItem({
    required this.asset,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String asset;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 58,
              height: 42,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFDCEEFF)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Image.asset(
                  asset,
                  width: 26,
                  height: 26,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}