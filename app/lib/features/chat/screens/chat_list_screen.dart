import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_footer.dart';
import '../../../core/widgets/custom_search_bar.dart';

import '../services/chat_service.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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