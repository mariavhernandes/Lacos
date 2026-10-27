import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_footer.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import '../widgets/chat_tile.dart';
import 'chat_screen.dart';

class FamilyChatListScreen extends StatefulWidget {
  const FamilyChatListScreen({super.key});

  @override
  State<FamilyChatListScreen> createState() => _FamilyChatListScreenState();
}

class _FamilyChatListScreenState extends State<FamilyChatListScreen> {
  final ChatService _chatService = ChatService();
  String? _elderlyUid;
  String _elderlyFirstName = 'Idoso';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchElderlyData();
  }

  Future<void> _fetchElderlyData() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final familyDoc = await FirebaseFirestore.instance
          .collection('familiares')
          .doc(currentUserId)
          .get();

      if (familyDoc.exists) {
        final familyData = familyDoc.data();
        final linkedElderEmail = familyData?['linkedElderEmail'] as String?;

        if (linkedElderEmail != null && linkedElderEmail.trim().isNotEmpty) {
          final elderlyQuery = await FirebaseFirestore.instance
              .collection('idosos')
              .where('email', isEqualTo: linkedElderEmail.trim())
              .limit(1)
              .get();

          if (elderlyQuery.docs.isNotEmpty) {
            final doc = elderlyQuery.docs.first;
            _elderlyUid = doc.id;

            final elderlyData = doc.data();
            final fullName = (elderlyData['name'] ?? elderlyData['nome'] ?? '')
                .toString()
                .trim();

            if (fullName.isNotEmpty) {
              _elderlyFirstName = fullName.split(' ').first;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar idoso vinculado: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: Text(
          'Conversas de $_elderlyFirstName',
          style: const TextStyle(
            color: Color(0xFF555555),
            fontWeight: FontWeight.bold,
            fontSize: 17,
            fontFamily: 'Quicksand',
          ),
        ),
      ),
      bottomNavigationBar: const CustomFooter(
        currentIndex: 2,
        isFamily: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : _elderlyUid == null
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Nenhum idoso vinculado a este perfil.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF8A8A8A),
                          fontSize: 15,
                          fontFamily: 'Quicksand',
                        ),
                      ),
                    ),
                  )
                : StreamBuilder<List<Chat>>(
                    stream: _chatService.getChatsStreamForUser(_elderlyUid!),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Erro ao carregar chats:\n${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontFamily: 'Quicksand',
                              ),
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final chats = snapshot.data!;

                      final validChats = chats.where((chat) {
                        if (chat.isGroup) {
                          return true;
                        }
                        final lastMessage = chat.lastMessage?.trim() ?? '';
                        return lastMessage.isNotEmpty;
                      }).toList();

                      if (validChats.isEmpty) {
                        return const Center(
                          child: Text(
                            'Nenhuma conversa encontrada.',
                            style: TextStyle(
                              color: Color(0xFF8A8A8A),
                              fontSize: 15,
                              fontFamily: 'Quicksand',
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: validChats.length,
                        separatorBuilder: (context, index) {
                          return const Divider(
                            height: 1,
                            thickness: 0.8,
                            color: Color(0xFFE5E5E5),
                          );
                        },
                        itemBuilder: (context, index) {
                          final originalChat = validChats[index];

                          // Força a contagem de mensagens não lidas para 0
                          // garantindo que não apareça a bolinha azul para o familiar
                          final chatWithoutBadge = Chat(
                            id: originalChat.id,
                            isGroup: originalChat.isGroup,
                            groupName: originalChat.groupName,
                            groupAvatar: originalChat.groupAvatar,
                            participantId: originalChat.participantId,
                            participantName: originalChat.participantName,
                            participantAvatar: originalChat.participantAvatar,
                            lastMessage: originalChat.lastMessage,
                            lastMessageTime: originalChat.lastMessageTime,
                            unreadMessages: 0,
                            isBlocked: originalChat.isBlocked,
                            participantIds: originalChat.participantIds,
                            creatorId: originalChat.creatorId,
                          );

                          return ChatTile(
                            chat: chatWithoutBadge,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    chat: originalChat,
                                    isReadOnly: true,
                                    viewingUserId: _elderlyUid,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }
}