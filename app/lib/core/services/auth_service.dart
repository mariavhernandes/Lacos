import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../features/notifications/data/notification_service.dart';
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

    final trimmedLinkedEmail = linkedElderEmail?.trim();

    try {
      await _firestore.collection('idosos').doc(uid).set({
        'uid': uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': 'idoso',
        'birthDate': birthDate,
        'city': city,
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
    final trimmedLinkedEmail = linkedElderEmail?.trim();

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
      final familyReference = _firestore.collection('familiares').doc(uid);
      final familyNotificationService =
          FamilyNotificationService(firestore: _firestore);

      if (trimmedLinkedEmail == null || trimmedLinkedEmail.isEmpty) {
        await familyReference.set({
          'uid': uid,
          'name': name.trim(),
          'email': email.trim(),
          'role': 'familiar',
          'relationship': relationship.trim(),
          'linkedElderEmail': null,
          'familyLinkStatus': 'none',
          'createdAt': FieldValue.serverTimestamp(),
        });
        return;
      }

      final elderQuery = await _firestore
          .collection('idosos')
          .where('email', isEqualTo: trimmedLinkedEmail)
          .limit(1)
          .get();
      if (elderQuery.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'linked-elder-not-found',
          message: 'O idoso vinculado não foi encontrado.',
        );
      }

      final elderData = elderQuery.docs.first.data();
      if (elderData['role'] != 'idoso') {
        throw FirebaseAuthException(
          code: 'linked-elder-not-found',
          message: 'O idoso vinculado não foi encontrado.',
        );
      }

      final elderReference = elderQuery.docs.first.reference;
      final elderUid = elderReference.id;

      await _firestore.runTransaction((transaction) async {
        final elderSnapshot = await transaction.get(elderReference);
        final elderData = elderSnapshot.data() ?? <String, dynamic>{};
        final linkedFamilyUid = elderData['linkedFamilyUid']?.toString();
        final linkStatus = elderData['familyLinkStatus']?.toString();

        if (linkStatus == 'active' &&
            linkedFamilyUid != null &&
            linkedFamilyUid.isNotEmpty) {
          throw FirebaseAuthException(
            code: 'elder-already-linked',
            message: 'Este idoso já possui um familiar vinculado.',
          );
        }

        transaction.set(familyReference, {
          'uid': uid,
          'name': name.trim(),
          'email': email.trim(),
          'role': 'familiar',
          'relationship': relationship.trim(),
          'linkedElderEmail': trimmedLinkedEmail,
          'linkedElderUid': elderUid,
          'familyLinkStatus': 'active',
          'createdAt': FieldValue.serverTimestamp(),
        });
        transaction.update(elderReference, {
          'linkedFamilyUid': uid,
          'familyLinkStatus': 'active',
          'familyLinkBlockedAt': FieldValue.delete(),
          'familyLinkBlockedBy': FieldValue.delete(),
        });
        familyNotificationService.setFamilyLinkCreatedNotification(
          transaction: transaction,
          elderUid: elderUid,
          familyUid: uid,
          familyName: name.trim(),
        );
      });
    } catch (error) {
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
