import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat_model.dart';
import 'message_service.dart';

class ChatService {
  ChatService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _messageService = MessageService(
          firestore: firestore,
          auth: auth,
        );

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

      // Guarda a data de atividade de cada conversa
      // para ordenar a lista depois.
      final Map<String, DateTime?> chatActivityDates = {};

      for (final document in snapshot.docs) {
        final data = document.data();

        chatActivityDates[document.id] = _getChatActivityDate(data);

        final List<dynamic> participants = data['participants'] ?? [];

        final bool isGroup = data['isGroup'] as bool? ?? false;

        if (isGroup) {
          // =========================
          // GRUPO
          // =========================

          final Map<String, dynamic> deletedFor = Map<String, dynamic>.from(
            (data['deletedFor'] as Map<String, dynamic>?) ?? {},
          );

          // Se o usuário apagou o grupo para si,
          // ele não deve mais aparecer na lista de conversas dele.
          if (deletedFor[userId] == true) {
            continue;
          }

          final groupName = data['groupName'] as String? ?? 'Grupo';

          final creatorId = data['creatorId'] as String?;

          final participantIds =
              participants.map((id) => id.toString()).toList();

          final unreadCount = await _getUnreadMessageCount(document.id);

          chats.add(
            Chat.fromMap(
              <String, dynamic>{
                ...data,
                'id': document.id,
                'isGroup': true,
                'groupName': groupName,
                'participantIds': participantIds,
                'creatorId': creatorId,
                'participantId': null,
                'participantName': null,
                'unreadMessages': unreadCount,
              },
            ),
          );
        } else {
          // =========================
          // CONVERSA PRIVADA
          // =========================

          final otherUserId = participants.firstWhere(
            (id) => id != userId,
            orElse: () => '',
          );

          String name = data['participantName'] ?? 'Usuário';

          String avatar =
              data['participantAvatar'] ?? 'assets/avatars/avatar_1.png';

          if (otherUserId.toString().isNotEmpty) {
            final userDoc = await _fetchUserProfile(
              otherUserId.toString(),
            );

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
            Chat.fromMap(
              <String, dynamic>{
                ...data,
                'id': document.id,
                'isGroup': false,
                'participantId': otherUserId,
                'participantName': name,
                'participantAvatar': avatar,
                'unreadMessages': unreadCount,
              },
            ),
          );
        }
      }

      // =========================
      // ORDENAR CONVERSAS
      // =========================
      //
      // Primeiro ficam as conversas com atividade
      // mais recente.
      //
      // Se a conversa ainda não possui mensagem,
      // usamos a data de criação.
      //
      // Assim, um grupo recém-criado aparece no topo.
      chats.sort((a, b) {
        final aDate = a.id != null ? chatActivityDates[a.id!] : null;
        final bDate = b.id != null ? chatActivityDates[b.id!] : null;

        if (aDate == null && bDate == null) {
          return 0;
        }

        if (aDate == null) {
          return 1;
        }

        if (bDate == null) {
          return -1;
        }

        return bDate.compareTo(aDate);
      });

