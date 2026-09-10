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

  /// Retorna um Stream com a contagem de mensagens não lidas para o usuário atual.
  ///
  /// Uma mensagem é considerada não lida se:
  /// - Não foi enviada pelo usuário atual (senderId != userId)
  /// - Ainda não foi marcada como 'read' (status != 'read')
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

        // Conta apenas mensagens recebidas que não foram lidas
        if (senderId != userId && status != 'read') {
          unreadCount++;
        }
      }
      return unreadCount;
    });
  }

  /// Monitora novas mensagens para uma conversa específica e dispara notificações.
  ///
  /// Esta função deve ser chamada uma vez por conversa para monitorar mensagens novas.
  /// Dispara notificações apenas se:
  /// - A mensagem foi recebida (não enviada pelo usuário atual)
  /// - A conversa não está aberta (_isChatScreenActive = false)
  /// - A mensagem ainda não está marcada como lida
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

      // Dispara notificação apenas se:
      // 1. A mensagem foi recebida (senderId != userId)
      // 2. Ainda não foi lida (status != 'read')
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
