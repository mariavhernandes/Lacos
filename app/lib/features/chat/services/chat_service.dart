import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat_model.dart';
import 'message_service.dart';

class ChatService {
  ChatService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _messageService = MessageService(firestore: firestore, auth: auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final MessageService _messageService;

  Stream<List<Chat>> getChatsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream<List<Chat>>.value(const <Chat>[]);
    }

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<Chat> chats = [];

      for (final document in snapshot.docs) {
        final data = document.data();
        final List<dynamic> participants = data['participants'] ?? [];

        final otherUserId = participants.firstWhere(
          (id) => id != userId,
          orElse: () => '',
        );

        String name = data['participantName'] ?? 'Usuário';
        String avatar =
            data['participantAvatar'] ?? 'assets/avatars/avatar_1.png';

        if (otherUserId.toString().isNotEmpty) {
          final userDoc = await _fetchUserProfile(otherUserId.toString());
          if (userDoc != null) {
            name = userDoc['nome'] ?? userDoc['name'] ?? name;
            avatar = userDoc['foto'] ??
                userDoc['avatar'] ??
                userDoc['foto_url'] ??
                avatar;
          }
        }

        final unreadCount = await _getUnreadMessageCount(document.id);

        chats.add(
          Chat.fromMap(<String, dynamic>{
            ...data,
            'id': document.id,
            'participantId': otherUserId,
            'participantName': name,
            'participantAvatar': avatar,
            'unreadMessages': unreadCount,
          }),
        );
      }

      return chats;
    });
  }

  Future<int> _getUnreadMessageCount(String chatId) async {
    try {
      final unreadCountStream = _messageService.getUnreadMessageCount(chatId);
      return await unreadCountStream.first;
    } catch (_) {
      return 0;
    }
  }

  Future<Map<String, dynamic>?> _fetchUserProfile(String uid) async {
    try {
      final idosoDoc = await _firestore.collection('idosos').doc(uid).get();
      if (idosoDoc.exists && idosoDoc.data() != null) {
        return idosoDoc.data();
      }

      final familiarDoc =
          await _firestore.collection('familiares').doc(uid).get();
      if (familiarDoc.exists && familiarDoc.data() != null) {
        return familiarDoc.data();
      }
    } catch (_) {}
    return null;
  }

  Future<void> markAsRead(String chatId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'unreadMessages': 0,
      });
    } on FirebaseException catch (_) {}
  }

  Future<void> blockChat(String chatId) async {
    await _setBlocked(chatId, true);
  }

  Future<void> unblockChat(String chatId) async {
    await _setBlocked(chatId, false);
  }

  Future<void> _setBlocked(String chatId, bool isBlocked) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'isBlocked': isBlocked,
      });
    } on FirebaseException catch (error) {
      throw Exception(
          'Não foi possível atualizar o bloqueio da conversa: ${error.message}');
    }
  }
}