import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/presentation/pages/public_profile_page.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

class ConversationInfoScreen extends StatefulWidget {
  const ConversationInfoScreen({
    super.key,
    required this.chat,
  });

  final Chat chat;

  @override
  State<ConversationInfoScreen> createState() =>
      _ConversationInfoScreenState();
}

class _ConversationInfoScreenState extends State<ConversationInfoScreen> {
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    final participantId = widget.chat.participantId;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chat.id)
          .snapshots(),
      builder: (context, chatSnapshot) {
        bool isBlocked = widget.chat.isBlocked;
        Map<String, dynamic>? chatData;
        if (chatSnapshot.hasData && chatSnapshot.data!.exists) {
          chatData = chatSnapshot.data!.data() as Map<String, dynamic>?;
          if (chatData != null && chatData.containsKey('isBlocked')) {
            isBlocked = chatData['isBlocked'] as bool? ?? false;
          }
        }

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('idosos')
              .doc(participantId)
              .snapshots(),
          builder: (context, userSnapshot) {
            Map<String, dynamic>? userData;
            if (userSnapshot.hasData && userSnapshot.data!.exists) {
              userData = userSnapshot.data!.data() as Map<String, dynamic>?;
            }

            if (userData == null) {
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('familiares')
                    .doc(participantId)
                    .snapshots(),
                builder: (context, familiarSnapshot) {
                  if (familiarSnapshot.hasData &&
                      familiarSnapshot.data!.exists) {
                    userData = familiarSnapshot.data!.data()
                        as Map<String, dynamic>?;
                  }
                  return _buildScaffold(context, userData, chatData, isBlocked);
                },
              );
            }

            return _buildScaffold(context, userData, chatData, isBlocked);
          },
        );
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    Map<String, dynamic>? userData,
    Map<String, dynamic>? chatData,
    bool isBlocked,
  ) {
    final participantName = userData?['name'] ??
        userData?['nome'] ??
        widget.chat.participantName ??
        'Participante';

    final avatarPath = userData?['avatarPath'] ??
        userData?['foto'] ??
        userData?['avatar'] ??
        widget.chat.participantAvatar;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      'assets/icons/navigation/back_icon.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDCEAF5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: Color(0xFF033B63),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 18),
                      _buildAvatar(avatarPath),
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
                      
                      // INFORMAÇÃO DO GRUPO DINÂMICA
                      _buildGroupInfo(userData, chatData),

                      const SizedBox(height: 22),
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
                      const Divider(
                        color: AppColors.divider,
                        thickness: 1,
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                        ),
                        title: const Text(
                          'Ver perfil',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PublicProfilePage(
                                uid: widget.chat.participantId,
                              ),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isBlocked ? Icons.lock_open : Icons.block,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          isBlocked
                              ? 'Desbloquear usuário'
                              : 'Bloquear usuário',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) {
                              return AlertDialog(
                                title: Text(
                                  isBlocked
                                      ? 'Deseja desbloquear "$participantName"?'
                                      : 'Deseja bloquear "$participantName"?',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Raleway',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 20,
                                  ),
                                ),
                                content: Text(
                                  isBlocked
                                      ? 'Você poderá voltar a enviar e receber mensagens dessa pessoa.'
                                      : 'A pessoa não poderá mais enviar mensagens para você. Ela não saberá que foi bloqueada.',
                                  style: const TextStyle(
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
                                    child: Text(
                                      isBlocked ? 'Desbloquear' : 'Bloquear',
                                      style: const TextStyle(
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

                          if (confirm == true && widget.chat.id != null) {
                            try {
                              if (isBlocked) {
                                await _chatService
                                    .unblockChat(widget.chat.id!);
                              } else {
                                await _chatService.blockChat(widget.chat.id!);
                              }
                            } catch (error) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error.toString())),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupInfo(
    Map<String, dynamic>? userData,
    Map<String, dynamic>? chatData,
  ) {
    final String? groupName =
        chatData?['groupName'] ?? userData?['groupName'] ?? userData?['grupo'];

    if (groupName == null || groupName.trim().isEmpty) {
      return const Text(
        'Nenhum grupo em comum',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF8A8A8A),
          fontSize: 14,
          fontFamily: 'Quicksand',
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
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
        Text(
          groupName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF8A8A8A),
            fontSize: 14,
            fontFamily: 'Quicksand',
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String? avatarPath) {
    final hasAvatar = (avatarPath ?? '').trim().isNotEmpty;

    if (hasAvatar) {
      return ClipOval(
        child: avatarPath!.startsWith('assets/')
            ? Image.asset(
                avatarPath,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              )
            : Image.network(
                avatarPath,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) => const CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.secondary,
                  child: Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 50,
                  ),
                ),
              ),
      );
    }

    return const CircleAvatar(
      radius: 60,
      backgroundColor: AppColors.secondary,
      child: Icon(
        Icons.person,
        color: AppColors.primary,
        size: 50,
      ),
    );
  }
}