import '../models/message_model.dart';

/// Serviço local responsável por fornecer mensagens mockadas para cada conversa.
class MessageService {
  const MessageService._();

  static List<MessageModel> getMessages(String chatId) {
    switch (chatId) {
      case 'chat-1':
        return const [
          MessageModel(
            id: 'm1',
            text: 'Oi Maria! Tudo bem?',
            time: '10:50',
            isCurrentUser: true,
          ),
          MessageModel(
            id: 'm2',
            text: 'Oi! Tudo sim 😊',
            time: '10:54',
            isCurrentUser: false,
          ),
          MessageModel(
            id: 'm3',
            text: 'Hoje teremos um encontro no parque às 16h.',
            time: '11:40',
            isCurrentUser: false,
          ),
          MessageModel(
            id: 'm4',
            text: 'Vai ser muito legal rever o pessoal!',
            time: '11:50',
            isCurrentUser: false,
          ),
          MessageModel(
            id: 'm5',
            text: 'Você vai participar do encontro de hoje?',
            time: '11:59',
            isCurrentUser: false,
          ),
        ];
      case 'chat-2':
        return const [
          MessageModel(
            id: 'm1',
            text: 'Conseguiu alterar a foto do perfil?',
            time: '09:05',
            isCurrentUser: true,
          ),
          MessageModel(
            id: 'm2',
            text: 'Sim! Ficou perfeita.',
            time: '09:10',
            isCurrentUser: false,
          ),
          MessageModel(
            id: 'm3',
            text: 'Obrigada pela ajuda com a foto.',
            time: '09:15',
            isCurrentUser: false,
          ),
        ];
      case 'chat-3':
        return const [
          MessageModel(
            id: 'm1',
            text: 'Conseguiu receber a imagem?',
            time: '11:55',
            isCurrentUser: true,
          ),
          MessageModel(
            id: 'm2',
            text: 'A sua mensagem chegou bem.',
            time: '11:59',
            isCurrentUser: false,
          ),
          MessageModel(
            id: 'm3',
            text: 'Perfeito! Qualquer coisa me avise.',
            time: '12:01',
            isCurrentUser: true,
          ),
        ];
      default:
        return const [];
    }
  }
}
