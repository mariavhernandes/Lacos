import '../models/chat_model.dart';

/// Serviço local responsável por fornecer dados fake para a lista de conversas.
///
/// A implementação atual é apenas de apoio visual e não utiliza Firebase.
class ChatService {
  const ChatService._();

  static final List<Chat> _chats = <Chat>[
    Chat(
      id: 'chat-1',
      participantId: 'user-1',
      participantName: 'Maria Silva',
      participantAvatar: 'assets/avatars/avatar_3.png',
      lastMessage: 'Você vai participar do encontro de hoje?',
      lastMessageTime: DateTime(2026, 7, 24, 11, 59),
      unreadMessages: 0,
    ),
    Chat(
      id: 'chat-2',
      participantId: 'user-2',
      participantName: 'João Pereira',
      participantAvatar: 'assets/avatars/avatar_4.png',
      lastMessage: 'Obrigada pela ajuda com a foto.',
      lastMessageTime: DateTime(2026, 7, 24, 9, 15),
      unreadMessages: 1,
    ),
    Chat(
      id: 'chat-3',
      participantId: 'user-3',
      participantName: 'Claudio Oliveira',
      participantAvatar: 'assets/avatars/avatar_1.png',
      lastMessage: 'A sua mensagem chegou bem.',
      lastMessageTime: DateTime(2026, 7, 24, 11, 59),
      unreadMessages: 0,
    ),
  ];

  static List<Chat> fakeChats() {
    return _chats;
  }

  static void markAsRead(String chatId) {
    final index = _chats.indexWhere((chat) => chat.id == chatId);

    if (index != -1) {
      _chats[index] = _chats[index].copyWith(unreadMessages: 0);
    }
  }
}
