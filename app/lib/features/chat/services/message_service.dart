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

      await chatReference.collection('messages').add({
        'text': normalizedText,
        'senderId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'sent',
      });

      await chatReference.update({
        'lastMessage': normalizedText,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      throw Exception('Não foi possível enviar a mensagem: ${error.message}');
    }
  }

    Future<void> markMessagesAsRead(String chatId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final snapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      bool hasUpdates = false;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        // Atualiza para 'read' as mensagens que vieram de VOCÊ (O6xd...)
        if (data['senderId'] != userId && data['status'] != 'read') {
          batch.update(doc.reference, {'status': 'read'});
          hasUpdates = true;
        }
      }

      if (hasUpdates) {
        await batch.commit();
      }
    } catch (e) {
      print('Erro ao marcar mensagens como lidas: $e');
    }
  }
}