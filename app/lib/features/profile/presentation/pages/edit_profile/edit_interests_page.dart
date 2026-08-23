import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditInterestsPage extends StatefulWidget {
  final String uid;
  final List<String> currentInterests;

  const EditInterestsPage({
    super.key,
    required this.uid,
    required this.currentInterests,
  });

  @override
  State<EditInterestsPage> createState() => _EditInterestsPageState();
}

class _EditInterestsPageState extends State<EditInterestsPage> {
  // ===============================================================
  // INTERESSES PRÉ-DEFINIDOS
  // IMPORTANTE:
  // ESTES NOMES DEVEM SER IGUAIS AOS UTILIZADOS NO PERFIL E NO BANCO
  // ===============================================================

  final Set<String> _predefinedInterests = {
    'Jogos de tabuleiro',
    'Jogos de carta',
    'Xadrez',
    'Dança',
    'Jardinagem',
    'Tricô/Crochê',
    'Artesanato',
    'Caminhada',
    'Dominó',
  };

  // ===============================================================
  // ÍCONES DOS INTERESSES
  // MESMOS ÍCONES UTILIZADOS NA TELA DE PERFIL
  // ===============================================================

  final Map<String, String> _interestIcons = {
    'Jogos de tabuleiro':
        'assets/images/commun/chess.png',

    'Jogos de carta':
        'assets/images/commun/card_games.png',

    'Xadrez':
        'assets/images/commun/chess.png',

    'Dança':
        'assets/images/commun/dancing.png',

    'Jardinagem':
        'assets/images/commun/gardening.png',

    'Tricô/Crochê':
        'assets/images/commun/knitting.png',

    'Artesanato':
        'assets/images/commun/sewing.png',

    'Caminhada':
        'assets/images/commun/walking.png',

    'Dominó':
        'assets/images/commun/domino.png',
  };

  // Todos os interesses vindos do Firestore
  List<String> _allInterests = [];

