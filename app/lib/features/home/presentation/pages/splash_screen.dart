import 'dart:math';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late String _fraseSorteada;

  final List<String> _frasesAcolhedoras = [
    "Crie novos laços. Compartilhe alegria.",
    "Cada conversa é uma nova oportunidade de sorrir.",
    "Conecte-se com quem faz o seu dia mais feliz.",
    "Histórias incríveis esperam por você hoje.",
    "O carinho e a amizade estão a um toque de distância.",
    "Cultive momentos especiais todos os dias.",
  ];

  @override
  void initState() {
    super.initState();
    _sortearFrase();
  }

  void _sortearFrase() {
    final random = Random();
    setState(() {
      _fraseSorteada = _frasesAcolhedoras[random.nextInt(_frasesAcolhedoras.length)];
    });
  }

  void _navegarParaHome() {
    Navigator.pushReplacementNamed(context, '/elderly-home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 24.0, top: 12.0, bottom: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/logos/logo_with_name.png',
                  height: 50,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(height: 50),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Image.asset(
                'assets/images/elderly/welcome_image.png',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF033B63),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36.0),
                    topRight: Radius.circular(36.0),
                  ),
                ),
                padding: const EdgeInsets.only(left: 28.0, right: 28.0, top: 28.0, bottom: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Redescubra o prazer\nde estar junto',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      _fraseSorteada,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Raleway',
                        color: Color(0xFFFFFFFF),
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _navegarParaHome,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F5A84),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Começar',
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Image.asset(
                              'assets/images/elderly/start_arrow.png',
                              height: 28,
                              width: 28,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}