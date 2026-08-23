import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditAboutMePage extends StatefulWidget {
  final String uid;
  final String initialBio;

  const EditAboutMePage({
    super.key,
    required this.uid,
    required this.initialBio,
  });

  @override
  State<EditAboutMePage> createState() => _EditAboutMePageState();
}

class _EditAboutMePageState extends State<EditAboutMePage> {
  late TextEditingController _bioController;

  final int _maxLength = 150;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _bioController = TextEditingController(
      text: widget.initialBio,
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  // ===============================================================
  // SALVAR BIO
  // ===============================================================

  Future<void> _saveBio() async {
    if (_isLoading) return;

    final bio = _bioController.text.trim();

    if (bio.length > _maxLength) {
      _showError(
        'O texto deve ter no máximo 150 caracteres.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    FocusScope.of(context).unfocus();

    try {
      await FirebaseFirestore.instance
          .collection('idosos')
          .doc(widget.uid)
          .update({
        'bio': bio,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sobre você atualizado com sucesso!',
            style: TextStyle(
              fontFamily: 'Raleway',
            ),
          ),
          backgroundColor: Color(0xFF033B63),
        ),
      );

      Navigator.pop(context, true);
    } on FirebaseException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'permission-denied':
          message =
              'Você não tem permissão para alterar essas informações.';
          break;

        case 'not-found':
          message =
              'Não foi possível encontrar os dados do usuário.';
          break;

        case 'unavailable':
          message =
              'Serviço indisponível. Verifique sua conexão e tente novamente.';
          break;

        default:
          message =
              'Erro ao atualizar suas informações. Tente novamente.';
      }

      _showError(message);
    } catch (e) {
      if (!mounted) return;

      _showError(
        'Erro ao atualizar suas informações. Tente novamente.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ===============================================================
  // MENSAGEM DE ERRO
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
            // =========================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),

              child: Row(
                children: [

                  // -------------------------------------------------
                  // SETA
                  // -------------------------------------------------

                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, false);
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

                  // -------------------------------------------------
                  // TÍTULO
                  // -------------------------------------------------

                  const Expanded(
                    child: Text(
                      'Sobre Você',

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ),

                  // Mantém o título centralizado
                  const SizedBox(
                    width: 40,
                  ),
                ],
              ),
            ),

            // =========================================================
            // CONTEÚDO
            // =========================================================

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  38,
                  36,
                  38,
                  30,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    // =================================================
                    // TÍTULO
                    // =================================================

                    const Text(
                      'Escreva sobre você:',

                      style: TextStyle(
                        fontFamily: 'Raleway',

                        // Fonte menor
                        fontSize: 16,

                        fontWeight: FontWeight.bold,

                        color: Color(0xFF033B63),
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    // =================================================
                    // CAMPO PARA ESCREVER
                    // =================================================

                    Container(
                      width: double.infinity,
                      height: 230,

                      decoration: BoxDecoration(
                        // Fundo externo
                        color: const Color(0xFFF6F6F6),

                        borderRadius: BorderRadius.circular(16),

                        // Borda externa
                        border: Border.all(
                          color: const Color(0xFF888888),
                          width: 1,
                        ),
                      ),

                      child: Stack(
                        children: [

                          // =========================================
                          // TEXTFIELD
                          // =========================================

                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                12,
                                16,
                                35,
                              ),

                              child: TextField(
                                controller: _bioController,

                                // Limite de caracteres
                                maxLength: _maxLength,

                                // Permite várias linhas
                                maxLines: 7,

                                // Texto alinhado à esquerda
                                textAlign: TextAlign.left,

                                // Texto começa no topo
                                textAlignVertical:
                                    TextAlignVertical.top,

                                // Atualiza o contador enquanto digita
                                onChanged: (text) {
                                  setState(() {});
                                },

                                style: const TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 16,
                                  color: Color(0xFF666666),
                                ),

                                decoration: const InputDecoration(

                                  // =================================================
                                  // IMPORTANTE:
                                  // o próprio TextField agora possui a mesma
                                  // cor do container externo.
                                  // Isso elimina o quadrado branco.
                                  // =================================================

                                  filled: true,

                                  fillColor: Color(0xFFF6F6F6),

                                  hintText:
                                      'Fale um pouco sobre você...',

                                  hintStyle: TextStyle(
                                    fontFamily: 'Raleway',
                                    fontSize: 16,
                                    color: Color(0xFF828282),
                                  ),

                                  // Remove TODAS as bordas
                                  border: InputBorder.none,

                                  enabledBorder:
                                      InputBorder.none,

                                  focusedBorder:
                                      InputBorder.none,

                                  disabledBorder:
                                      InputBorder.none,

                                  errorBorder:
                                      InputBorder.none,

                                  focusedErrorBorder:
                                      InputBorder.none,

                                  // Remove contador padrão
                                  counterText: '',

                                  // Texto começa exatamente no
                                  // canto superior esquerdo
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ),

                          // =================================================
                          // CONTADOR
                          // =================================================

                          Positioned(
                            right: 12,
                            bottom: 10,

                            child: IgnorePointer(
                              child: Text(
                                '${_bioController.text.length}/$_maxLength',

                                style: const TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 12,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // =================================================
                    // AVISO
                    // =================================================

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,

                      children: [

                        const Icon(
                          Icons.error,
                          size: 18,
                          color: Color(0xFF292929),
                        ),

                        const SizedBox(
                          width: 6,
                        ),

                        Expanded(
                          child: Text(
                            'Tudo o que escrever ficará visível para todos.',

                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 12,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // =================================================
                    // ESPAÇO
                    // =================================================

                    const SizedBox(
                      height: 30,
                    ),

                    // =================================================
                    // BOTÃO ALTERAR
                    // =================================================

                    Center(
                      child: SizedBox(
                        width: 160,
                        height: 56,

                        child: ElevatedButton(
                          onPressed:
                              _isLoading ? null : _saveBio,

                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF033B63),

                            disabledBackgroundColor:
                                const Color(0xFF033B63),

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),

                            elevation: 0,
                          ),

                          child: _isLoading
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
                                  'Alterar',

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
}