  bool _isLoading = true;
  bool _isSaving = false;

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();
    _loadInterests();
  }

  // ===============================================================
  // CARREGAR INTERESSES DO FIRESTORE
  // ===============================================================

  Future<void> _loadInterests() async {
    try {
      final document = await FirebaseFirestore.instance
          .collection('idosos')
          .doc(widget.uid)
          .get();

      if (!document.exists) {
        if (!mounted) return;

        setState(() {
          _allInterests = [];
          _isLoading = false;
        });

        return;
      }

      final data = document.data();

      final interestsData = data?['interests'];

      List<String> interests = [];

      if (interestsData is List) {
        interests = interestsData
            .map((interest) => interest.toString().trim())
            .where((interest) => interest.isNotEmpty)
            .toList();
      }

      if (!mounted) return;

      setState(() {
        _allInterests = interests;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showError(
        'Não foi possível carregar seus interesses.',
      );
    }
  }

  // ===============================================================
  // INTERESSES PRÉ-DEFINIDOS SELECIONADOS
  // ===============================================================

  List<String> get _selectedPredefinedInterests {
    return _allInterests
        .where(
          (interest) => _predefinedInterests.contains(interest),
        )
        .toList();
  }

  // ===============================================================
  // INTERESSES ADICIONADOS MANUALMENTE
  // ===============================================================

  List<String> get _addedInterests {
    return _allInterests
        .where(
          (interest) => !_predefinedInterests.contains(interest),
        )
        .toList();
  }

  // ===============================================================
  // SALVAR
  // ===============================================================

  Future<void> _saveInterests() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('idosos')
          .doc(widget.uid)
          .update({
        'interests': _allInterests,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Interesses atualizados com sucesso!',
            style: TextStyle(
              fontFamily: 'Raleway',
            ),
          ),
          backgroundColor: Color(0xFF033B63),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      _showError(
        'Erro ao atualizar seus interesses. Tente novamente.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ===============================================================
  // ERRO
  // ===============================================================

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Raleway',
          ),
        ),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            // =========================================================
            // CABEÇALHO
            // MESMO PADRÃO DA TELA DE EDITAR PERFIL
            // =========================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, false),
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
                      'Interesses',
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

            // =========================================================
            // CONTEÚDO
            // =========================================================

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF033B63),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        10,
                        20,
                        30,
                      ),
                      child: Column(
                        children: [
                          // =================================================
                          // INTERESSES ESCOLHIDOS
                          // =================================================

                          _buildSelectedInterestsSection(),

                          const SizedBox(height: 20),

                          // =================================================
                          // INTERESSES ADICIONADOS
                          // =================================================

                          _buildAddedInterestsSection(),

                          const SizedBox(height: 30),

                          // =================================================
                          // BOTÃO
                          // =================================================

                          Center(
                            child: SizedBox(
                              width: 160,
                              height: 56,
                              child: ElevatedButton(
                                onPressed:
                                    _isSaving ? null : _saveInterests,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF033B63),
                                  disabledBackgroundColor:
                                      const Color(0xFF033B63),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Editar',
                                        style: TextStyle(
                                          fontFamily: 'Raleway',
                                          fontSize: 18,
                                          fontWeight:
                                              FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
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

  // ===============================================================
  // CARD — INTERESSES ESCOLHIDOS
  // ===============================================================

  Widget _buildSelectedInterestsSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =============================================================
          // CABEÇALHO DO CARD
          // =============================================================

          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 12,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF033B63),
                ),

                const SizedBox(width: 8),

                const Text(
                  'Interesses Escolhidos',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF033B63),
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            thickness: 0.8,
            color: Color(0xFF8B8B8B),
          ),

          // =============================================================
          // CARDS DOS INTERESSES E BOTÃO ADICIONAR
          // =============================================================

          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _selectedPredefinedInterests.length + 1,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                if (index == _selectedPredefinedInterests.length) {
                  return _buildAddButtonCard(onTap: () {});
                }

                final interest = _selectedPredefinedInterests[index];
                final imagePath = _interestIcons[interest];

                return _buildInterestCardWithIcon(
                  interest,
                  imagePath,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // BOTÃO DE ADICIONAR EM FORMATO DE CARD (GRID)
  // ===============================================================

  Widget _buildAddButtonCard({VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: const Center(
        child: Icon(
          Icons.add_circle,
          size: 52,
          color: Color(0xFF033B63),
        ),
      ),
    );
  }

  // ===============================================================
  // CARD DO INTERESSE
  // IGUAL AO CARD DA TELA DE PERFIL
  // ===============================================================

  Widget _buildInterestCardWithIcon(
    String title,
    String? imagePath,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0D3B66),
          width: 1.8,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ===========================================================
          // ÍCONE
          // ===========================================================

          if (imagePath != null)
            Image.asset(
              imagePath,
              height: 36,
              width: 36,
              fit: BoxFit.contain,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons.extension,
                  size: 32,
                  color: Color(0xFF0D3B66),
                );
              },
            )
          else
            const Icon(
              Icons.star,
              size: 32,
              color: Color(0xFF0D3B66),
            ),

          const SizedBox(height: 4),

          // ===========================================================
          // NOME
          // ===========================================================

          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Raleway',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              height: 1.1,
              color: Color(0xFF0D3B66),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // INTERESSES ADICIONADOS MANUALMENTE
  // ===============================================================

  Widget _buildAddedInterestsSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =============================================================
          // CABEÇALHO
          // =============================================================

          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 12,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.add_circle,
                  color: Color(0xFF033B63),
                ),

                const SizedBox(width: 8),

                const Text(
                  'Interesses Adicionados',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF033B63),
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            thickness: 0.8,
            color: Color(0xFF8B8B8B),
          ),

          // =============================================================
          // INTERESSES E BOTÃO ADICIONAR LADO A LADO
          // =============================================================

          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ..._addedInterests.map((interest) {
                  return _buildAddedInterestChip(
                    interest,
                  );
                }),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.add_circle,
                    size: 42,
                    color: Color(0xFF033B63),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // CHIP DOS INTERESSES ADICIONADOS
  // ===============================================================

  Widget _buildAddedInterestChip(String interest) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF0D3B66),
          width: 1.5,
        ),
      ),
      child: Text(
        interest,
        style: const TextStyle(
          fontFamily: 'Raleway',
          color: Color(0xFF0D3B66),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}