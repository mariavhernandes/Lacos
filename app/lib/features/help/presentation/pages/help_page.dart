import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_footer.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  bool _isAboutExpanded = false;
  bool _isAccessibilityExpanded = false;
  bool _isFeaturesExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Topo Customizado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      'assets/icons/navigation/back_icon.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
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
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Ajuda',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Lista de Opções Sanfona
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    // 1. Sobre o aplicativo
                    _buildHelpCard(
                      title: 'Sobre o aplicativo',
                      isExpanded: _isAboutExpanded,
                      onToggle: () {
                        setState(() {
                          _isAboutExpanded = !_isAboutExpanded;
                        });
                      },
                      iconWidget: const Icon(
                        Icons.info,
                        color: Color(0xFF033B63),
                        size: 26,
                      ),
                      expandedContent: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'O Laços é um aplicativo desenvolvido especialmente para o público da terceira idade.',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 14,
                              height: 1.4,
                              color: Color(0xFF444444),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Seu propósito é de promover conexões sociais e combater o isolamento, contribuindo para o bem-estar emocional dos usuários.',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 14,
                              height: 1.4,
                              color: Color(0xFF444444),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 2. Acessibilidade
                    _buildHelpCard(
                      title: 'Acessibilidade',
                      isExpanded: _isAccessibilityExpanded,
                      onToggle: () {
                        setState(() {
                          _isAccessibilityExpanded = !_isAccessibilityExpanded;
                        });
                      },
                      iconWidget: const Text(
                        'Aa',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF033B63),
                        ),
                      ),
                      expandedContent: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Este aplicativo foi desenvolvido seguindo padrões de design acessível, com cores de alto contraste, botões amplos e textos claros para garantir conforto e praticidade na sua navegação.',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 14,
                              height: 1.4,
                              color: Color(0xFF444444),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // ElevatedButton(
                          //   onPressed: () {
                          //     // Ação de alterar tamanho
                          //   },
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: const Color(0xFF033B63),
                          //     elevation: 0,
                          //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(20),
                          //     ),
                          //   ),
                          //   child: const Text(
                          //     'Alterar tamanho',
                          //     style: TextStyle(
                          //       fontFamily: 'Raleway',
                          //       fontSize: 13,
                          //       fontWeight: FontWeight.bold,
                          //       color: Colors.white,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 3. Funcionalidades
                    _buildHelpCard(
                      title: 'Funcionalidades',
                      isExpanded: _isFeaturesExpanded,
                      onToggle: () {
                        setState(() {
                          _isFeaturesExpanded = !_isFeaturesExpanded;
                        });
                      },
                      iconWidget: const Icon(
                        Icons.format_list_bulleted,
                        color: Color(0xFF033B63),
                        size: 24,
                      ),
                      expandedContent: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'No aplicativo Laços você pode:',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 14,
                              color: Color(0xFF444444),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildBulletPoint('Seguir pessoas que tenham os mesmos interesses que você.'),
                          const SizedBox(height: 10),
                          _buildBulletPoint('Combinar encontros para praticarem seus hobbies juntos.'),
                          const SizedBox(height: 10),
                          _buildBulletPoint('Receber sugestões de lugares para o encontro, escolhidos conforme a cidade de vocês.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomFooter(currentIndex: 0),
    );
  }

  /// Card expansível genérico com tamanho de fonte ajustado
  Widget _buildHelpCard({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget iconWidget,
    required Widget expandedContent,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 32,
                child: Center(child: iconWidget),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 15, // Fonte diminuída para alinhar ao protótipo
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4C7296),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 4),
              child: expandedContent,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF444444),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Raleway',
              fontSize: 14,
              height: 1.35,
              color: Color(0xFF444444),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}