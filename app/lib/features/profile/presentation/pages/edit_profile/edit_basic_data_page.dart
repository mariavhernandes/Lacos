import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ===============================================================
// FORMATADOR DE DATA
// ===============================================================

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    final truncated =
        digitsOnly.length > 8 ? digitsOnly.substring(0, 8) : digitsOnly;

    final buffer = StringBuffer();

    for (int i = 0; i < truncated.length; i++) {
      if (i == 2 || i == 4) {
        buffer.write('/');
      }

      buffer.write(truncated[i]);
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}

// ===============================================================
// PÁGINA DE EDIÇÃO DOS DADOS
// ===============================================================

class EditBasicDataPage extends StatefulWidget {
  final String uid;
  final Map<String, dynamic> initialData;

  const EditBasicDataPage({
    super.key,
    required this.uid,
    required this.initialData,
  });

  @override
  State<EditBasicDataPage> createState() => _EditBasicDataPageState();
}

class _EditBasicDataPageState extends State<EditBasicDataPage> {
  // =============================================================
  // CONTROLLERS
  // =============================================================

  late TextEditingController _nameController;
  late TextEditingController _familyController;
  late TextEditingController _birthDateController;
  late TextEditingController _passwordController;

  // =============================================================
  // VARIÁVEIS
  // =============================================================

  String? _selectedCity;

  bool _isLoading = false;

  // Controla se a senha está escondida
  bool _obscurePassword = true;

  // Indica que os pontinhos são apenas uma representação
  // da senha já cadastrada e não uma senha real armazenada
  bool _isPasswordPlaceholder = true;

