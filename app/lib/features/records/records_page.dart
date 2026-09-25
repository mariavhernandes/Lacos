import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/widgets/custom_footer.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  // Endereço do computador onde o Docker/PHP está rodando.
  // É o mesmo endereço utilizado pelo ESP32.
  static const String _baseUrl = 'http://192.168.15.154:3000';

  List<Map<String, dynamic>> _photos = [];

  bool _isLoading = true;
  String? _errorMessage;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    _loadPhotos();

    // Verifica se chegaram novas fotos a cada 5 segundos.
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadPhotos(showLoading: false),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPhotos({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/photos'),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Erro HTTP: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body);

      if (data['success'] != true) {
        throw Exception(
          'Não foi possível carregar as fotos.',
        );
      }

      final List<dynamic> photos = data['photos'] ?? [];

      if (!mounted) return;

      setState(() {
        _photos = photos
            .map(
              (photo) => Map<String, dynamic>.from(photo),
            )
            .toList();

        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Não foi possível carregar os registros.';
      });
    }
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return 'Data não disponível';
    }

    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();

      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year.toString();

      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');

      return '$day/$month/$year às $hour:$minute';
    } catch (_) {
      return 'Data não disponível';
    }
  }

  /// Modal que explica o funcionamento do IoT.
  void _showInfoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE3F0FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Color(0xFF033B63),
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text(
                      'Registros e Monitoramento IoT',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF033B63),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Esta tela foi feita para você acompanhar a segurança do idoso através das capturas inteligentes do dispositivo IoT:',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 13,
                          height: 1.4,
                          color: Color(0xFF555555),
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildBulletPoint(
                        'As imagens registradas pela câmera inteligente são sincronizadas automaticamente em tempo real.',
                      ),

                      const SizedBox(height: 10),

                      _buildBulletPoint(
                        'Permite acompanhar momentos dos encontros e garantir maior tranquilidade e proteção.',
                      ),

                      const SizedBox(height: 10),

                      _buildBulletPoint(
                        'Todas as fotos capturadas durante os passeios ficam salvas no histórico.',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF033B63),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Entendi',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: const CustomFooter(
        currentIndex: 1,
        isFamily: true,
      ),

      body: SafeArea(
        child: Column(
          children: [
            // =====================================================
            // CABEÇALHO
            // =====================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Row(
                children: [
                  const SizedBox(width: 40),

                  const Expanded(
                    child: Text(
                      'Registros do IoT',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () => _showInfoModal(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE3F0FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: Color(0xFF033B63),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =====================================================
            // CONTEÚDO
            // =====================================================

            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF033B63),
                onRefresh: () => _loadPhotos(),
                child: SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    30,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Últimas Capturas',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF033B63),
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildContent(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    // ===========================================================
    // CARREGANDO
    // ===========================================================

    if (_isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 60,
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF033B63),
          ),
        ),
      );
    }

    // ===========================================================
    // ERRO
    // ===========================================================

    if (_errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 48,
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 42,
              color: Color(0xFF777777),
            ),

            const SizedBox(height: 16),

            const Text(
              'Não foi possível carregar os registros',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Verifique se o servidor do Laços está conectado e tente novamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 13,
                height: 1.35,
                color: Color(0xFF666666),
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton(
              onPressed: () => _loadPhotos(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF033B63),
                elevation: 0,
              ),
              child: const Text(
                'Tentar novamente',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ===========================================================
    // NENHUMA FOTO
    // ===========================================================

    if (_photos.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 48,
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFD9EEFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                size: 36,
                color: Color(0xFF033B63),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Nenhum registro no momento',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Assim que o dispositivo capturar novas imagens, elas aparecerão aqui automaticamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 13,
                height: 1.35,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      );
    }

    // ===========================================================
    // FOTOS
    // ===========================================================

    return Column(
      children: _photos.map((photo) {
        return _buildPhotoCard(photo);
      }).toList(),
    );
  }

  Widget _buildPhotoCard(
    Map<String, dynamic> photo,
  ) {
    final fileName =
        photo['fileName']?.toString() ?? '';

    final capturedAt =
        photo['capturedAt']?.toString();

    final imageUrl =
        '$_baseUrl/uploads/$fileName';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // =====================================================
          // FOTO
          // =====================================================

          AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,

              loadingBuilder: (
                context,
                child,
                loadingProgress,
              ) {
                if (loadingProgress == null) {
                  return child;
                }

                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF033B63),
                  ),
                );
              },

              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Container(
                  color: const Color(0xFFF5F5F5),
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 42,
                      color: Color(0xFF888888),
                    ),
                  ),
                );
              },
            ),
          ),

          // =====================================================
          // DATA E HORA
          // =====================================================

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE3F0FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 18,
                    color: Color(0xFF033B63),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Captura do dispositivo',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        _formatDateTime(capturedAt),
                        style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 12,
                          color: Color(0xFF777777),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Item de lista com marcador.
  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF033B63),
          ),
        ),

        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Raleway',
              fontSize: 13,
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