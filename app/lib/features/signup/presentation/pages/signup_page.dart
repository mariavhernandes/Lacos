import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/services/auth_service.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final truncated = digitsOnly.length > 8 ? digitsOnly.substring(0, 8) : digitsOnly;

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
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

enum SignupFlow { idoso, familiar }

class InterestItem {
  final String label;
  final String? imagePath;
  final String? selectedImagePath;
  bool isSelected;

  InterestItem({
    required this.label,
    this.imagePath,
    this.selectedImagePath,
    this.isSelected = false,
  });
}

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  static const routeName = '/signup';

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  SignupFlow _flow = SignupFlow.idoso;
  int _step = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _elderEmailController = TextEditingController();

  String? _selectedCity;
  String? _selectedRelationship;
  bool _termsAccepted = false;
  bool _isLoading = false;

  List<InterestItem> _interests = [];

  @override
  void initState() {
    super.initState();
    _resetInterests();
  }

  void _resetInterests() {
    _interests = [
      InterestItem(
        label: 'Dominó',
        imagePath: 'assets/images/commun/domino.png',
        selectedImagePath: 'assets/images/commun/domino_selected.png',
      ),
      InterestItem(
        label: 'Jogo de cartas',
        imagePath: 'assets/images/commun/card_games.png',
        selectedImagePath: 'assets/images/commun/card_games_selected.png',
      ),
      InterestItem(
        label: 'Jogos de tabuleiro',
        imagePath: 'assets/images/commun/chess.png',
        selectedImagePath: 'assets/images/commun/chess_selected.png',
      ),
      InterestItem(
        label: 'Tricô/Crochê',
        imagePath: 'assets/images/commun/knitting.png',
        selectedImagePath: 'assets/images/commun/knitting_selected.png',
      ),
      InterestItem(
        label: 'Caminhada',
        imagePath: 'assets/images/commun/walking.png',
        selectedImagePath: 'assets/images/commun/walking_selected.png',
      ),
      InterestItem(
        label: 'Dança',
        imagePath: 'assets/images/commun/dancing.png',
        selectedImagePath: 'assets/images/commun/dancing_selected.png',
      ),
      InterestItem(
        label: 'Artesanato',
        imagePath: 'assets/images/commun/sewing.png',
        selectedImagePath: 'assets/images/commun/sewing_selected.png',
      ),
      InterestItem(
        label: 'Jardinagem',
        imagePath: 'assets/images/commun/gardening.png',
        selectedImagePath: 'assets/images/commun/gardening_selected.png',
      ),
    ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dateController.dispose();
    _elderEmailController.dispose();
    super.dispose();
  }

  int get maxSteps => _flow == SignupFlow.idoso ? 3 : 2;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Raleway')),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  bool _validateCurrentStep() {
    if (_step == 0) {
      if (_nameController.text.trim().isEmpty) {
        _showError('Por favor, informe seu nome completo.');
        return false;
      }
      if (_emailController.text.trim().isEmpty || !_emailController.text.contains('@')) {
        _showError('Por favor, insira um e-mail válido.');
        return false;
      }
      if (_passwordController.text.length < 6) {
        _showError('A senha deve ter pelo menos 6 caracteres.');
        return false;
      }
    } else if (_step == 1) {
      if (_flow == SignupFlow.idoso) {
        if (_dateController.text.length < 10) {
          _showError('Informe uma data de nascimento válida (DD/MM/AAAA).');
          return false;
        }
        if (_selectedCity == null) {
          _showError('Por favor, selecione sua cidade.');
          return false;
        }
      } else {
        if (_selectedRelationship == null) {
          _showError('Por favor, selecione o grau de parentesco.');
          return false;
        }
      }

      if (!_termsAccepted) {
        _showError('Você precisa aceitar os Termos de uso para continuar.');
        return false;
      }
    }
    return true;
  }

  List<String> _getSelectedInterests() {
    return _interests.where((item) => item.isSelected).map((item) => item.label).toList();
  }

  Future<void> _submit() async {
    if (!_validateCurrentStep()) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      if (_flow == SignupFlow.idoso) {
        await AuthService.signUpElderly(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          birthDate: _dateController.text,
          city: _selectedCity ?? '',
          interests: _getSelectedInterests(),
          linkedElderEmail: _elderEmailController.text,
        );
      } else {
        await AuthService.signUpFamily(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          relationship: _selectedRelationship ?? '',
          linkedElderEmail: _elderEmailController.text,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
            backgroundColor: Color(0xFF033B63),
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.splashScreen, (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'email-already-in-use' => 'Este e-mail já está cadastrado.',
        'invalid-email' => 'O e-mail informado não é válido.',
        'weak-password' => 'A senha deve ter pelo menos 6 caracteres.',
        'operation-not-allowed' => 'Cadastro com e-mail e senha não está habilitado.',
        'network-request-failed' => 'Falha de rede. Verifique sua conexão.',
        _ => 'Erro no cadastro: ${e.message ?? 'Tente novamente.'}',
      };
      _showError(message);
    } catch (error) {
      _showError('Erro ao salvar seus dados. Tente novamente mais tarde.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _next() {
    if (!_validateCurrentStep()) return;

    if (_step < maxSteps - 1) {
      setState(() => _step += 1);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step -= 1);
  }

  void _toggleFlow() {
    setState(() {
      _flow = _flow == SignupFlow.idoso ? SignupFlow.familiar : SignupFlow.idoso;
      _step = 0;
      _termsAccepted = false;

      // Limpa os textos digitados
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _dateController.clear();
      _elderEmailController.clear();

      // Limpa as seleções de dropdown
      _selectedCity = null;
      _selectedRelationship = null;

      // Reseta os interesses
      _resetInterests();
    });
  }
  

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1960),
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
      _dateController.text = '$day/$month/$year';
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Termos de Uso e Privacidade',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
            color: Color(0xFF033B63),
          ),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'Ao utilizar este aplicativo, você concorda com a coleta e o processamento dos seus dados pessoais exclusivamente para o funcionamento dos serviços de conexão, segurança e atividades comunitárias.\n\n'
            '1. Garantimos a proteção e privacidade dos seus dados cadastrais.\n'
            '2. As informações compartilhadas não serão vendidas a terceiros.\n'
            '3. Você pode solicitar a exclusão de sua conta a qualquer momento.',
            style: TextStyle(fontFamily: 'Raleway', fontSize: 14, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi', style: TextStyle(color: Color(0xFF033B63), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isElderly = _flow == SignupFlow.idoso;
    final isLastStep = _step == maxSteps - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Image.asset(
                'assets/logos/app_logo.png',
                height: 95,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 12),
              const Text(
                'Cadastre-se',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Color(0xFF033B63),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Crie uma conta',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF033B63),
                ),
              ),
              const SizedBox(height: 18),

              _ProgressBar(current: _step + 1, total: maxSteps),
              const SizedBox(height: 8),
              Text(
                'Passo ${_step + 1}',
                style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 15,
                  color: Color(0xFF033B63),
                ),
              ),
              const SizedBox(height: 18),

              _StepContent(
                flow: _flow,
                step: _step,
                nameController: _nameController,
                emailController: _emailController,
                passwordController: _passwordController,
                dateController: _dateController,
                elderEmailController: _elderEmailController,
                selectedCity: _selectedCity,
                selectedRelationship: _selectedRelationship,
                termsAccepted: _termsAccepted,
                interests: _interests,
                onCityChanged: (val) => setState(() => _selectedCity = val),
                onRelationshipChanged: (val) => setState(() => _selectedRelationship = val),
                onTermsChanged: (val) => setState(() => _termsAccepted = val ?? false),
                onCalendarTap: () => _selectDate(context),
                onOpenTerms: _showTermsDialog,
              ),

              const SizedBox(height: 12),
                if (_step == 0) ...[
                  const SizedBox(height: 10),
                  
                  // Link: Já possui uma conta? Entrar
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Já possui uma conta? ',
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF033B63),
                              ),
                            ),
                            TextSpan(
                              text: 'Entrar',
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF157699),
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF157699),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Link: É um familiar / idoso? Clique aqui
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _toggleFlow,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: isElderly ? 'É um familiar? ' : 'É um idoso? ',
                              style: const TextStyle(
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF033B63),
                              ),
                            ),
                            const TextSpan(
                              text: 'Clique aqui',
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF157699),
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF157699),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: _step > 0,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: TextButton(
                      onPressed: _back,
                      child: const Text(
                        'Voltar',
                        style: TextStyle(color: Color(0xFF033B63)),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF033B63),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: SizedBox(
                      height: 24,
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.2,
                                ),
                              )
                            : Text(
                                isLastStep ? 'Criar' : 'Avançar',
                                style: const TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressBar({Key? key, required this.current, required this.total}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ratio = (current / total).clamp(0.0, 1.0);
    return Column(
      children: [
        Stack(
          children: [
            Container(height: 8, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8))),
            FractionallySizedBox(
              widthFactor: ratio,
              child: Container(height: 8, decoration: BoxDecoration(color: const Color(0xFF0D4E6A), borderRadius: BorderRadius.circular(8))),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepContent extends StatefulWidget {
  final SignupFlow flow;
  final int step;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController dateController;
  final TextEditingController elderEmailController;
  final String? selectedCity;
  final String? selectedRelationship;
  final bool termsAccepted;
  final List<InterestItem>? interests;
  final ValueChanged<String?> onCityChanged;
  final ValueChanged<String?> onRelationshipChanged;
  final ValueChanged<bool?> onTermsChanged;
  final VoidCallback onCalendarTap;
  final VoidCallback onOpenTerms;

  const _StepContent({
    Key? key,
    required this.flow,
    required this.step,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.dateController,
    required this.elderEmailController,
    required this.selectedCity,
    required this.selectedRelationship,
    required this.termsAccepted,
    this.interests,
    required this.onCityChanged,
    required this.onRelationshipChanged,
    required this.onTermsChanged,
    required this.onCalendarTap,
    required this.onOpenTerms,
  }) : super(key: key);

  @override
  State<_StepContent> createState() => _StepContentState();
}

class _StepContentState extends State<_StepContent> {
  bool _obscurePassword = true;

  Widget _input({
    required String label,
    String? hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
    bool obscureText = false,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: suffixIcon,
          labelStyle: const TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w600,
            color: Color(0xFF033B63),
          ),
          hintStyle: const TextStyle(
            fontFamily: 'Raleway',
            color: Color(0xFF828282),
          ),
          filled: true,
          fillColor: const Color(0xFFF6F6F6),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF888888)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF033B63), width: 2),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator(String password) {
    if (password.isEmpty) return const SizedBox.shrink();

    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

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

  void _showAddOtherDialog() {
    final TextEditingController otherController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Adicionar atividades:',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF033B63),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: otherController,
                  decoration: InputDecoration(
                    hintText: 'Ex: Hidroginástica',
                    hintStyle: const TextStyle(
                      fontFamily: 'Raleway',
                      color: Color(0xFFB0B0B0),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF6F6F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF888888)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF888888)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      final text = otherController.text.trim();
                      if (text.isNotEmpty) {
                        setState(() {
                          (widget.interests ?? []).add(InterestItem(
                            label: text,
                            isSelected: true,
                          ));
                        });
                        Navigator.of(dialogContext).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF033B63),
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Adicionar',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<InterestItem> activeInterests = widget.interests ?? [];

    if (widget.flow == SignupFlow.idoso) {
      switch (widget.step) {
        case 0:
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _input(
                label: 'Nome completo',
                hint: 'Digite seu nome completo',
                controller: widget.nameController,
              ),
              const SizedBox(height: 8),
              _input(
                label: 'E-mail',
                hint: 'Digite seu e-mail',
                controller: widget.emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
              _input(
                label: 'Senha',
                hint: 'Digite sua senha',
                controller: widget.passwordController,
                obscureText: _obscurePassword,
                onChanged: (val) => setState(() {}),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF033B63),
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              _buildPasswordStrengthIndicator(widget.passwordController.text),
            ],
          );
        case 1:
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _input(
                label: 'Data de nascimento',
                hint: 'DD/MM/AAAA',
                controller: widget.dateController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  DateInputFormatter(),
                ],
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.calendar_month_outlined,
                    color: Color(0xFF033B63),
                  ),
                  onPressed: widget.onCalendarTap,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cidade:',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF033B63),
                ),
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  return DropdownMenu<String>(
                    width: constraints.maxWidth,
                    hintText: 'Selecione sua cidade',
                    initialSelection: widget.selectedCity,
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
                      fillColor: const Color(0xFFF6F6F6),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF888888)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF033B63), width: 2),
                      ),
                    ),
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: 'Americana', label: 'Americana'),
                      DropdownMenuEntry(value: 'Campinas', label: 'Campinas'),
                      DropdownMenuEntry(value: 'Limeira', label: 'Limeira'),
                      DropdownMenuEntry(
                        value: 'Santa Bárbara d\'Oeste',
                        label: 'Santa Bárbara d\'Oeste',
                      ),
                      DropdownMenuEntry(value: 'Sumaré', label: 'Sumaré'),
                    ],
                    onSelected: widget.onCityChanged,
                  );
                },
              ),
              // const SizedBox(height: 16),
              // _input(
              //   label: 'E-mail do familiar (opcional)',
              //   hint: 'Digite o e-mail',
              //   controller: widget.elderEmailController,
              //   keyboardType: TextInputType.emailAddress,
              // ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: widget.termsAccepted,
                    shape: const CircleBorder(),
                    side: const BorderSide(
                      color: Color(0xFF02394E),
                      width: 2,
                    ),
                    checkColor: Colors.white,
                    fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.selected)) {
                        return const Color(0xFF02394E);
                      }
                      return Colors.transparent;
                    }),
                    onChanged: widget.onTermsChanged,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onOpenTerms,
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Concordo com os ',
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                color: Color(0xFF828282),
                              ),
                            ),
                            TextSpan(
                              text: 'Termos de uso',
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                color: Color(0xFF02394E),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );

        case 2:
        default:
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Interesses:',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF033B63),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Selecione suas atividades favoritas',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 14,
                  color: Color(0xFF828282),
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: activeInterests.map((item) {
                  final String? activeImagePath = item.isSelected
                      ? (item.selectedImagePath ?? item.imagePath)
                      : item.imagePath;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        item.isSelected = !item.isSelected;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: item.isSelected
                            ? const Color(0xFF033B63)
                            : const Color(0xFFF6F6F6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF033B63),
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (activeImagePath != null)
                              Image.asset(
                                activeImagePath,
                                height: 42,
                                width: 42,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.extension_outlined,
                                    size: 38,
                                    color: item.isSelected
                                        ? Colors.white
                                        : const Color(0xFF033B63),
                                  );
                                },
                              )
                            else
                              Icon(
                                Icons.star_border_rounded,
                                size: 38,
                                color: item.isSelected
                                    ? Colors.white
                                    : const Color(0xFF033B63),
                              ),
                            const SizedBox(height: 10),
                            Text(
                              item.label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: item.isSelected
                                    ? Colors.white
                                    : const Color(0xFF033B63),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _showAddOtherDialog,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Outras ',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF033B63),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Color(0xFF033B63),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
      }
    } else {
      switch (widget.step) {
        case 0:
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _input(
                label: 'Nome completo',
                hint: 'Digite seu nome completo',
                controller: widget.nameController,
              ),
              const SizedBox(height: 8),
              _input(
                label: 'E-mail',
                hint: 'Digite seu e-mail',
                controller: widget.emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
              _input(
                label: 'Senha',
                hint: 'Digite sua senha',
                controller: widget.passwordController,
                obscureText: _obscurePassword,
                onChanged: (val) => setState(() {}),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF033B63),
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              _buildPasswordStrengthIndicator(widget.passwordController.text),
            ],
          );
        case 1:
        default:
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Grau de parentesco:',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF033B63),
                ),
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  return DropdownMenu<String>(
                    width: constraints.maxWidth,
                    hintText: 'Selecione o parentesco',
                    initialSelection: widget.selectedRelationship,
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
                      fillColor: const Color(0xFFF6F6F6),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF888888)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF033B63), width: 2),
                      ),
                    ),
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: 'Filho(a)', label: 'Filho(a)'),
                      DropdownMenuEntry(value: 'Neto(a)', label: 'Neto(a)'),
                      DropdownMenuEntry(value: 'Cuidador(a)', label: 'Cuidador(a)'),
                      DropdownMenuEntry(value: 'Amigo(a)', label: 'Amigo(a)'),
                      DropdownMenuEntry(value: 'Outro', label: 'Outro'),
                    ],
                    onSelected: widget.onRelationshipChanged,
                  );
                },
              ),
              const SizedBox(height: 16),
              _input(
                label: 'Vincular usuário:',
                hint: 'Digite o e-mail de seu familiar',
                controller: widget.elderEmailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: widget.termsAccepted,
                    shape: const CircleBorder(),
                    side: const BorderSide(
                      color: Color(0xFF02394E),
                      width: 2,
                    ),
                    checkColor: Colors.white,
                    fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.selected)) {
                        return const Color(0xFF02394E);
                      }
                      return Colors.transparent;
                    }),
                    onChanged: widget.onTermsChanged,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onOpenTerms,
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Concordo com os ',
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                color: Color(0xFF828282),
                              ),
                            ),
                            TextSpan(
                              text: 'Termos de uso',
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                color: Color(0xFF02394E),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
      }
    }
  }
}