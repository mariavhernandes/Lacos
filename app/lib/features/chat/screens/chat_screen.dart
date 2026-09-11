import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../services/message_service.dart';
import '../services/notification_service.dart';
import '../widgets/message_bubble.dart';
import 'conversation_info_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.chat});

  final Chat chat;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isSearching = false;
  bool _isChatScreenActive = false;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final MessageService _messageService = MessageService();
  final ChatService _chatService = ChatService();
  final FocusNode _messageFocusNode = FocusNode();

  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _isChatScreenActive = true;

    if (widget.chat.id != null) {
      NotificationService().setActiveChatId(widget.chat.id!);
    }

    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _isChatScreenActive = false;
    NotificationService().clearActiveChatId();
    _searchController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _markMessagesAsRead() {
    if (widget.chat.id != null) {
      _messageService.markMessagesAsRead(widget.chat.id!);
      _chatService.markAsRead(widget.chat.id!);
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text;

    if (messageText.trim().isEmpty) {
      return;
    }

    try {
      await _messageService.sendMessage(
        chatId: widget.chat.id!,
        text: messageText,
      );
      _messageController.clear();

      if (mounted) {
        FocusScope.of(context).requestFocus(_messageFocusNode);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
          ),
        );
      }
    }
  }

  Widget _buildPresenceSubtitle(String? participantId) {
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
    final bool isOnline = (data != null && data.containsKey('isOnline'))
        ? (data['isOnline'] == true)
        : false;

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

  Widget _buildNormalAppBar(bool isBlocked) {
    final otherUserId = widget.chat.participantId;

    return Row(
      children: [
        IconButton(
          onPressed: () async {
            if (widget.chat.id != null) {
              await _chatService.markAsRead(widget.chat.id!);
            }
            if (mounted) {
              Navigator.pop(context);
            }
          },
          icon: Image.asset('assets/icons/navigation/arrow_left.png'),
          color: AppColors.textPrimary,
          splashRadius: 24,
          tooltip: 'Voltar',
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('idosos')
                .doc(otherUserId)
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
                      .doc(otherUserId)
                      .snapshots(),
                  builder: (context, familiarSnapshot) {
                    Map<String, dynamic>? familiarData;
                    if (familiarSnapshot.hasData &&
                        familiarSnapshot.data!.exists) {
                      familiarData =
                          familiarSnapshot.data!.data() as Map<String, dynamic>?;
                    }
                    return _buildHeaderContent(
                      userId: otherUserId,
                      userData: familiarData,
                      isBlocked: isBlocked,
                    );
                  },
                );
              }

              return _buildHeaderContent(
                userId: otherUserId,
                userData: data,
                isBlocked: isBlocked,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderContent({
    required String? userId,
    required Map<String, dynamic>? userData,
    required bool isBlocked,
  }) {
    final name = userData?['name'] ??
        userData?['nome'] ??
        widget.chat.participantName ??
        'Participante';

    final avatar = userData?['avatarPath'] ??
        userData?['foto'] ??
        userData?['avatar'] ??
        widget.chat.participantAvatar ??
        'assets/avatars/avatar_1.png';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (_) => ConversationInfoScreen(
              chat: widget.chat,
            ),
          ),
        );

        if (!mounted) return;

        if (result == 'search') {
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
            child: avatar.startsWith('assets/')
                ? Image.asset(
                    avatar,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    avatar,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/avatars/avatar_1.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Raleway',
                  ),
                ),
                const SizedBox(height: 2),
                _buildPresenceSubtitle(userId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chat.id)
          .snapshots(),
      builder: (context, chatSnapshot) {
        bool isBlocked = widget.chat.isBlocked;
        if (chatSnapshot.hasData && chatSnapshot.data!.exists) {
          final data = chatSnapshot.data!.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('isBlocked')) {
            isBlocked = data['isBlocked'] as bool? ?? false;
          }
        }

        return StreamBuilder<List<MessageModel>>(
          stream: _messageService.getMessagesStream(widget.chat.id!),
          builder: (context, snapshot) {
            final messages = snapshot.data ?? const <MessageModel>[];

            if (_isChatScreenActive && snapshot.hasData && messages.isNotEmpty) {
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
                title: isSearching
                    ? _buildSearchBar()
                    : _buildNormalAppBar(isBlocked),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    const Divider(
                        height: 1, thickness: 1, color: Color(0xFFE5E5E5)),
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
                                    reverse: true,
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 16, 20, 16),
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
                                              isCurrentUser:
                                                  message.isCurrentUser,
                                              status: message.status,
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
                            child: KeyboardListener(
                              focusNode: FocusNode(),
                              onKeyEvent: (KeyEvent event) {
                                if (event is KeyDownEvent &&
                                    event.logicalKey ==
                                        LogicalKeyboardKey.enter &&
                                    !HardwareKeyboard
                                        .instance.isShiftPressed) {
                                  if (!isBlocked) {
                                    _sendMessage();
                                  }
                                }
                              },
                              child: TextField(
                                controller: _messageController,
                                focusNode: _messageFocusNode,
                                enabled: !isBlocked,
                                minLines: 1,
                                maxLines: 5,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
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
                                    vertical: 12,
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
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: isBlocked ? null : _sendMessage,
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
      },
    );
  }
}