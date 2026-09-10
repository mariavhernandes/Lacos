import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message_model.dart';

class MessageService {
  MessageService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream<List<MessageModel>>.value(const <MessageModel>[]);
    }

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((document) {
        return MessageModel.fromMap(
          <String, dynamic>{...document.data(), 'id': document.id},
          userId,
        );
      }).toList();
    });
  }

  Future<void> sendMessage({
    required String chatId,
    required String text,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw StateError('É necessário estar autenticado para enviar mensagens.');
    }

    final normalizedText = text.trim();
    if (normalizedText.isEmpty) {
      return;
    }

    try {
      final chatReference = _firestore.collection('chats').doc(chatId);

      // Adiciona a mensagem com o status inicial 'sent'
      await chatReference.collection('messages').add({
        'text': normalizedText,
        'senderId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'sent',
      });

      // Atualiza os dados de preview na lista de conversas
      await chatReference.update({
        'lastMessage': normalizedText,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      throw Exception('Não foi possível enviar a mensagem: ${error.message}');
    }
  }

  /// Marca todas as mensagens enviadas pelo outro usuário nesta conversa como 'read'
  Future<void> markMessagesAsRead(String chatId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final unreadDocs = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('status', isNotEqualTo: 'read')
          .get();

      if (unreadDocs.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in unreadDocs.docs) {
        batch.update(doc.reference, {'status': 'read'});
      }
      await batch.commit();
    } catch (_) {
      // Ignora falhas em background para não interromper a UI
    }
  }
}