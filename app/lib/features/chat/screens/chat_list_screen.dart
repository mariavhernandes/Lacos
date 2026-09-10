import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_footer.dart';
import '../../../core/widgets/custom_search_bar.dart';

import '../services/chat_service.dart';
import '../services/notification_service.dart';
import '../services/message_service.dart';
import '../widgets/chat_tile.dart';
import '../screens/chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ChatService _chatService = ChatService();
  final MessageService _messageService = MessageService();
  final NotificationService _notificationService = NotificationService();
  final Set<String> _initializedChats = {};

  @override
  void initState() {
    super.initState();
    
    // Registra callback para receber notificações de novas mensagens
    _notificationService.onNotificationRequired(_showMessageNotification);
  }

  @override
  void dispose() {
    _searchController.dispose();
    
    // Remove callback de notificações
    _notificationService.removeNotificationCallback(_showMessageNotification);
    
    super.dispose();
  }

  /// Exibe uma notificação de nova mensagem usando SnackBar.
  void _showMessageNotification(String message, String senderName) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mensagem de $senderName',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Quicksand',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Quicksand',
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Inicializa listeners de notificações para cada conversa.
  /// 
  /// Este método garante que o listener é iniciado apenas uma vez por conversa.
  void _initializeNotificationListeners(List<dynamic> chats) {
    for (final chat in chats) {
      final chatId = chat.id as String?;
      final participantName = chat.participantName as String? ?? 'Desconhecido';
      final participantId = chat.participantId as String?;

      if (chatId != null && participantId != null && !_initializedChats.contains(chatId)) {
        _messageService.startListeningForNotifications(
          chatId,
          participantName,
          participantId,
        );
        _initializedChats.add(chatId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: const Text(
          'Conversas',
          style: TextStyle(
            color: Color(0xFF555555),
            fontWeight: FontWeight.bold,
            fontSize: 17,
            fontFamily: 'Quicksand',
          ),
        ),
      ),

      // ============================================================
      // RODAPÉ PADRÃO DO APP
      // ============================================================

      bottomNavigationBar: const CustomFooter(
        currentIndex: 2,
      ),

      // ============================================================
      // CONTEÚDO
      // ============================================================

      body: SafeArea(
        child: Column(
          children: [
            // ========================================================
            // BARRA DE PESQUISA PADRÃO
            // ========================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: CustomSearchBar(
                hintText: 'Pesquisar conversas',
                controller: _searchController,
                onChanged: (value) {},
                onSubmitted: (value) {},
              ),
            ),

            // ========================================================
            // LISTA DE CONVERSAS
            // ========================================================

            Expanded(
              child: StreamBuilder(
                stream: _chatService.getChatsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Erro ao carregar chats:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontFamily: 'Quicksand',
                          ),
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final chats = snapshot.data!;

                  if (chats.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhuma conversa encontrada.',
                        style: TextStyle(
                          color: Color(0xFF8A8A8A),
                          fontSize: 15,
                          fontFamily: 'Quicksand',
                        ),
                      ),
                    );
                  }

                  // Inicializa listeners de notificações para cada conversa
                  _initializeNotificationListeners(chats);

                  return ListView.separated(
                    itemCount: chats.length,
                    separatorBuilder: (context, index) {
                      return const Divider(
                        height: 1,
                        thickness: 0.8,
                        color: Color(0xFFE5E5E5),
                      );
                    },
                    itemBuilder: (context, index) {
                      final chat = chats[index];

                      return ChatTile(
                        chat: chat,
                        onTap: () async {
                          final blocked = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                chat: chat,
                              ),
                            ),
                          );

                          if (chat.id == null) {
                            return;
                          }

                          try {
                            await _chatService.markAsRead(chat.id!);
                            if (blocked == true) {
                              await _chatService.blockChat(chat.id!);
                            }
                          } catch (error) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error.toString())),
                              );
                            }
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}