import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Representa uma conversa privada entre dois participantes ou um grupo de participantes.
///
/// Para conversas privadas:
/// - [isGroup] é false
/// - [participantId] contém o ID do outro participante
/// - [participantName] contém o nome do outro participante
/// - [participantIds] é null
///
/// Para grupos:
/// - [isGroup] é true
/// - [groupName] contém o nome do grupo
/// - [groupAvatar] contém o caminho da foto do grupo
/// - [participantIds] contém todos os IDs dos participantes
/// - [creatorId] contém o ID de quem criou o grupo
/// - [participantId] e [participantName] são null
@immutable
class Chat {
  const Chat({
    this.id,
    this.participantId,
    this.participantName,
    this.participantAvatar,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadMessages = 0,
    this.isBlocked = false,
    this.isGroup = false,
    this.groupName,
    this.groupAvatar,
    this.participantIds,
    this.creatorId,
  });

  /// Identificador único da conversa.
  final String? id;

  /// Identificador do participante da conversa (apenas conversas privadas).
  final String? participantId;

  /// Nome exibido do participante (apenas conversas privadas).
  final String? participantName;

  /// URL, caminho ou identificador do avatar do participante.
  final String? participantAvatar;

  /// Última mensagem da conversa.
  final String? lastMessage;

  /// Horário da última mensagem.
  final DateTime? lastMessageTime;

  /// Quantidade de mensagens não lidas.
  final int unreadMessages;

  /// Indica se o usuário foi bloqueado.
  final bool isBlocked;

  /// Indica se esta é uma conversa de grupo.
  final bool isGroup;

  /// Nome do grupo (apenas para grupos).
  final String? groupName;

  /// Caminho ou URL da foto do grupo (apenas para grupos).
  final String? groupAvatar;

  /// Lista de IDs de todos os participantes (apenas para grupos).
  final List<String>? participantIds;

  /// ID de quem criou o grupo (apenas para grupos).
  final String? creatorId;

  /// Cria uma nova instância de [Chat] substituindo apenas os campos informados.
  Chat copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? participantAvatar,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadMessages,
    bool? isBlocked,
    bool? isGroup,
    String? groupName,
    String? groupAvatar,
    List<String>? participantIds,
    String? creatorId,
  }) {
    return Chat(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantAvatar: participantAvatar ?? this.participantAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      isBlocked: isBlocked ?? this.isBlocked,
      isGroup: isGroup ?? this.isGroup,
      groupName: groupName ?? this.groupName,
      groupAvatar: groupAvatar ?? this.groupAvatar,
      participantIds: participantIds ?? this.participantIds,
      creatorId: creatorId ?? this.creatorId,
    );
  }

  /// Converte o modelo em um mapa compatível com armazenamento local ou Firestore.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'participantId': participantId,
      'participantName': participantName,
      'participantAvatar': participantAvatar,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadMessages': unreadMessages,
      'isBlocked': isBlocked,
      'isGroup': isGroup,
      'groupName': groupName,
      'groupAvatar': groupAvatar,
      'participantIds': participantIds,
      'creatorId': creatorId,
    };
  }

  /// Cria uma instância de [Chat] a partir de um mapa.
  factory Chat.fromMap(Map<String, dynamic> map, {String? docId}) {
    // Procura o nome do participante ou grupo entre diversos campos possíveis
    final name = map['groupName'] ??
        map['participantName'] ??
        map['name'] ??
        map['otherUserName'] ??
        map['userName'] ??
        map['senderName'];

    return Chat(
      id: docId ?? map['id'] as String?,
      participantId: map['participantId'] as String?,
      participantName: name?.toString(),
      participantAvatar: (map['participantAvatar'] ??
              map['avatar'] ??
              map['userPhoto'] ??
              map['photoUrl'])
          ?.toString(),
      lastMessage: map['lastMessage'] as String?,
      lastMessageTime: _parseDateTime(map['lastMessageTime'] ?? map['timestamp']),
      unreadMessages: _parseInt(map['unreadMessages'] ?? map['unreadCount']),
      isBlocked: map['isBlocked'] as bool? ?? false,
      isGroup: map['isGroup'] as bool? ?? false,
      groupName: map['groupName'] as String?,
      groupAvatar: map['groupAvatar'] as String?,
      participantIds: _parseParticipantIds(map['participantIds']),
      creatorId: map['creatorId'] as String?,
    );
  }

  /// Converte um QueryDocumentSnapshot ou DocumentSnapshot em um Chat.
  factory Chat.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Chat.fromMap(data, docId: doc.id);
  }

  /// Serializa o modelo em string JSON.
  String toJson() => jsonEncode(toMap());

  /// Cria uma instância de [Chat] a partir de uma string JSON.
  factory Chat.fromJson(String source) {
    final decoded = jsonDecode(source) as Map<String, dynamic>;
    return Chat.fromMap(decoded);
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  static List<String>? _parseParticipantIds(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is List) {
      return value.cast<String>();
    }

    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Chat &&
        other.id == id &&
        other.participantId == participantId &&
        other.participantName == participantName &&
        other.participantAvatar == participantAvatar &&
        other.lastMessage == lastMessage &&
        other.lastMessageTime == lastMessageTime &&
        other.unreadMessages == unreadMessages &&
        other.isBlocked == isBlocked &&
        other.isGroup == isGroup &&
        other.groupName == groupName &&
        other.groupAvatar == groupAvatar &&
        other.creatorId == creatorId &&
        _listEquals(other.participantIds, participantIds);
  }

  static bool _listEquals(List<String>? a, List<String>? b) {
    if (identical(a, b)) {
      return true;
    }

    if (a == null || b == null) {
      return a == b;
    }

    if (a.length != b.length) {
      return false;
    }

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }

    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      participantId,
      participantName,
      participantAvatar,
      lastMessage,
      lastMessageTime,
      unreadMessages,
      isBlocked,
      isGroup,
      groupName,
      groupAvatar,
      creatorId,
      participantIds,
    );
  }
}