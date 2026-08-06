import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        'linkedElderEmail': (trimmedLinkedEmail?.isNotEmpty ?? false) ? trimmedLinkedEmail : null,
        'interests': interests,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      await userCredential.user?.delete();
      rethrow;
    }
  }

  static Future<void> signUpFamily({
    required String name,
    required String email,
    required String password,
    required String relationship,
    String? linkedElderEmail,
  }) async {
    final trimmedLinkedEmail = linkedElderEmail?.trim();

    // Se um e-mail de idoso foi informado, verifique se existe um documento
    // na coleção 'idosos' com este e-mail e role 'idoso' antes de criar a conta.
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
              "O e-mail do idoso informado não foi encontrado. Certifique-se de que o idoso já possui cadastro.",
        );
      }

      final data = query.docs.first.data();
      final role = data['role'];
      if (role != 'idoso') {
        throw FirebaseAuthException(
          code: 'linked-elder-not-found',
          message:
              "O e-mail do idoso informado não foi encontrado. Certifique-se de que o idoso já possui cadastro.",
        );
      }
    }

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
      await _firestore.collection('familiares').doc(uid).set({
        'uid': uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': 'familiar',
        'relationship': relationship.trim(),
        'linkedElderEmail': (trimmedLinkedEmail?.isNotEmpty ?? false) ? trimmedLinkedEmail : null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      await userCredential.user?.delete();
      rethrow;
    }
  }
}
