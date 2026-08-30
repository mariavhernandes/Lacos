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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chats = ChatService.fakeChats();

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
        title: Text(
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

                // A lógica da pesquisa pode ser implementada aqui
                onChanged: (value) {
                  // Futuramente:
                  // filtrar as conversas conforme o texto digitado.
                },

                onSubmitted: (value) {
                  // Futuramente:
                  // executar uma pesquisa ao pressionar "buscar".
                },
              ),
            ),

            // ========================================================
            // LISTA DE CONVERSAS
            // ========================================================

            Expanded(
              child: ListView.separated(
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

                      // Marca a conversa como lida ao voltar
                      ChatService.markAsRead(chat.id!);

                      // Se a conversa foi bloqueada
                      if (blocked == true) {
                        ChatService.blockChat(chat.id!);
                      }

                      setState(() {});
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