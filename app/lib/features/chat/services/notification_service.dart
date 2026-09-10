/// Serviço responsável por gerenciar notificações de novas mensagens no chat.
/// 
/// Rastreia qual conversa está aberta e dispara notificações apenas quando apropriado.
class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();

  factory NotificationService() {
    return _instance;
  }

  /// Rastreia qual conversa está aberta no momento (ID do chat).
  /// Null = nenhuma conversa aberta.
  String? _activeChatId;

  /// Callbacks para disparar notificações.
  final List<Function(String message, String senderName)> _notificationCallbacks =
      [];

  /// Define qual conversa está ativa (quando o usuário abre o ChatScreen).
  void setActiveChatId(String chatId) {
    _activeChatId = chatId;
  }

  /// Remove a conversa ativa (quando o usuário fecha o ChatScreen).
  void clearActiveChatId() {
    _activeChatId = null;
  }

  /// Retorna se a conversa com o ID fornecido está ativa.
  bool isChatActive(String chatId) {
    return _activeChatId == chatId;
  }

  /// Registra um callback para disparar notificações.
  /// 
  /// O callback será chamado quando:
  /// - Uma nova mensagem chegar
  /// - A conversa NÃO está aberta
  /// - A mensagem NÃO foi enviada pelo próprio usuário
  void onNotificationRequired(
    Function(String message, String senderName) callback,
  ) {
    _notificationCallbacks.add(callback);
  }

  /// Remove um callback de notificação.
  void removeNotificationCallback(
    Function(String message, String senderName) callback,
  ) {
    _notificationCallbacks.remove(callback);
  }

  /// Dispara uma notificação se apropriado.
  /// 
  /// [chatId] = ID da conversa onde a mensagem chegou
  /// [message] = Conteúdo da mensagem
  /// [senderName] = Nome de quem enviou a mensagem
  /// [senderId] = UID de quem enviou
  /// [currentUserId] = UID do usuário atual
  void notifyIfNeeded({
    required String chatId,
    required String message,
    required String senderName,
    required String senderId,
    required String currentUserId,
  }) {
    // Não notifica o próprio remetente
    if (senderId == currentUserId) {
      return;
    }

    // Não notifica se a conversa está aberta
    if (isChatActive(chatId)) {
      return;
    }

    // Dispara a notificação
    for (final callback in _notificationCallbacks) {
      callback(message, senderName);
    }
  }
}
