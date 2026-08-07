import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _showMessage(String message, {Color backgroundColor = const Color(0xFF033B63)}) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Raleway')),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handlePasswordReset() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      await FirebaseAuth.instance.setLanguageCode('pt-BR');
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      await _showMessage(
        'E-mail enviado com sucesso. Verifique sua caixa de entrada para redefinir a senha.',
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'user-not-found' => 'Usuário não encontrado.',
        'invalid-email' => 'Formato de e-mail inválido.',
        'too-many-requests' => 'Muitas tentativas. Tente novamente mais tarde.',
        _ => 'Erro ao enviar o e-mail de redefinição. Tente novamente.',
      };
      await _showMessage(message, backgroundColor: Colors.redAccent);
    } catch (_) {
      await _showMessage('Erro ao enviar o e-mail. Tente novamente mais tarde.', backgroundColor: Colors.redAccent);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF033B63)),
        title: const Text(
          'Recuperar senha',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
            color: Color(0xFF033B63),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Informe o e-mail cadastrado para enviar o link de redefinição de senha.',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 16,
                  color: Color(0xFF033B63),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        hintText: 'Digite seu e-mail',
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe seu e-mail.';
                        }
                        final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'E-mail inválido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handlePasswordReset,
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
                                'Enviar e-mail de redefinição',
                                textAlign: TextAlign.center,
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
        ),
      ),
    );
  }
}
