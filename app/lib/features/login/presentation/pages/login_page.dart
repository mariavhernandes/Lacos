import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../../core/routes/app_routes.dart';

enum LoginProfile { usuario, familiar }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginProfile _profile = LoginProfile.usuario;
  bool _showPassword = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _verificarSessaoAtiva();
  }

  void _verificarSessaoAtiva() {
    FirebaseAuth.instance.authStateChanges().first.then((user) async {
      if (user != null && mounted) {
        final familyDoc = await FirebaseFirestore.instance
            .collection('familiares')
            .doc(user.uid)
            .get();

        if (!mounted) return;

        if (familyDoc.exists) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.familyHome,
            (route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.splashScreen,
            (route) => false,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToSignup() {
    Navigator.pushNamed(context, AppRoutes.signup);
  }

  void _navigateToRecoverPassword() {
    Navigator.pushNamed(context, AppRoutes.recoverPassword);
  }

  Future<void> _showError(String message) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Raleway')),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      final credentials = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final uid = credentials.user?.uid;
      if (uid == null) {
        throw FirebaseAuthException(
          code: 'invalid-user',
          message: 'Não foi possível recuperar o usuário autenticado.',
        );
      }

      final String primaryCollection =
          _profile == LoginProfile.usuario ? 'idosos' : 'familiares';

      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance.collection(primaryCollection).doc(uid).get();

      if (!userDoc.exists) {
        final String secondaryCollection =
            _profile == LoginProfile.usuario ? 'users' : 'responsaveis';
        userDoc = await FirebaseFirestore.instance
            .collection(secondaryCollection)
            .doc(uid)
            .get();
      }

      if (!userDoc.exists) {
        userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      }

      if (!userDoc.exists || userDoc.data() == null) {
        await FirebaseAuth.instance.signOut();
        await _showError('Dados do usuário não encontrados. Faça o cadastro novamente.');
        return;
      }

      final userData = userDoc.data()!;

      final String rawRole = (userData['role'] ??
                              userData['tipo'] ??
                              userData['perfil'] ??
                              userData['accountType'] ??
                              '').toString().toLowerCase().trim();

      final bool isElderlyRole = rawRole == 'idoso' || rawRole == 'usuario' || rawRole == 'user';
      final bool isFamilyRole = rawRole == 'familiar' || rawRole == 'responsavel' || rawRole == 'family';

      final bool isSelectedElderly = _profile == LoginProfile.usuario;
      final bool isSelectedFamily = _profile == LoginProfile.familiar;

      final bool isProfileValid = (isSelectedElderly && (isElderlyRole || rawRole.isEmpty)) ||
                                  (isSelectedFamily && (isFamilyRole || rawRole.isEmpty));

      if (!isProfileValid) {
        await FirebaseAuth.instance.signOut();
        await _showError('Este perfil de acesso não corresponde ao tipo da sua conta.');
        return;
      }

      if (!mounted) return;

      final String targetRoute = isSelectedFamily
          ? AppRoutes.familyHome
          : AppRoutes.splashScreen;

      Navigator.pushNamedAndRemoveUntil(context, targetRoute, (route) => false);
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'user-not-found' => 'Usuário não encontrado.',
        'wrong-password' => 'E-mail ou senha incorretos.',
        'invalid-credential' => 'E-mail ou senha incorretos.',
        'invalid-email' => 'Formato de e-mail inválido.',
        'user-disabled' => 'Esta conta foi desativada.',
        'too-many-requests' => 'Muitas tentativas. Tente novamente mais tarde.',
        _ => 'Erro de autenticação. Verifique seus dados e tente novamente.',
      };
      await _showError(message);
    } catch (_) {
      await _showError('Erro ao realizar login. Tente novamente mais tarde.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
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

  Widget _buildProfileCheckbox(LoginProfile profile, String label) {
    final bool isSelected = _profile == profile;
    return InkWell(
      onTap: () => setState(() => _profile = profile),
      borderRadius: BorderRadius.circular(8),
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: isSelected,
              shape: const CircleBorder(),
              side: const BorderSide(
                color: Color(0xFF033B63),
                width: 2,
              ),
              checkColor: Colors.white,
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF033B63);
                }
                return Colors.transparent;
              }),
              onChanged: (_) => setState(() => _profile = profile),
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF033B63),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 18),
              const Text(
                'Bem-vindo(a)!',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Color(0xFF033B63),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Entre com sua conta',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color(0xFF033B63),
                ),
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Perfil de acesso:',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF033B63),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildProfileCheckbox(LoginProfile.usuario, 'Usuário'),
                      const SizedBox(width: 16),
                      _buildProfileCheckbox(LoginProfile.familiar, 'Familiar'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInput(
                          label: 'E-mail',
                          hint: 'Digite seu e-mail',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe seu e-mail.';
                            }
                            final emailRegex = RegExp(
                                r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'E-mail inválido.';
                            }
                            return null;
                          },
                        ),
                        _buildInput(
                          label: 'Senha',
                          hint: 'Digite sua senha',
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                                () => _showPassword = !_showPassword),
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xFF033B63),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe sua senha.';
                            }
                            if (value.length < 6) {
                              return 'A senha deve ter pelo menos 6 caracteres.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: _navigateToRecoverPassword,
                            child: RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Esqueceu a senha? ',
                                    style: TextStyle(
                                      fontFamily: 'Raleway',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Color(0xFF033B63),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Clique aqui',
                                    style: TextStyle(
                                      fontFamily: 'Raleway',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
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
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF033B63),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                                    'Entrar',
                                    style: TextStyle(
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _navigateToSignup,
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Não possui conta? ',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF033B63),
                          ),
                        ),
                        TextSpan(
                          text: 'Cadastre-se',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
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
          ),
        ),
      ),
    );
  }
}