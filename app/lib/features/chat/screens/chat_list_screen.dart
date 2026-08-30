import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../services/chat_service.dart';
import '../widgets/chat_tile.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import '../screens/chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    final chats = ChatService.fakeChats();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: Text(
          'Conversas',
          style: TextStyle(
            color: Colors.grey[600], // Cor cinza igual à do horário
            fontWeight: FontWeight.w600,
            fontSize: 22,
            fontFamily: 'Raleway', // Garante a fonte Raleway no título
          ),
        ),
      ),

      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 2,
        onTap: (_) {},
        items: [
          BottomNavItem(
            icon: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/icons/icons_footer/footer_home_icon.png',
                width: 24,
                height: 24,
              ),
            ),
            activeIcon: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/icons/icons_footer/footer_home_icon.png',
                width: 24,
                height: 24,
              ),
            ),
            label: 'Início',
          ),
          BottomNavItem(
            icon: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/icons/icons_footer/footer_location_icon.png',
                width: 24,
                height: 24,
              ),
            ),
            activeIcon: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/icons/icons_footer/footer_location_icon.png',
                width: 24,
                height: 24,
              ),
            ),
            label: 'Lugares',
          ),
          BottomNavItem(
            icon: ColorFiltered(
              colorFilter: ColorFilter.mode(
                AppColors.textSecondary,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/icons/icons_footer/footer_chat_icon.png',
                width: 24,
                height: 24,
              ),
            ),
            activeIcon: ColorFiltered(
              colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
              child: Image.asset(
                'assets/icons/icons_footer/footer_chat_icon.png',
                width: 24,
                height: 24,
              ),
            ),
            label: 'Conversas',
          ),
          BottomNavItem(
            icon: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/icons/icons_footer/footer_profile_icon.png',
                width: 24,
                height: 24,
              ),
            ),
            activeIcon: ColorFiltered(
              colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
              child: Image.asset(
                'assets/icons/icons_footer/footer_profile_icon.png',
                width: 24,
                height: 24,
              ),
            ),
            label: 'Perfil',
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  cursorColor: const Color(0xFF8A8A8A),
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Quicksand',
                    color: Color(0xFF8A8A8A),
                  ),
                  decoration: InputDecoration(
                    // AQUI ESTÁ A MUDANÇA DO TEXTO "Pesquisar conversas"
                    hintStyle: TextStyle(
                      color: Colors
                          .grey[600], // Cor cinza (igual do horário/título)
                      fontSize: 14,
                      fontFamily: 'Raleway',
                    ),
                    hintText: 'Pesquisar conversas',
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: chats.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  thickness: 0.8,
                  color: Color(0xFFE5E5E5),
                ),

                itemBuilder: (context, index) {
                  return ChatTile(
                    chat: chats[index],
                    onTap: () async {
                      final blocked = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(chat: chats[index]),
                        ),
                      );

                      // Marca a conversa como lida ao voltar do chat
                      ChatService.markAsRead(chats[index].id!);

                      if (blocked == true) {
                        ChatService.blockChat(chats[index].id!);
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
