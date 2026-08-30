import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Widget reutilizável responsável por exibir uma mensagem da conversa.
class MessageBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isCurrentUser;

  const MessageBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    // Define a cor do balão apenas no nível do widget para manter
    // a paleta global intacta em outras telas do app.
    final backgroundColor = isCurrentUser
        ? AppColors.card
        : const Color(0xFFCFDBEF);
    final messageTextColor = Colors.black;

    final borderRadius = isCurrentUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      constraints: BoxConstraints(
        // Keep bubble within a comfortable reading width.
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: isCurrentUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: messageTextColor,
                  fontSize: 15,
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                time,
                style: const TextStyle(
                  color: Color(0xFF8A8A8A),
                  fontSize: 12,
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
