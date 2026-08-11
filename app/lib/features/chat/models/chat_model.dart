import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Representa uma conversa privada entre dois participantes.
///
/// O modelo é imutável para facilitar o uso em widgets, estados e
/// futuras integrações com Firebase Firestore.
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
  });

  /// Identificador único da conversa.
  final String? id;

  /// Identificador do participante da conversa.
  final String? participantId;

  /// Nome exibido do participante.
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

  /// Cria uma nova instância de [Chat] substituindo apenas os campos informados.
  Chat copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? participantAvatar,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadMessages,
  }) {
    return Chat(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantAvatar: participantAvatar ?? this.participantAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadMessages: unreadMessages ?? this.unreadMessages,
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
    };
  }

  /// Cria uma instância de [Chat] a partir de um mapa.
  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] as String?,
      participantId: map['participantId'] as String?,
      participantName: map['participantName'] as String?,
      participantAvatar: map['participantAvatar'] as String?,
      lastMessage: map['lastMessage'] as String?,
      lastMessageTime: _parseDateTime(map['lastMessageTime']),
      unreadMessages: _parseInt(map['unreadMessages']),
    );
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
        other.unreadMessages == unreadMessages;
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
    );
  }
}
