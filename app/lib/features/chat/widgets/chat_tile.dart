import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/chat_model.dart';

/// Widget responsável por exibir uma conversa privada na lista.
class ChatTile extends StatelessWidget {
  const ChatTile({super.key, required this.chat, required this.onTap});

  final Chat chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasCustomAvatar = (chat.participantAvatar ?? '').trim().isNotEmpty;

    return Material(
      color: AppColors.background,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              SizedBox(
                width: 56,
                height: 56,
                child: hasCustomAvatar
                    ? ClipOval(
                        child: Image.asset(
                          chat.participantAvatar!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ),
                      )
                    : _buildDefaultAvatar(),
              ),
              const SizedBox(width: 16),
              // Informações da conversa
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome e Horário
                    Text(
                      chat.participantName ?? 'Participante',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Ralewawy',
                        fontWeight:
                            FontWeight.w500, // Peso mais leve que o w700
                        fontSize: 18, // Tamanho levemente aumentado
                        color: Color.fromARGB(
                          255,
                          0,
                          0,
                          0,
                        ), // Ou a cor do título "Conversas" / AppColors.primary
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Última mensagem
                    Text(
                      chat.isBlocked
                          ? 'Você bloqueou esta pessoa.'
                          : (chat.lastMessage ?? 'Sem mensagens ainda'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: chat.isBlocked
                            ? const Color(0xFF8A8A8A)
                            : Colors.black87,
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge de mensagens não lidas
              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (chat.lastMessageTime != null)
                    Text(
                      _formatTime(chat.lastMessageTime!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600], // Cor cinza ajustada
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                  if (chat.unreadMessages > 0) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${chat.unreadMessages}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Quicksand',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return CircleAvatar(
      radius: 26,
      backgroundColor: AppColors.secondary,
      child: const Icon(Icons.person, color: AppColors.primary, size: 24),
    );
  }

  String _formatTime(DateTime dateTime) {
    final time = dateTime.toLocal();
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
