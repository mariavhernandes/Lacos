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
  // CONTROLLERS
  // =============================================================

  late TextEditingController _nameController;
  late TextEditingController _passwordController;

  // =============================================================
  // VARIÁVEIS
  // =============================================================

  String? _selectedRelationship;
  bool _isLoading = false;

  // Controla se a senha está escondida
  bool _obscurePassword = true;

  // Indica que os pontinhos são apenas uma representação da senha
  bool _isPasswordPlaceholder = true;

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

    // Começa mostrando pontinhos para representar que existe uma senha cadastrada.
    _passwordController = TextEditingController(
      text: '••••••••',
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
    _passwordController.dispose();

    super.dispose();
  }

  // =============================================================
  // INDICADOR DE FORÇA DA SENHA
  // =============================================================

  Widget _buildPasswordStrengthIndicator(String password) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    int score = 0;

    if (password.length >= 6) {
      score++;
    }

    if (password.length >= 8) {
      score++;
    }

    if (RegExp(r'[A-Z]').hasMatch(password)) {
      score++;
    }

    if (RegExp(r'[0-9]').hasMatch(password)) {
      score++;
    }

    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      score++;
    }

    Color color = Colors.red;
    String label = 'Fraca';
    double flexValue = 0.33;

    if (score >= 4) {
      color = Colors.green;
      label = 'Forte';
      flexValue = 1.0;
    } else if (score >= 2) {
      color = Colors.orange;
      label = 'Média';
      flexValue = 0.66;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: flexValue,
                  color: color,
                  backgroundColor: Colors.grey.shade300,
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Raleway',
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
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

    final newPassword =
        _isPasswordPlaceholder ? '' : _passwordController.text.trim();

    if (newPassword.isNotEmpty && newPassword.length < 6) {
      _showError('A senha deve ter pelo menos 6 caracteres.');
      return;
    }

    if (firestoreUpdates.isEmpty && newPassword.isEmpty) {
      _showError('Nenhuma alteração foi realizada.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    FocusScope.of(context).unfocus();

    try {
      if (firestoreUpdates.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('familiares')
            .doc(widget.uid)
            .update(firestoreUpdates);
      }

      if (newPassword.isNotEmpty) {
        final User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser == null) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'Usuário não autenticado.',
          );
        }

        await currentUser.updatePassword(newPassword);
      }

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
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'weak-password':
          message = 'A senha deve ter pelo menos 6 caracteres.';
          break;
        case 'requires-recent-login':
          message =
              'Por segurança, faça login novamente antes de alterar sua senha.';
          break;
        case 'user-not-found':
          message = 'Usuário não encontrado.';
          break;
        case 'network-request-failed':
          message = 'Falha de rede. Verifique sua conexão.';
          break;
        default:
          message = 'Erro ao atualizar a senha. Tente novamente mais tarde.';
      }

      _showError(message);
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

                        // =================================================
                        // VÍNCULO FAMILIAR (E-MAIL DO IDOSO)
                        // =================================================

                        _buildElderEmailDisplay(elderEmail),

                        // =================================================
                        // GRAU DE PARENTESCO
                        // =================================================

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
                        // =================================================
                        // E-MAIL
                        // =================================================

                        _buildEmailDisplay(email),

                        // =================================================
                        // SENHA
                        // =================================================

                        _buildPasswordField(),

                        // =================================================
                        // FORÇA DA SENHA
                        // =================================================

                        _buildPasswordStrengthIndicator(
                          _isPasswordPlaceholder
                              ? ''
                              : _passwordController.text,
                        ),
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
          // CABEÇALHO DO CARD
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

          // DIVISOR
          const Divider(
            height: 1,
            thickness: 0.8,
            color: Color(0xFF999999),
          ),

          // CAMPOS
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
  // VÍNCULO FAMILIAR (E-MAIL DO IDOSO VINCULADO - DESABILITADO)
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
  // SENHA
  // =============================================================

  Widget _buildPasswordField() {
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
            height: 52,
            child: TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              onChanged: (value) {
                if (_isPasswordPlaceholder) {
                  setState(() {
                    _isPasswordPlaceholder = false;
                  });
                }
              },
              onTap: () {
                if (_isPasswordPlaceholder) {
                  _passwordController.clear();
                  setState(() {
                    _isPasswordPlaceholder = false;
                  });
                }
              },
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
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF033B63),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
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
}