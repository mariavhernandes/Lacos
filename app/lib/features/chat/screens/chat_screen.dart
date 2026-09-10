import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
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
  final TextEditingController _messageController = TextEditingController();
  final MessageService _messageService = MessageService();

  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    isBlocked = widget.chat.isBlocked;
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _markMessagesAsRead() {
    if (widget.chat.id != null) {
      _messageService.markMessagesAsRead(widget.chat.id!);
    }
  }

  Widget _buildPresenceSubtitle() {
    final participantId = widget.chat.participantId;
    if (participantId == null || participantId.isEmpty) {
      return const Text(
        'Off-line',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('idosos')
          .doc(participantId)
          .snapshots(),
      builder: (context, snapshot) {
        Map<String, dynamic>? data;
        if (snapshot.hasData && snapshot.data!.exists) {
          data = snapshot.data!.data() as Map<String, dynamic>?;
        }

        if (data == null) {
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('familiares')
                .doc(participantId)
                .snapshots(),
            builder: (context, familiarSnapshot) {
              if (!familiarSnapshot.hasData || !familiarSnapshot.data!.exists) {
                return const Text(
                  'Off-line',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                );
              }
              final familiarData =
                  familiarSnapshot.data!.data() as Map<String, dynamic>?;
              return _formatPresenceText(familiarData);
            },
          );
        }

        return _formatPresenceText(data);
      },
    );
  }

  Widget _formatPresenceText(Map<String, dynamic>? data) {
    final bool isOnline = data?['isOnline'] as bool? ?? false;
    final rawLastSeen = data?['lastSeen'];

    if (isOnline) {
      return const Text(
        'Online',
        style: TextStyle(
          color: Color(0xFF2E7D32),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (rawLastSeen is Timestamp) {
      final date = rawLastSeen.toDate();
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return Text(
        'Visto por último às $hour:$minute',
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      );
    }

    return const Text(
      'Off-line',
      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
    );
  }

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
          icon: Image.asset('assets/icons/navigation/arrow_left.png'),
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
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildNormalAppBar() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset('assets/icons/navigation/arrow_left.png'),
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

              if (!mounted) return;

              if (result == 'blocked') {
                setState(() => isBlocked = true);
              } else if (result == 'unblocked') {
                setState(() => isBlocked = false);
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
                    widget.chat.participantAvatar ?? 'assets/avatars/avatar_1.png',
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
                    _buildPresenceSubtitle(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MessageModel>>(
      stream: _messageService.getMessagesStream(widget.chat.id!),
      builder: (context, snapshot) {
        final messages = snapshot.data ?? const <MessageModel>[];

        if (snapshot.hasData && messages.isNotEmpty) {
          _markMessagesAsRead();
        }

        final filteredMessages = messages.where((message) {
          if (searchQuery.trim().isEmpty) return true;
          return message.text
              .toLowerCase()
              .contains(searchQuery.trim().toLowerCase());
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: isSearching ? _buildSearchBar() : _buildNormalAppBar(),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const Divider(height: 1, thickness: 1, color: Color(0xFFE5E5E5)),
                Expanded(
                  child: Column(
                    children: [
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
                                          status: message.status, // <--- ADICIONE ESTA PROPRIEDADE AQUI
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
                Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
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
                            // REMOVE A BORDA PADRÃO E A BORDA AZUL AO CLICAR (FOCADO)
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
                      GestureDetector(
                        onTap: isBlocked
                            ? null
                            : () async {
                                try {
                                  await _messageService.sendMessage(
                                    chatId: widget.chat.id!,
                                    text: _messageController.text,
                                  );
                                  _messageController.clear();
                                } catch (error) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(error.toString()),
                                      ),
                                    );
                                  }
                                }
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
      },
    );
  }
}