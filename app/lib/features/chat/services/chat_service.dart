import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat_model.dart';

class ChatService {
  ChatService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

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

        // Identifica o ID do outro usuário da conversa
        final otherUserId = participants.firstWhere(
          (id) => id != userId,
          orElse: () => '',
        );

        String name = data['participantName'] ?? 'Usuário';
        String avatar = data['participantAvatar'] ?? 'assets/avatars/avatar_1.png';

        // Tenta buscar as informações atualizadas do outro usuário no BD
        if (otherUserId.toString().isNotEmpty) {
          final userDoc = await _fetchUserProfile(otherUserId.toString());
          if (userDoc != null) {
            name = userDoc['nome'] ?? userDoc['name'] ?? name;
            avatar = userDoc['foto'] ?? userDoc['avatar'] ?? userDoc['foto_url'] ?? avatar;
          }
        }

        chats.add(
          Chat.fromMap(<String, dynamic>{
            ...data,
            'id': document.id,
            'participantId': otherUserId,
            'participantName': name,
            'participantAvatar': avatar,
          }),
        );
      }

      return chats;
    });
  }

  /// Procura o perfil do participante nas coleções 'idosos' ou 'familiares'
  Future<Map<String, dynamic>?> _fetchUserProfile(String uid) async {
    try {
      final idosoDoc = await _firestore.collection('idosos').doc(uid).get();
      if (idosoDoc.exists && idosoDoc.data() != null) {
        return idosoDoc.data();
      }

      final familiarDoc = await _firestore.collection('familiares').doc(uid).get();
      if (familiarDoc.exists && familiarDoc.data() != null) {
        return familiarDoc.data();
      }
    } catch (_) {
      // Caso ocorra erro de permissão ao ler perfil de terceiros, ignora e usa o valor salvo
    }
    return null;
  }

  Future<void> markAsRead(String chatId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'unreadMessages': 0,
      });
    } on FirebaseException catch (error) {
      throw Exception(
          'Não foi possível marcar a conversa como lida: ${error.message}');
    }
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