  // =============================================================
  // INIT STATE
  // =============================================================

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.initialData['name']?.toString() ?? '',
    );

    _familyController = TextEditingController(
      text: widget.initialData['familyContact']?.toString() ?? '',
    );

    _birthDateController = TextEditingController(
      text: widget.initialData['birthDate']?.toString() ?? '',
    );

    // Começa mostrando pontinhos para representar
    // que existe uma senha cadastrada.
    _passwordController = TextEditingController(
      text: '••••••••',
    );

    _selectedCity = widget.initialData['city']?.toString();
  }

  // =============================================================
  // DISPOSE
  // =============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _familyController.dispose();
    _birthDateController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // =============================================================
  // SELECIONAR DATA
  // =============================================================

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime(1960);

    final currentDate = _parseDate(
      _birthDateController.text,
    );

    if (currentDate != null) {
      initialDate = currentDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF033B63),
              onPrimary: Colors.white,
              onSurface: Color(0xFF033B63),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      final year = picked.year.toString();

      setState(() {
        _birthDateController.text = '$day/$month/$year';
      });
    }
  }

  // =============================================================
  // CONVERTER DATA
  // =============================================================

  DateTime? _parseDate(String value) {
    try {
      final parts = value.split('/');

      if (parts.length != 3) {
        return null;
      }

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final date = DateTime(
        year,
        month,
        day,
      );

      if (date.day != day ||
          date.month != month ||
          date.year != year) {
        return null;
      }

      return date;
    } catch (_) {
      return null;
    }
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
    final originalBirthDate =
        widget.initialData['birthDate']?.toString().trim() ?? '';
    final originalCity = widget.initialData['city']?.toString().trim() ?? '';

    final currentName = _nameController.text.trim();
    final currentBirthDate = _birthDateController.text.trim();
    final currentCity = (_selectedCity ?? '').trim();

    final firestoreUpdates = <String, dynamic>{};

    if (currentName != originalName) {
      firestoreUpdates['name'] = currentName;
    }

    if (currentBirthDate != originalBirthDate) {
      if (currentBirthDate.length < 10 ||
          _parseDate(currentBirthDate) == null) {
        _showError('Informe uma data de nascimento válida (DD/MM/AAAA).');
        return;
      }

      firestoreUpdates['birthDate'] = currentBirthDate;
    }

    if (currentCity != originalCity) {
      if (currentCity.isEmpty) {
        _showError('Por favor, selecione sua cidade.');
        return;
      }

      firestoreUpdates['city'] = currentCity;
    }

    final newPassword = _isPasswordPlaceholder
        ? ''
        : _passwordController.text.trim();

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
            .collection('idosos')
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
    final String email =
        widget.initialData['email']?.toString() ??
        FirebaseAuth.instance.currentUser?.email ??
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
                        // DATA DE NASCIMENTO
                        // =================================================

                        _buildDateField(),

                        // =================================================
                        // CIDADE
                        // =================================================

                        _buildCityField(),
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
                        onPressed:
                            _isLoading ? null : _saveData,

                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF033B63),

                          disabledBackgroundColor:
                              const Color(0xFF033B63),

                          shape: RoundedRectangleBorder(
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
          // =======================================================
          // CABEÇALHO DO CARD
          // =======================================================

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

          // =======================================================
          // DIVISOR
          // =======================================================

          const Divider(
            height: 1,
            thickness: 0.8,
            color: Color(0xFF999999),
          ),

          // =======================================================
          // CAMPOS
          // =======================================================

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
    bool obscureText = false,
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

              obscureText: obscureText,

              style: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 16,
                color: Color(0xFF666666),
              ),

              decoration: InputDecoration(
                filled: true,

                fillColor: Colors.white,

                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),

                  borderSide: const BorderSide(
                    color: Color(0xFF888888),
                    width: 1,
                  ),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),

                  borderSide: const BorderSide(
                    color: Color(0xFF888888),
                    width: 1,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),

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
  // DATA DE NASCIMENTO
  // =============================================================

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Data nascimento:',

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
              controller: _birthDateController,

              keyboardType: TextInputType.number,

              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                DateInputFormatter(),
              ],

              style: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 16,
                color: Color(0xFF666666),
              ),

              decoration: InputDecoration(
                hintText: 'DD/MM/AAAA',

                hintStyle: const TextStyle(
                  fontFamily: 'Raleway',
                  color: Color(0xFF828282),
                ),

                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.calendar_month_outlined,
                    color: Color(0xFF033B63),
                  ),

                  onPressed: () =>
                      _selectDate(context),
                ),

                filled: true,

                fillColor: Colors.white,

                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),

                  borderSide: const BorderSide(
                    color: Color(0xFF888888),
                    width: 1,
                  ),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),

                  borderSide: const BorderSide(
                    color: Color(0xFF888888),
                    width: 1,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),

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
  // CIDADE
  // =============================================================

  Widget _buildCityField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Cidade:',

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

                hintText: 'Selecione sua cidade',

                initialSelection: _selectedCity,

                menuHeight: 250,

                trailingIcon: const RotatedBox(
                  quarterTurns: 1,

                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Color(0xFF949494),
                  ),
                ),

                selectedTrailingIcon:
                    const RotatedBox(
                  quarterTurns: 3,

                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Color(0xFF949494),
                  ),
                ),

                inputDecorationTheme:
                    InputDecorationTheme(
                  filled: true,

                  fillColor: Colors.white,

                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),

                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),

                    borderSide:
                        const BorderSide(
                      color: Color(0xFF888888),
                    ),
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),

                    borderSide:
                        const BorderSide(
                      color: Color(0xFF033B63),
                      width: 1.5,
                    ),
                  ),
                ),

                dropdownMenuEntries: const [
                  DropdownMenuEntry(
                    value: 'Americana',
                    label: 'Americana',
                  ),

                  DropdownMenuEntry(
                    value: 'Campinas',
                    label: 'Campinas',
                  ),

                  DropdownMenuEntry(
                    value: 'Limeira',
                    label: 'Limeira',
                  ),

                  DropdownMenuEntry(
                    value: "Santa Bárbara d'Oeste",
                    label: "Santa Bárbara d'Oeste",
                  ),

                  DropdownMenuEntry(
                    value: 'Sumaré',
                    label: 'Sumaré',
                  ),
                ],

                onSelected: (value) {
                  setState(() {
                    _selectedCity = value;
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
  // E-MAIL FIXO
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

              borderRadius:
                  BorderRadius.circular(14),

              border: Border.all(
                color: const Color(0xFFB5B5B5),
                width: 1,
              ),
            ),

            child: Text(
              email.isEmpty
                  ? 'E-mail não informado'
                  : email,

              style: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // CAMPO DE SENHA
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

              // =================================================
              // QUANDO A PESSOA CLICA NO CAMPO
              // =================================================

              onTap: () {
                if (_isPasswordPlaceholder) {
                  setState(() {
                    _isPasswordPlaceholder = false;

                    _passwordController.clear();
                  });
                }
              },

              // =================================================
              // QUANDO A PESSOA DIGITA
              // =================================================

              onChanged: (value) {
                if (_isPasswordPlaceholder) {
                  setState(() {
                    _isPasswordPlaceholder = false;
                  });
                } else {
                  // Atualiza a tela para o indicador
                  // de força da senha.
                  setState(() {});
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

                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),

                // =================================================
                // OLHINHO
                // =================================================

                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword =
                          !_obscurePassword;
                    });
                  },

                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,

                    color: const Color(0xFF033B63),
                  ),
                ),

                // =================================================
                // BORDAS
                // =================================================

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),

                  borderSide: const BorderSide(
                    color: Color(0xFF888888),
                    width: 1,
                  ),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),

                  borderSide: const BorderSide(
                    color: Color(0xFF888888),
                    width: 1,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),

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