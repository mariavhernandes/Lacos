import 'package:cloud_firestore/cloud_firestore.dart';

class AuditService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> logAction({
    required String userId,
    required String action,
    required String context,
  }) async {
    await _firestore.collection('auditoria').add({
      'userId': userId,
      'action': action,
      'context': context,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}