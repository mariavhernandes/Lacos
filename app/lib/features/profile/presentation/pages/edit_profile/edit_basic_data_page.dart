import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  late TextEditingController _nameController;
  late TextEditingController _familyController;
  late TextEditingController _birthDateController;

  String? _selectedCity;
  bool _isLoading = false;
  bool _isSendingResetEmail = false;

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

    _selectedCity = widget.initialData['city']?.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _familyController.dispose();
    _birthDateController.dispose();

    super.dispose();
  }

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

  Future<void> _sendPasswordResetEmail(String email) async {
    if (email.isEmpty) {
      _showError('E-mail do usuário não foi encontrado.');
      return;
    }

    setState(() {
      _isSendingResetEmail = true;
    });

    try {
      await FirebaseAuth.instance.setLanguageCode('pt-BR');
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'E-mail de redefinição enviado com sucesso! Verifique sua caixa de entrada.',
            style: TextStyle(fontFamily: 'Raleway'),
          ),
          backgroundColor: Color(0xFF033B63),
          duration: Duration(seconds: 4),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      final message = switch (e.code) {
        'user-not-found' => 'Usuário não encontrado.',
        'invalid-email' => 'Formato de e-mail inválido.',
        'too-many-requests' => 'Muitas tentativas. Tente novamente mais tarde.',
        _ => 'Erro ao enviar o e-mail de redefinição. Tente novamente.',
      };
      _showError(message);
    } catch (_) {
      if (!mounted) return;
      _showError('Erro ao enviar o e-mail. Tente novamente mais tarde.');
    } finally {
      if (mounted) {
        setState(() {
          _isSendingResetEmail = false;
        });
      }
    }
  }

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
          .collection('idosos')
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
                    _buildCardGroup(
                      title: 'Dados do cadastro',
                      icon: Icons.person,
                      children: [
                        _buildInputField(
                          'Seu nome completo:',
                          _nameController,
                        ),
                        _buildDateField(),
                        _buildCityField(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildCardGroup(
                      title: 'Acesso',
                      icon: Icons.lock,
                      children: [
                        _buildEmailDisplay(email),
                        _buildResetPasswordSection(email),
                      ],
                    ),
                    const SizedBox(height: 30),
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
                  onPressed: () => _selectDate(context),
                ),
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
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                    : 'Alterar senha' + '\n' + 'por e-mail',
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