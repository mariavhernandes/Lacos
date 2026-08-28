import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ===============================================================
// PÁGINA DE EDIÇÃO DOS DADOS BÁSICOS DO FAMILIAR
// ===============================================================

class EditFamilyBasicDataPage extends StatefulWidget {
  final String uid;
  final Map<String, dynamic> initialData;

  const EditFamilyBasicDataPage({
    super.key,
    required this.uid,
    required this.initialData,
  });

  @override
  State<EditFamilyBasicDataPage> createState() =>
      _EditFamilyBasicDataPageState();
}

class _EditFamilyBasicDataPageState extends State<EditFamilyBasicDataPage> {
  // =============================================================
  // CONTROLLERS E VARIÁVEIS
  // =============================================================

  late TextEditingController _nameController;

  String? _selectedRelationship;
  bool _isLoading = false;
  bool _isSendingResetEmail = false;

  // Lista de graus de parentesco conforme o cadastro
  final List<String> _relationshipOptions = [
    'Filho(a)',
    'Neto(a)',
    'Cuidador(a)',
    'Amigo(a)',
    'Outro',
  ];

  // =============================================================
  // INIT STATE
  // =============================================================

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.initialData['name']?.toString() ?? '',
    );

    final String? savedRelationship = widget.initialData['relationship']?.toString() ??
        widget.initialData['relationshipDegree']?.toString();

    if (savedRelationship != null &&
        _relationshipOptions.contains(savedRelationship)) {
      _selectedRelationship = savedRelationship;
    } else {
      _selectedRelationship = null;
    }
  }

  // =============================================================
  // DISPOSE
  // =============================================================

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // =============================================================
  // ENVIAR E-MAIL DE REDEFINIÇÃO DE SENHA
  // =============================================================

  Future<void> _sendPasswordResetEmail(String email) async {
    if (email.isEmpty) {
      _showError('E-mail não encontrado para envio da redefinição.');
      return;
    }

    setState(() {
      _isSendingResetEmail = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'E-mail de redefinição enviado para $email!',
            style: const TextStyle(
              fontFamily: 'Raleway',
            ),
          ),
          backgroundColor: const Color(0xFF033B63),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Usuário não encontrado.';
          break;
        case 'invalid-email':
          message = 'E-mail inválido.';
          break;
        default:
          message = 'Erro ao enviar e-mail de redefinição.';
      }

      _showError(message);
    } catch (_) {
      if (!mounted) return;
      _showError('Erro ao enviar e-mail. Tente novamente mais tarde.');
    } finally {
      if (mounted) {
        setState(() {
          _isSendingResetEmail = false;
        });
      }
    }
  }

  // =============================================================
  // SALVAR DADOS
  // =============================================================

  Future<void> _saveData() async {
    final originalName = widget.initialData['name']?.toString().trim() ?? '';
    final originalRelationship =
        (widget.initialData['relationship']?.toString() ??
                widget.initialData['relationshipDegree']?.toString() ??
                '')
            .trim();

    final currentName = _nameController.text.trim();
    final currentRelationship = (_selectedRelationship ?? '').trim();

    final firestoreUpdates = <String, dynamic>{};

    if (currentName != originalName) {
      firestoreUpdates['name'] = currentName;
    }

    if (currentRelationship != originalRelationship) {
      if (currentRelationship.isEmpty) {
        _showError('Por favor, selecione seu grau de parentesco.');
        return;
      }

      firestoreUpdates['relationship'] = currentRelationship;
    }

    if (firestoreUpdates.isEmpty) {
      _showError('Nenhuma alteração foi realizada.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    FocusScope.of(context).unfocus();

    try {
      await FirebaseFirestore.instance
          .collection('familiares')
          .doc(widget.uid)
          .update(firestoreUpdates);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Dados atualizados com sucesso!',
            style: TextStyle(
              fontFamily: 'Raleway',
            ),
          ),
          backgroundColor: Color(0xFF033B63),
        ),
      );

      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      _showError('Erro ao atualizar os dados. Tente novamente mais tarde.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // =============================================================
  // MENSAGEM DE ERRO
  // =============================================================

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

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    final String email = widget.initialData['email']?.toString() ??
        FirebaseAuth.instance.currentUser?.email ??
        '';

    final String elderEmail = widget.initialData['linkedElderEmail']?.toString() ??
        widget.initialData['elderEmail']?.toString() ??
        widget.initialData['familyContact']?.toString() ??
        '';

    return Scaffold(
      backgroundColor: Colors.white,
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
                  GestureDetector(
                    onTap: () => Navigator.pop(context, false),
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
                  const Expanded(
                    child: Text(
                      'Dados Básicos',
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

            // =====================================================
            // CONTEÚDO
            // =====================================================

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  30,
                ),
                child: Column(
                  children: [
                    // =================================================
                    // CARD - DADOS DO CADASTRO
                    // =================================================

                    _buildCardGroup(
                      title: 'Dados do cadastro',
                      icon: Icons.person,
                      children: [
                        _buildInputField(
                          'Seu nome completo:',
                          _nameController,
                        ),

                        // VÍNCULO FAMILIAR (E-MAIL DO IDOSO)
                        _buildElderEmailDisplay(elderEmail),

                        // GRAU DE PARENTESCO
                        _buildRelationshipField(),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // =================================================
                    // CARD - ACESSO
                    // =================================================

                    _buildCardGroup(
                      title: 'Acesso',
                      icon: Icons.lock,
                      children: [
                        // E-MAIL
                        _buildEmailDisplay(email),

                        // SENHA (REDEFINIÇÃO POR E-MAIL)
                        _buildResetPasswordSection(email),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // =================================================
                    // BOTÃO EDITAR
                    // =================================================

                    SizedBox(
                      width: 160,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF033B63),
                          disabledBackgroundColor: const Color(0xFF033B63),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Editar',
                                style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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

  // =============================================================
  // CARD
  // =============================================================

  Widget _buildCardGroup({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 5,
            offset: Offset(2, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              14,
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Color(0xFF033B63),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
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
            color: Color(0xFF999999),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              16,
              18,
              6,
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // CAMPO DE TEXTO
  // =============================================================

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Raleway',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF033B63),
            ),
          ),
          const SizedBox(height: 7),
          SizedBox(
            height: 52,
            child: TextField(
              controller: controller,
              enabled: enabled,
              style: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 16,
                color: Color(0xFF666666),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF888888),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF888888),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF033B63),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // VÍNCULO FAMILIAR (E-MAIL DO IDOSO VINCULADO)
  // =============================================================

  Widget _buildElderEmailDisplay(String elderEmail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vínculo familiar:',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF033B63),
            ),
          ),
          const SizedBox(height: 7),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEDEDED),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFB5B5B5),
                width: 1,
              ),
            ),
            child: Text(
              elderEmail.isEmpty ? 'E-mail não informado' : elderEmail,
              style: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 16,
                color: Color(0xFF828282),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // GRAU DE PARENTESCO
  // =============================================================

  Widget _buildRelationshipField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grau de parentesco:',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF033B63),
            ),
          ),
          const SizedBox(height: 7),
          LayoutBuilder(
            builder: (context, constraints) {
              return DropdownMenu<String>(
                width: constraints.maxWidth,
                hintText: 'Selecione o grau de parentesco',
                initialSelection: _selectedRelationship,
                menuHeight: 250,
                trailingIcon: const RotatedBox(
                  quarterTurns: 1,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Color(0xFF949494),
                  ),
                ),
                selectedTrailingIcon: const RotatedBox(
                  quarterTurns: 3,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Color(0xFF949494),
                  ),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF888888),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF033B63),
                      width: 1.5,
                    ),
                  ),
                ),
                dropdownMenuEntries: _relationshipOptions
                    .map(
                      (option) => DropdownMenuEntry(
                        value: option,
                        label: option,
                      ),
                    )
                    .toList(),
                onSelected: (value) {
                  setState(() {
                    _selectedRelationship = value;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // =============================================================
  // E-MAIL FIXO DO FAMILIAR
  // =============================================================

  Widget _buildEmailDisplay(String email) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'E-mail:',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF033B63),
            ),
          ),
          const SizedBox(height: 7),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEDEDED),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFB5B5B5),
                width: 1,
              ),
            ),
            child: Text(
              email.isEmpty ? 'E-mail não informado' : email,
              style: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 16,
                color: Color(0xFF828282),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // SENHA (ENVIAR E-MAIL DE REDEFINIÇÃO)
  // =============================================================

  Widget _buildResetPasswordSection(String email) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Senha:',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF033B63),
            ),
          ),
          const SizedBox(height: 7),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _isSendingResetEmail
                  ? null
                  : () => _sendPasswordResetEmail(email),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(
                  color: Color(0xFF033B63),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _isSendingResetEmail
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF033B63),
                      ),
                    )
                  : const Icon(
                      Icons.mail_outline_rounded,
                      color: Color(0xFF033B63),
                    ),
              label: Text(
                _isSendingResetEmail
                    ? 'Enviando e-mail...'
                    : 'Alterar senha\npor e-mail',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF033B63),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}