      return chats;
    });
  }

  // ==========================================
  // DATA DE ATIVIDADE DA CONVERSA
  // ==========================================

  DateTime? _getChatActivityDate(
    Map<String, dynamic> data,
  ) {
    // Primeiro tenta usar a data da última mensagem.
    final lastMessageTime = data['lastMessageTime'];

    if (lastMessageTime is Timestamp) {
      return lastMessageTime.toDate();
    }

    if (lastMessageTime is DateTime) {
      return lastMessageTime;
    }

    if (lastMessageTime is String) {
      return DateTime.tryParse(lastMessageTime);
    }

    // Se ainda não existe mensagem,
    // usa a data de criação da conversa.
    final createdAt = data['createdAt'];

    if (createdAt is Timestamp) {
      return createdAt.toDate();
    }

    if (createdAt is DateTime) {
      return createdAt;
    }

    if (createdAt is String) {
      return DateTime.tryParse(createdAt);
    }

    return null;
  }

  // ==========================================
  // CONTAR MENSAGENS NÃO LIDAS
  // ==========================================

  Future<int> _getUnreadMessageCount(
    String chatId,
  ) async {
    try {
      final unreadCountStream = _messageService.getUnreadMessageCount(chatId);

      return await unreadCountStream.first;
    } catch (_) {
      return 0;
    }
  }

  // ==========================================
  // BUSCAR PERFIL DO USUÁRIO
  // ==========================================

  Future<Map<String, dynamic>?> _fetchUserProfile(
    String uid,
  ) async {
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

  // ==========================================
  // MARCAR CONVERSA COMO LIDA
  // ==========================================

  Future<void> markAsRead(
    String chatId,
  ) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'unreadMessages': 0,
      });
    } on FirebaseException catch (_) {}
  }

  // ==========================================
  // BLOQUEAR / DESBLOQUEAR CHAT PRIVADO
  // ==========================================

  Future<void> blockChat(
    String chatId,
  ) async {
    await _setBlocked(chatId, true);
  }

  Future<void> unblockChat(
    String chatId,
  ) async {
    await _setBlocked(chatId, false);
  }

  Future<void> _setBlocked(
    String chatId,
    bool isBlocked,
  ) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'isBlocked': isBlocked,
      });
    } on FirebaseException catch (error) {
      throw Exception(
        'Não foi possível atualizar o bloqueio da conversa: '
        '${error.message}',
      );
    }
  }

  // ==========================================
  // CRIAR GRUPO
  // ==========================================

  Future<String> createGroup({
    required String groupName,
    required List<String> participantIds,
    required String groupAvatar,
  }) async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception('Usuário não autenticado');
    }

    final uniqueParticipants = {
      ...participantIds,
      userId,
    }.toList();

    if (uniqueParticipants.length < 2) {
      throw Exception(
        'Um grupo deve ter pelo menos 2 participantes',
      );
    }

    if (groupName.trim().isEmpty) {
      throw Exception(
        'Nome do grupo não pode estar vazio',
      );
    }

    try {
      final groupDoc = await _firestore.collection('chats').add({
        'groupAvatar': groupAvatar,
        'isGroup': true,
        'groupName': groupName.trim(),
        'participants': uniqueParticipants,
        'creatorId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': null,
        'lastMessageTime': null,
        'isBlocked': false,

        // Usuários que saíram do grupo.
        'leftAt': <String, dynamic>{},

        // Usuários que apagaram o grupo somente para si.
        'deletedFor': <String, dynamic>{},
      });

      return groupDoc.id;
    } on FirebaseException catch (error) {
      throw Exception(
        'Não foi possível criar o grupo: ${error.message}',
      );
    }
  }

  // ==========================================
  // BUSCAR MEMBROS DO GRUPO
  // ==========================================

  Future<List<Map<String, dynamic>>> getGroupMembers(
    String chatId,
  ) async {
    try {
      final groupDoc = await _firestore.collection('chats').doc(chatId).get();

      if (!groupDoc.exists) {
        return [];
      }

      final data = groupDoc.data();

      if (data == null) {
        return [];
      }

      final List<dynamic> participants = data['participants'] ?? [];

      final List<Map<String, dynamic>> members = [];

      for (final participant in participants) {
        final uid = participant.toString();

        final userData = await _fetchUserProfile(uid);

        if (userData != null) {
          final name = userData['nome'] ?? userData['name'] ?? 'Usuário';

          final avatar = userData['avatarPath'] ??
              userData['foto'] ??
              userData['avatar'] ??
              userData['foto_url'] ??
              'assets/avatars/avatar_1.png';

          members.add({
            'uid': uid,
            'name': name,
            'avatar': avatar,
          });
        } else {
          members.add({
            'uid': uid,
            'name': 'Usuário',
            'avatar': 'assets/avatars/avatar_1.png',
          });
        }
      }

      return members;
    } on FirebaseException catch (error) {
      throw Exception(
        'Não foi possível carregar os membros: '
        '${error.message}',
      );
    }
  }

  // ==========================================
  // VERIFICAR SE É O CRIADOR
  // ==========================================

  Future<bool> isGroupCreator(
    String chatId,
  ) async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      return false;
    }

    try {
      final groupDoc = await _firestore.collection('chats').doc(chatId).get();

      if (!groupDoc.exists) {
        return false;
      }

      final data = groupDoc.data();

      if (data == null) {
        return false;
      }

      return data['creatorId'] == userId;
    } catch (_) {
      return false;
    }
  }

  // ==========================================
  // SAIR DO GRUPO
  // ==========================================

  Future<void> leaveGroup(
    String chatId,
  ) async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception(
        'Usuário não autenticado',
      );
    }

    try {
      final groupRef = _firestore.collection('chats').doc(chatId);

      final groupDoc = await groupRef.get();

      if (!groupDoc.exists) {
        throw Exception(
          'Grupo não encontrado.',
        );
      }

      final data = groupDoc.data();

      if (data == null) {
        throw Exception(
          'Não foi possível acessar o grupo.',
        );
      }

      final bool isGroup = data['isGroup'] as bool? ?? false;

      if (!isGroup) {
        throw Exception(
          'Esta conversa não é um grupo.',
        );
      }

      final List<String> participants = List<String>.from(
        (data['participants'] as List<dynamic>? ?? [])
            .map((participant) => participant.toString()),
      );

      if (!participants.contains(userId)) {
        return;
      }

      final Map<String, dynamic> leftAt = Map<String, dynamic>.from(
        (data['leftAt'] as Map?) ?? {},
      );

      // Registra que este usuário saiu do grupo.
      leftAt[userId] = Timestamp.now();

      // Descobre quantas pessoas ainda estão participando.
      final activeParticipants = participants
          .where(
            (participantId) => !leftAt.containsKey(participantId),
          )
          .toList();

      // Se ninguém mais estiver participando,
      // o grupo deixa de existir de verdade.
      if (activeParticipants.isEmpty) {
        await groupRef.delete();
        return;
      }

      // Mantém o grupo no Firestore e registra
      // somente a saída deste usuário.
      await groupRef.update({
        'leftAt': leftAt,
      });
    } on FirebaseException catch (error) {
      throw Exception(
        'Não foi possível sair do grupo: '
        '${error.message}',
      );
    }
  }

  // ==========================================
  // APAGAR GRUPO
  // ==========================================

  Future<void> deleteGroup(
    String chatId,
  ) async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception(
        'Usuário não autenticado',
      );
    }

    try {
      final groupRef = _firestore.collection('chats').doc(chatId);

      final groupDoc = await groupRef.get();

      if (!groupDoc.exists) {
        throw Exception(
          'Grupo não encontrado.',
        );
      }

      final data = groupDoc.data();

      if (data == null) {
        throw Exception(
          'Não foi possível acessar o grupo.',
        );
      }

      final bool isGroup = data['isGroup'] as bool? ?? false;

      if (!isGroup) {
        throw Exception(
          'Esta conversa não é um grupo.',
        );
      }

      final List<String> participants = List<String>.from(
        (data['participants'] as List<dynamic>? ?? [])
            .map((participant) => participant.toString()),
      );

      final Map<String, dynamic> deletedFor = Map<String, dynamic>.from(
        (data['deletedFor'] as Map<String, dynamic>?) ?? {},
      );

      final Map<String, dynamic> leftAt = Map<String, dynamic>.from(
        (data['leftAt'] as Map<String, dynamic>?) ?? {},
      );

      // Marca o grupo como apagado somente para este usuário.
      deletedFor[userId] = true;

      // Considera somente quem ainda está participando
      // do grupo de verdade.
      final activeParticipants = participants
          .where(
            (participantId) => !leftAt.containsKey(participantId),
          )
          .toList();

      // Se não existe mais nenhum participante ativo,
      // o grupo deixa de existir de verdade.
      if (activeParticipants.isEmpty) {
        await groupRef.delete();
        return;
      }

      // O grupo continua existindo para os outros usuários.
      // Para este usuário, ele ficará escondido da lista.
      await groupRef.update({
        'deletedFor': deletedFor,
      });
    } on FirebaseException catch (error) {
      throw Exception(
        'Não foi possível apagar o grupo: '
        '${error.message}',
      );
    }
  }
}
