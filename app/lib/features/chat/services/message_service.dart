import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message_model.dart';
import 'notification_service.dart';

class MessageService {
  MessageService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Retorna as mensagens de um chat.
  /// Se [targetUserId] for informado (ex: idoso monitorado), ele é usado
  /// para calcular o `isCurrentUser` das mensagens do modelo.
  Stream<List<MessageModel>> getMessagesStream(
    String chatId, {
    String? targetUserId,
  }) {
    final effectiveUserId = targetUserId ?? _auth.currentUser?.uid;

    if (effectiveUserId == null) {
      return Stream<List<MessageModel>>.value(const <MessageModel>[]);
    }

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((document) {
        return MessageModel.fromMap(
          <String, dynamic>{...document.data(), 'id': document.id},
          effectiveUserId,
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

  Stream<int> getUnreadMessageCount(String chatId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream<int>.value(0);
    }

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .snapshots()
        .map((snapshot) {
      int unreadCount = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final senderId = data['senderId'] as String? ?? '';
        final status = data['status'] as String? ?? 'sent';

        if (senderId != userId && status != 'read') {
          unreadCount++;
        }
      }
      return unreadCount;
    });
  }

  void startListeningForNotifications(
    String chatId,
    String participantName,
    String participantId,
  ) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty) return;

      final doc = snapshot.docs.first;
      final data = doc.data();
      final senderId = data['senderId'] as String? ?? '';
      final messageText = data['text'] as String? ?? '';
      final status = data['status'] as String? ?? 'sent';

      if (senderId != userId && status != 'read' && messageText.isNotEmpty) {
        NotificationService().notifyIfNeeded(
          chatId: chatId,
          message: messageText,
          senderName: participantName,
          senderId: senderId,
          currentUserId: userId,
        );
      }
    });
  }
}