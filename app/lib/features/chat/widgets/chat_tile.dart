import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/chat_model.dart';

/// Widget responsável por exibir uma conversa privada na lista com dados sincronizados do Firestore.
class ChatTile extends StatelessWidget {
  const ChatTile({super.key, required this.chat, required this.onTap});

  final Chat chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final participantId = chat.participantId;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('idosos')
          .doc(participantId)
          .snapshots(),
      builder: (context, idosoSnapshot) {
        Map<String, dynamic>? userData;
        if (idosoSnapshot.hasData && idosoSnapshot.data!.exists) {
          userData = idosoSnapshot.data!.data() as Map<String, dynamic>?;
        }

        if (userData == null) {
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('familiares')
                .doc(participantId)
                .snapshots(),
            builder: (context, familiarSnapshot) {
              if (familiarSnapshot.hasData && familiarSnapshot.data!.exists) {
                userData = familiarSnapshot.data!.data() as Map<String, dynamic>?;
              }
              return _buildTileContent(context, userData);
            },
          );
        }

        return _buildTileContent(context, userData);
      },
    );
  }

  Widget _buildTileContent(BuildContext context, Map<String, dynamic>? userData) {
    final String name = userData?['name'] ??
        userData?['nome'] ??
        chat.participantName ??
        'Participante';

    final String? avatarPath = userData?['avatarPath'] ??
        userData?['foto'] ??
        userData?['avatar'] ??
        chat.participantAvatar;

    return Material(
      color: AppColors.background,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar dinâmico
              SizedBox(
                width: 56,
                height: 56,
                child: _buildAvatar(avatarPath),
              ),
              const SizedBox(width: 16),

              // Informações da conversa
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome do Participante
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Colors.black,
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
              const SizedBox(width: 12),

              // Horário e Badge de mensagens não lidas
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (chat.lastMessageTime != null)
                    Text(
                      _formatTime(chat.lastMessageTime!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
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
                      decoration: const BoxDecoration(
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

  Widget _buildAvatar(String? avatarPath) {
    final hasAvatar = (avatarPath ?? '').trim().isNotEmpty;

    if (hasAvatar) {
      return ClipOval(
        child: avatarPath!.startsWith('assets/')
            ? Image.asset(
                avatarPath,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              )
            : Image.network(
                avatarPath,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
              ),
      );
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return const CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.secondary,
      child: Icon(Icons.person, color: AppColors.primary, size: 28),
    );
  }

  String _formatTime(DateTime dateTime) {
    final time = dateTime.toLocal();
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}