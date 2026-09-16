import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../routes/app_routes.dart';

final class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Retorna o usuário atualmente autenticado
  static User? get currentUser => _auth.currentUser;

  // ============================================================
  // CADASTRO DE IDOSO
  // ============================================================
  static Future<void> signUpElderly({
    required String name,
    required String email,
    required String password,
    required String birthDate,
    required String city,
    required List<String> interests,
    String? linkedElderEmail,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = userCredential.user?.uid;
    if (uid == null) {
      throw FirebaseAuthException(
        code: 'invalid-user',
        message: 'Não foi possível criar o usuário.',
      );
    }

    final trimmedLinkedEmail = linkedElderEmail?.trim().toLowerCase();

    try {
      await _firestore.collection('idosos').doc(uid).set({
        'uid': uid,
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'role': 'idoso',
        'birthDate': birthDate,
        'city': city,
        // 2. Agora pode usar diretamente a variável já tratada
        'linkedElderEmail': (trimmedLinkedEmail?.isNotEmpty ?? false)
            ? trimmedLinkedEmail
            : null,
        'interests': interests,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      await userCredential.user?.delete();
      rethrow;
    }
  }

  // ============================================================
  // CADASTRO DE FAMILIAR
  // ============================================================
  static Future<void> signUpFamily({
    required String name,
    required String email,
    required String password,
    required String relationship,
    String? linkedElderEmail,
  }) async {
    final trimmedLinkedEmail = linkedElderEmail?.trim().toLowerCase();

    // 1. Cria a conta de autenticação primeiro para garantir que as
    // regras de segurança (request.auth != null) permitam a leitura no Firestore
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = userCredential.user?.uid;
    if (uid == null) {
      throw FirebaseAuthException(
        code: 'invalid-user',
        message: 'Não foi possível criar o usuário.',
      );
    }

    try {
      // 2. Se informou um e-mail de idoso, valida se ele realmente existe
      if (trimmedLinkedEmail != null && trimmedLinkedEmail.isNotEmpty) {
        final query = await _firestore
            .collection('idosos')
            .where('email', isEqualTo: trimmedLinkedEmail)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          throw FirebaseAuthException(
            code: 'linked-elder-not-found',
            message:
                'O e-mail do idoso informado não foi encontrado. Certifique-se de que o idoso já possui cadastro.',
          );
        }

        final data = query.docs.first.data();
        final role = data['role'];
        if (role != 'idoso') {
          throw FirebaseAuthException(
            code: 'linked-elder-not-found',
            message:
                'O e-mail do idoso informado não foi encontrado. Certifique-se de que o idoso já possui cadastro.',
          );
        }
      }

      // 3. Salva os dados do familiar no Firestore
      await _firestore.collection('familiares').doc(uid).set({
        'uid': uid,
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'role': 'familiar',
        'relationship': relationship.trim(),
        'linkedElderEmail': (trimmedLinkedEmail?.isNotEmpty ?? false)
            ? trimmedLinkedEmail
            : null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      // Se houver qualquer falha na validação ou salvamento, desfaz a criação da conta no Auth
      await userCredential.user?.delete();
      rethrow;
    }
  }

  // ============================================================
  // LOGIN E IDENTIFICAÇÃO DE ROLE
  // ============================================================
  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Consulta se o UID informado pertence a um idoso ou familiar
  static Future<String?> getUserRole(String uid) async {
    final idosoDoc = await _firestore.collection('idosos').doc(uid).get();
    if (idosoDoc.exists) return 'idoso';

    final familiarDoc =
        await _firestore.collection('familiares').doc(uid).get();
    if (familiarDoc.exists) return 'familiar';

    return null;
  }

  // ============================================================
  // RECUPERAÇÃO DE SENHA
  // ============================================================
  static Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ============================================================
  // LOGOUT
  // ============================================================
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static Future<void> signOutAndRedirect(BuildContext context) async {
    await signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}