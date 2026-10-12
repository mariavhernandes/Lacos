import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isCurrentUser;
  final String status;

  // Usados nas mensagens recebidas em grupos.
  final String? senderName;
  final String? senderAvatar;

  const MessageBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isCurrentUser,
    this.status = 'sent',
    this.senderName,
    this.senderAvatar,
  });

  bool get _showGroupSender => !isCurrentUser && senderName != null;

  Widget _buildStatusIcon() {
    if (!isCurrentUser) {
      return const SizedBox.shrink();
    }

    final Color color =
        status == 'read' ? const Color(0xFF0288D1) : const Color(0xFF8A8A8A);

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Icon(
        Icons.done_all,
        size: 15,
        color: color,
      ),
    );
  }

  Widget _buildAvatar() {
    final avatar = senderAvatar?.trim().isNotEmpty == true
        ? senderAvatar!.trim()
        : 'assets/avatars/avatar_1.png';

    final Widget image = avatar.startsWith('assets/')
        ? Image.asset(
            avatar,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/avatars/avatar_1.png',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          )
        : Image.network(
            avatar,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/avatars/avatar_1.png',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          );

    return ClipOval(
      child: SizedBox(
        width: 32,
        height: 32,
        child: image,
      ),
    );
  }

  Widget _buildBubble(BuildContext context) {
    final backgroundColor =
        isCurrentUser ? AppColors.card : const Color(0xFFCFDBEF);

    final borderRadius = isCurrentUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    return Container(
      constraints: BoxConstraints(
        // Reserva espaço para a foto fora do balão no grupo.
        maxWidth: MediaQuery.of(context).size.width *
            (_showGroupSender ? 0.68 : 0.75),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // O nome fica dentro do balão, acima da mensagem.
          if (_showGroupSender) ...[
            Text(
              senderName?.trim().isNotEmpty == true
                  ? senderName!.trim()
                  : 'Usuário',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
          ],

          Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  color: Color(0xFF8A8A8A),
                  fontSize: 12,
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w400,
                ),
              ),
              _buildStatusIcon(),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: _showGroupSender
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Foto fora do balão, como no WhatsApp.
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: _buildAvatar(),
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: _buildBubble(context),
                ),
              ],
            )
          : _buildBubble(context),
    );
  }
}
