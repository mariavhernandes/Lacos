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

  // Controller para adicionar interesse personalizado
  late TextEditingController _customInterestController;

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();
    _customInterestController = TextEditingController();
    _loadInterests();
  }

  @override
  void dispose() {
    _customInterestController.dispose();
    super.dispose();
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
  // TOGGLE INTERESSE PRÉ-DEFINIDO
  // ===============================================================

  void _togglePredefinedInterest(String interest) {
    setState(() {
      if (_allInterests.contains(interest)) {
        _allInterests.remove(interest);
      } else {
        _allInterests.add(interest);
      }
    });
  }

  // ===============================================================
  // ADICIONAR INTERESSE PERSONALIZADO
  // ===============================================================

  void _addCustomInterest() {
    final interestText = _customInterestController.text.trim();

    if (interestText.isEmpty) {
      _showError('Digite um interesse antes de adicionar.');
      return;
    }

    if (_allInterests.contains(interestText)) {
      _showError('Este interesse já foi adicionado.');
      return;
    }

    setState(() {
      _allInterests.add(interestText);
      _customInterestController.clear();
    });
  }

  // ===============================================================
  // REMOVER INTERESSE
  // ===============================================================

  void _removeInterest(String interest) {
    setState(() {
      _allInterests.remove(interest);
    });
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
    // Todos os interesses predefinidos, ordenados
    final sortedPredefined = _predefinedInterests.toList()..sort();

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
          // CARDS DOS INTERESSES
          // =============================================================

          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedPredefined.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final interest = sortedPredefined[index];
                final isSelected = _allInterests.contains(interest);
                final imagePath = _interestIcons[interest];

                return GestureDetector(
                  onTap: () => _togglePredefinedInterest(interest),
                  child: _buildInterestCardWithIcon(
                    interest,
                    imagePath,
                    isSelected: isSelected,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // CARD DO INTERESSE
  // IGUAL AO CARD DA TELA DE PERFIL
  // ===============================================================

  Widget _buildInterestCardWithIcon(
    String title,
    String? imagePath, {
    bool isSelected = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFDCEAF5) : const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF0D3B66) : const Color(0xFF0D3B66),
          width: isSelected ? 2.5 : 1.8,
        ),
      ),
      child: Stack(
        children: [
          Column(
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
          // Checkmark quando selecionado
          if (isSelected)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0D3B66),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(2),
                child: const Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                ),
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
          // CAMPO DE ENTRADA
          // =============================================================

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customInterestController,
                    decoration: InputDecoration(
                      hintText: 'Digite um novo interesse...',
                      hintStyle: const TextStyle(
                        fontFamily: 'Raleway',
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFFCCCCCC),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    onSubmitted: (_) => _addCustomInterest(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _addCustomInterest,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF033B63),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // =============================================================
          // INTERESSES ADICIONADOS COM OPÇÃO DE REMOVER
          // =============================================================

          Padding(
            padding: const EdgeInsets.all(16),
            child: _addedInterests.isEmpty
                ? const Text(
                    'Nenhum interesse adicionado ainda. Digite um interesse acima para adicionar.',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
                  )
                : Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _addedInterests.map((interest) {
                      return GestureDetector(
                        onTap: () => _removeInterest(interest),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF0D3B66),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                interest,
                                style: const TextStyle(
                                  fontFamily: 'Raleway',
                                  color: Color(0xFF0D3B66),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.close,
                                size: 16,
                                color: Color(0xFFD32F2F),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}