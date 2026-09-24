import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  State<ConversationInfoScreen> createState() => _ConversationInfoScreenState();
}

class _ConversationInfoScreenState extends State<ConversationInfoScreen> {
  final ChatService _chatService = ChatService();

  Future<List<Map<String, dynamic>>>? _groupMembersFuture;

  @override
  void initState() {
    super.initState();

    if (widget.chat.isGroup && widget.chat.id != null) {
      _groupMembersFuture = _chatService.getGroupMembers(widget.chat.id!);
    }
  }

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

        // ==========================================
        // GRUPO
        // ==========================================

        if (widget.chat.isGroup) {
          return _buildScaffold(
            context,
            null,
            chatData,
            isBlocked,
          );
        }

        // ==========================================
        // CONVERSA PRIVADA
        // ==========================================

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
                    userData =
                        familiarSnapshot.data!.data() as Map<String, dynamic>?;
                  }

                  return _buildScaffold(
                    context,
                    userData,
                    chatData,
                    isBlocked,
                  );
                },
              );
            }

            return _buildScaffold(
              context,
              userData,
              chatData,
              isBlocked,
            );
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
    final bool isGroup = widget.chat.isGroup;

    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    final Map<String, dynamic> leftAt = Map<String, dynamic>.from(
      (chatData?['leftAt'] as Map<String, dynamic>?) ?? {},
    );

    final bool hasLeftGroup =
        isGroup && currentUserId != null && leftAt.containsKey(currentUserId);

    final String displayName = isGroup
        ? (chatData?['groupName'] ?? widget.chat.groupName ?? 'Grupo')
        : (userData?['name'] ??
            userData?['nome'] ??
            widget.chat.participantName ??
            'Participante');

    final String? avatarPath = isGroup
        ? (chatData?['groupAvatar'] ?? widget.chat.groupAvatar)
        : (userData?['avatarPath'] ??
            userData?['foto'] ??
            userData?['avatar'] ??
            widget.chat.participantAvatar);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // BOTÃO VOLTAR
            // ==========================================

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

            // ==========================================
            // CONTEÚDO
            // ==========================================

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 18),

                      // FOTO
                      _buildAvatar(avatarPath),

                      const SizedBox(height: 18),

                      // NOME
                      Text(
                        displayName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Raleway',
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ==========================================
                      // INFORMAÇÕES DO GRUPO
                      // ==========================================

                      if (isGroup) _buildGroupInfo(chatData),

                      const SizedBox(height: 22),

                      // ==========================================
                      // PESQUISAR
                      // ==========================================

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.search,
                          color: AppColors.primary,
                        ),
                        title: const Text(
                          'Pesquisar',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(
                            context,
                            'search',
                          );
                        },
                      ),

                      const Divider(
                        color: AppColors.divider,
                        thickness: 1,
                      ),

                      const SizedBox(height: 8),

                      // ==========================================
                      // OPÇÕES DO GRUPO
                      // ==========================================

                      if (isGroup) ...[
                        _buildMembersSection(chatData),
                        const SizedBox(height: 12),
                        const Divider(
                          color: AppColors.divider,
                          thickness: 1,
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            hasLeftGroup
                                ? Icons.delete_outline
                                : Icons.exit_to_app,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            hasLeftGroup ? 'Apagar grupo' : 'Sair do grupo',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () {
                            if (hasLeftGroup) {
                              _handleDeleteGroup();
                            } else {
                              _handleLeaveGroup(displayName);
                            }
                          },
                        ),
                      ],

                      // ==========================================
                      // OPÇÕES DA CONVERSA PRIVADA
                      // ==========================================

                      if (!isGroup) ...[
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
                                        ? 'Deseja desbloquear "$displayName"?'
                                        : 'Deseja bloquear "$displayName"?',
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
                                        Navigator.pop(
                                          dialogContext,
                                          false,
                                        );
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
                                        Navigator.pop(
                                          dialogContext,
                                          true,
                                        );
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

                            if (!mounted) {
                              return;
                            }

                            if (confirm == true && widget.chat.id != null) {
                              try {
                                if (isBlocked) {
                                  await _chatService.unblockChat(
                                    widget.chat.id!,
                                  );
                                } else {
                                  await _chatService.blockChat(
                                    widget.chat.id!,
                                  );
                                }
                              } catch (error) {
                                if (!mounted) {
                                  return;
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error.toString()),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
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

  // ==========================================
  // INFORMAÇÕES DO GRUPO
  // ==========================================

  Widget _buildGroupInfo(
    Map<String, dynamic>? chatData,
  ) {
    final List<dynamic> participants =
        chatData?['participants'] ?? widget.chat.participantIds ?? [];

    final int participantCount = participants.length;

    return Text(
      '$participantCount participantes',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontFamily: 'Quicksand',
      ),
    );
  }

  // ==========================================
  // MEMBROS
  // ==========================================

  Widget _buildMembersSection(
    Map<String, dynamic>? chatData,
  ) {
    if (widget.chat.id == null) {
      return const SizedBox.shrink();
    }

    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Membros',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _groupMembersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Não foi possível carregar os membros.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontFamily: 'Quicksand',
                  ),
                ),
              );
            }

            final members = List<Map<String, dynamic>>.from(
              snapshot.data ?? [],
            );

            members.sort((a, b) {
              final String? uidA = a['uid']?.toString();
              final String? uidB = b['uid']?.toString();

              if (uidA == currentUserId) return -1;
              if (uidB == currentUserId) return 1;

              return 0;
            });

            if (members.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Nenhum membro encontrado.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontFamily: 'Quicksand',
                  ),
                ),
              );
            }

            return Column(
              children: members.map((member) {
                final String? uid = member['uid']?.toString();

                final String name = member['name']?.toString() ?? 'Usuário';

                final String? avatar = member['avatar']?.toString();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: uid == null || uid.isEmpty || uid == currentUserId
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PublicProfilePage(
                                    uid: uid,
                                  ),
                                ),
                              );
                            },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 4,
                        ),
                        child: Row(
                          children: [
                            _buildMemberAvatar(avatar),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (uid != null &&
                                uid.isNotEmpty &&
                                uid != currentUserId)
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.textSecondary,
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // AVATAR DOS MEMBROS
  // ==========================================

  Widget _buildMemberAvatar(
    String? avatarPath,
  ) {
    if (avatarPath == null || avatarPath.trim().isEmpty) {
      return _buildDefaultMemberAvatar();
    }

    if (avatarPath.startsWith('assets/')) {
      return ClipOval(
        child: Image.asset(
          avatarPath,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _buildDefaultMemberAvatar();
          },
        ),
      );
    }

    return ClipOval(
      child: Image.network(
        avatarPath,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _buildDefaultMemberAvatar();
        },
      ),
    );
  }

  Widget _buildDefaultMemberAvatar() {
    return const CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.secondary,
      child: Icon(
        Icons.person,
        color: AppColors.primary,
        size: 25,
      ),
    );
  }

  // ==========================================
  // SAIR DO GRUPO
  // ==========================================

  Future<void> _handleLeaveGroup(
    String groupName,
  ) async {
    final chatId = widget.chat.id;

    if (chatId == null) {
      return;
    }

    final bool? confirmLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Deseja realmente sair deste grupo?',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w400,
              fontSize: 20,
            ),
          ),
          content: Text(
            'Você deixará de participar do grupo "$groupName".',
            style: const TextStyle(
              color: Color(0xFF8A8A8A),
              fontFamily: 'Quicksand',
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
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
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Sair',
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

    if (!mounted || confirmLeave != true) {
      return;
    }

    // ==========================================
    // SAI DO GRUPO
    // ==========================================

    try {
      await _chatService.leaveGroup(chatId);

      if (!mounted) {
        return;
      }

      // Apenas informa ao ChatScreen que a saída aconteceu.
      // A pergunta sobre apagar o grupo será feita lá.
      Navigator.of(context).pop('group_left');
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    }
  }

  // ==========================================
  // APAGAR GRUPO
  // ==========================================

  Future<void> _handleDeleteGroup() async {
    final chatId = widget.chat.id;

    if (chatId == null) {
      return;
    }

    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Deseja apagar este grupo?',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w400,
              fontSize: 20,
            ),
          ),
          content: Text(
            'O grupo será apagado apenas para você.',
            style: const TextStyle(
              color: Color(0xFF8A8A8A),
              fontFamily: 'Quicksand',
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Não',
                style: TextStyle(
                  color: AppColors.primary,
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Sim',
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

    if (!mounted || confirmDelete != true) {
      return;
    }

    try {
      await _chatService.deleteGroup(chatId);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop('group_deleted');
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    }
  }

  // ==========================================
  // FOTO PRINCIPAL
  // ==========================================

  Widget _buildAvatar(
    String? avatarPath,
  ) {
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
                errorBuilder: (_, __, ___) {
                  return _buildDefaultAvatar();
                },
              )
            : Image.network(
                avatarPath,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) {
                  return _buildDefaultAvatar();
                },
              ),
      );
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    final bool isGroup = widget.chat.isGroup;

    return CircleAvatar(
      radius: 60,
      backgroundColor: AppColors.secondary,
      child: Icon(
        isGroup ? Icons.group : Icons.person,
        color: AppColors.primary,
        size: 50,
      ),
    );
  }
}
