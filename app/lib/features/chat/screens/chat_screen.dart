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

  @override
  Widget build(BuildContext context) {
    final messages = MessageService.getMessages(widget.chat.id!);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.maybePop(context),
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
                  final blocked = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConversationInfoScreen(chat: widget.chat),
                    ),
                  );

                  if (blocked == true) {
                    print('BLOQUEIO RECEBIDO!');

                    setState(() {
                      isBlocked = true;
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
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E5E5)),

            Expanded(
              child: isBlocked
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Você bloqueou esta pessoa.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF8A8A8A),
                            fontSize: 14,
                            fontFamily: 'Quicksand',
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];

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
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                    ),
            ),
            Container(
              color: AppColors.background,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      cursorColor: AppColors.textPrimary,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Digite sua mensagem...',
                        hintStyle: const TextStyle(
                          color: Color(0xFFB8B8B8),
                          fontSize: 15,
                          fontFamily: 'Quicksand',
                        ),
                        filled: true,
                        fillColor: Color(0xFFEAEAEA),
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
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  GestureDetector(
                    onTap: () {
                      // Implementação futura
                    },
                    child: Image.asset(
                      'assets/images/elderly/send.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
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
