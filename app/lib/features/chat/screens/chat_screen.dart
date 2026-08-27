import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/chat_model.dart';
import '../services/message_service.dart';
import '../widgets/message_bubble.dart';
import 'conversation_info_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.chat});

  final Chat chat;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isBlocked = false;
  bool isSearching = false;

  final TextEditingController _searchController = TextEditingController();

  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    isBlocked = widget.chat.isBlocked;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // BARRA DE PESQUISA
  // ============================================================

  Widget _buildSearchBar() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              isSearching = false;
              searchQuery = '';
              _searchController.clear();
            });
          },
          icon: Image.asset(
            'assets/icons/navigation/back_icon.png',
            width: 20,
            height: 20,
          ),
          color: AppColors.textPrimary,
          splashRadius: 24,
          tooltip: 'Voltar',
        ),

        const SizedBox(width: 4),

        Expanded(
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            cursorColor: const Color(0xFF8A8A8A),
            style: const TextStyle(
              color: Color(0xFF8A8A8A),
              fontSize: 15,
              fontFamily: 'Quicksand',
            ),
            decoration: InputDecoration(
              hintText: 'Pesquisar mensagens...',
              hintStyle: const TextStyle(
                color: Color(0xFF8A8A8A),
                fontSize: 15,
                fontFamily: 'Quicksand',
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
                size: 21,
              ),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();

                        setState(() {
                          searchQuery = '';
                        });
                      },
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFEAEAEA),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),
      ],
    );
  }

  // ============================================================
  // APP BAR NORMAL
  // ============================================================

  Widget _buildNormalAppBar() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset(
            'assets/icons/navigation/back_icon.png',
            width: 20,
            height: 20,
          ),
          color: AppColors.textPrimary,
          splashRadius: 24,
          tooltip: 'Voltar',
        ),

        const SizedBox(width: 12),

        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final result = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (_) => ConversationInfoScreen(chat: widget.chat),
                ),
              );

              if (!mounted) {
                return;
              }

              if (result == 'blocked') {
                setState(() {
                  isBlocked = true;
                });
              } else if (result == 'unblocked') {
                setState(() {
                  isBlocked = false;
                });
              } else if (result == 'search') {
                setState(() {
                  isSearching = true;
                  searchQuery = '';
                  _searchController.clear();
                });
              }
            },
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    widget.chat.participantAvatar!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(width: 12),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.chat.participantName ?? 'Participante',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Raleway',
                      ),
                    ),

                    const SizedBox(height: 2),

                    const Text(
                      'Online',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final messages = MessageService.getMessages(widget.chat.id!);

    final filteredMessages = messages.where((message) {
      if (searchQuery.trim().isEmpty) {
        return true;
      }

      return message.text.toLowerCase().contains(
        searchQuery.trim().toLowerCase(),
      );
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 0,

        title: isSearching ? _buildSearchBar() : _buildNormalAppBar(),
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SafeArea(
        child: Column(
          children: [
            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E5E5)),

            // ==================================================
            // MENSAGENS
            // ==================================================
            Expanded(
              child: Column(
                children: [
                  // --------------------------------------------
                  // AVISO DE BLOQUEIO
                  // --------------------------------------------
                  if (isBlocked)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Você bloqueou esta pessoa.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF8A8A8A),
                          fontSize: 14,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  // --------------------------------------------
                  // LISTA DE MENSAGENS
                  // --------------------------------------------
                  Expanded(
                    child: filteredMessages.isEmpty
                        ? Center(
                            child: Text(
                              searchQuery.trim().isNotEmpty
                                  ? 'Nenhuma mensagem encontrada.'
                                  : 'Nenhuma mensagem.',
                              style: const TextStyle(
                                color: Color(0xFF8A8A8A),
                                fontSize: 14,
                                fontFamily: 'Quicksand',
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                            itemCount: filteredMessages.length,
                            itemBuilder: (context, index) {
                              final message = filteredMessages[index];

                              return Row(
                                mainAxisAlignment: message.isCurrentUser
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: MessageBubble(
                                      text: message.text,
                                      time: message.time,
                                      isCurrentUser: message.isCurrentUser,
                                    ),
                                  ),
                                ],
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                          ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // CAMPO DE MENSAGEM
            // ==================================================
            Container(
              color: AppColors.background,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      enabled: !isBlocked,
                      cursorColor: const Color(0xFF8A8A8A),

                      style: const TextStyle(
                        color: Color(0xFF8A8A8A),
                        fontSize: 14,
                        fontFamily: 'Quicksand',
                      ),
                      decoration: InputDecoration(
                        hintText: isBlocked
                            ? 'Você bloqueou esta pessoa'
                            : 'Digite sua mensagem...',
                        hintStyle: const TextStyle(
                          color: Color(0xFFB8B8B8),
                          fontSize: 15,
                          fontFamily: 'Quicksand',
                        ),
                        filled: true,
                        fillColor: const Color(0xFFEAEAEA),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ==================================================
                  // BOTÃO ENVIAR
                  // ==================================================
                  GestureDetector(
                    onTap: isBlocked
                        ? null
                        : () {
                            // Implementação futura.
                          },
                    child: Opacity(
                      opacity: isBlocked ? 0.4 : 1.0,
                      child: Image.asset(
                        'assets/images/elderly/send.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
