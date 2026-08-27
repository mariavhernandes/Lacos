import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

class ConversationInfoScreen extends StatefulWidget {
  const ConversationInfoScreen({super.key, required this.chat});

  final Chat chat;

  @override
  State<ConversationInfoScreen> createState() => _ConversationInfoScreenState();
}

class _ConversationInfoScreenState extends State<ConversationInfoScreen> {
  late bool isBlocked;

  @override
  void initState() {
    super.initState();

    final currentChat = ChatService.getChat(widget.chat.id!);

    isBlocked = currentChat?.isBlocked ?? widget.chat.isBlocked;
  }

  @override
  Widget build(BuildContext context) {
    final participantName = widget.chat.participantName ?? 'Participante';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leadingWidth: 48,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset(
            'assets/icons/navigation/back_icon.png',
            width: 20,
            height: 20,
          ),
          splashRadius: 24,
          tooltip: 'Voltar',
        ),
        title: const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 18),
                _buildAvatar(),
                const SizedBox(height: 18),
                Text(
                  participantName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Raleway',
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    const Text(
                      'Você participa do mesmo grupo:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Dia de Parque',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF8A8A8A),
                        fontSize: 14,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const SizedBox(height: 20),
                Center(
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.pop(context, 'search');
                      },
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 30,
                              color: AppColors.primary,
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Pesquisar',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Quicksand',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(color: AppColors.divider, thickness: 1),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person, color: AppColors.primary),
                  title: const Text(
                    'Ver perfil',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isBlocked ? Icons.lock_open : Icons.block,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    isBlocked ? 'Desbloquear usuário' : 'Bloquear usuário',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    if (isBlocked) {
                      final shouldUnblock = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: Text(
                              'Deseja desbloquear "$participantName"?',
                              style: const TextStyle(
                                color: Colors.black,
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.w400,
                                fontSize: 20,
                              ),
                            ),
                            content: const Text(
                              'Você poderá voltar a enviar e receber mensagens dessa pessoa.',
                              style: TextStyle(
                                color: Color(0xFF8A8A8A),
                                fontFamily: 'Quicksand',
                                fontSize: 14,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext, false);
                                },
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontFamily: 'Quicksand',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext, true);
                                },
                                child: const Text(
                                  'Desbloquear',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontFamily: 'Quicksand',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                      if (shouldUnblock == true) {
                        ChatService.unblockChat(widget.chat.id!);

                        if (context.mounted) {
                          Navigator.pop(context, 'unblocked');
                        }
                      }

                      return;
                    }

                    // Aqui continua o bloqueio que já temos.
                    final shouldBlock = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: Text(
                            'Deseja bloquear "$participantName"?',
                            style: const TextStyle(
                              color: Colors.black,
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                            ),
                          ),
                          content: const Text(
                            'A pessoa não poderá mais enviar mensagens para você. '
                            'Ela não saberá que foi bloqueada.',
                            style: TextStyle(
                              color: Color(0xFF8A8A8A),
                              fontFamily: 'Quicksand',
                              fontSize: 14,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext, false);
                              },
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext, true);
                              },
                              child: const Text(
                                'Bloquear',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    if (shouldBlock == true) {
                      ChatService.blockChat(widget.chat.id!);

                      if (context.mounted) {
                        Navigator.pop(context, 'blocked');
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final hasAvatar = (widget.chat.participantAvatar ?? '').trim().isNotEmpty;

    if (hasAvatar) {
      return ClipOval(
        child: Image.asset(
          widget.chat.participantAvatar!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      );
    }

    return CircleAvatar(
      radius: 40,
      backgroundColor: AppColors.secondary,
      child: const Icon(Icons.person, color: AppColors.primary, size: 38),
    );
  }
}
