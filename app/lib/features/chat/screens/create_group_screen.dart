import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../services/chat_service.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Set<String> _selectedParticipants = {};

  String? _currentUserId;
  List<Map<String, dynamic>> _users = [];

  bool _isLoading = false;
  bool _isFetchingUsers = true;

  String _selectedGroupAvatar = 'assets/avatars/group_photo_1.png';

  final List<String> _groupAvatars = [
    'assets/avatars/group_photo_1.png',
    'assets/avatars/group_photo_2.png',
  ];

  @override
  void initState() {
    super.initState();

    _currentUserId = _auth.currentUser?.uid;
    _fetchAvailableUsers();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUSCA OS IDOSOS QUE PODEM SER ADICIONADOS AO GRUPO
  // ============================================================
  Future<void> _fetchAvailableUsers() async {
    try {
      final currentUserId = _currentUserId;

      if (currentUserId == null) {
        if (mounted) {
          setState(() {
            _users = [];
            _isFetchingUsers = false;
          });
        }
        return;
      }

      // ==========================================================
      // 1. BUSCA O IDOSO LOGADO
      // ==========================================================

      final currentUserDoc =
          await _firestore.collection('idosos').doc(currentUserId).get();

      if (!currentUserDoc.exists || currentUserDoc.data() == null) {
        if (mounted) {
          setState(() {
            _users = [];
            _isFetchingUsers = false;
          });
        }
        return;
      }

      final currentUserData = currentUserDoc.data()!;

      // ==========================================================
      // 2. PEGA QUEM O IDOSO LOGADO SEGUE
      // ==========================================================

      final Set<String> followingIds = {};

      final following = currentUserData['followingIds'];

      if (following is List) {
        for (final id in following) {
          final followingId = id.toString();

          if (followingId.isNotEmpty && followingId != currentUserId) {
            followingIds.add(followingId);
          }
        }
      }

      // ==========================================================
      // 3. BUSCA OS CONTATOS DE CONVERSAS PRIVADAS
      // ==========================================================

      final chatsSnapshot = await _firestore
          .collection('chats')
          .where(
            'participants',
            arrayContains: currentUserId,
          )
          .get();

      final Set<String> contactIds = {};

      for (final doc in chatsSnapshot.docs) {
        final data = doc.data();

        final bool isGroup = data['isGroup'] as bool? ?? false;

        // Grupo não é considerado contato para esta seleção.
        if (isGroup) {
          continue;
        }

        final participants = data['participants'];

        if (participants is! List) {
          continue;
        }

        for (final participant in participants) {
          final participantId = participant.toString();

          if (participantId.isNotEmpty && participantId != currentUserId) {
            contactIds.add(participantId);
          }
        }
      }

      // ==========================================================
      // 4. JUNTA QUEM SEGUE + QUEM JÁ TEM CONVERSA
      // ==========================================================

      final Set<String> availableIds = {
        ...followingIds,
        ...contactIds,
      };

      final List<Map<String, dynamic>> users = [];

      // ==========================================================
      // 5. BUSCA SOMENTE NA COLEÇÃO "IDOSOS"
      // ==========================================================

      for (final userId in availableIds) {
        final userDoc = await _firestore.collection('idosos').doc(userId).get();

        // Se não existir na coleção "idosos",
        // não aparece na criação do grupo.
        if (!userDoc.exists || userDoc.data() == null) {
          continue;
        }

        final data = userDoc.data()!;

        // ========================================================
        // NOME
        // ========================================================

        final String name =
            (data['nome'] ?? data['name'] ?? 'Sem nome').toString();

        // ========================================================
        // AVATAR
        // ========================================================

        final String avatar = (data['avatarPath'] ??
                data['foto'] ??
                data['avatar'] ??
                data['foto_url'] ??
                'assets/avatars/default_profile_image.png')
            .toString();

        users.add({
          'id': userId,
          'name': name,
          'avatar': avatar,
          'type': 'idoso',
        });
      }

      // ==========================================================
      // 6. ORDENA POR NOME
      // ==========================================================

      users.sort(
        (a, b) => (a['name'] as String)
            .toLowerCase()
            .compareTo((b['name'] as String).toLowerCase()),
      );

      if (mounted) {
        setState(() {
          _users = users;
          _isFetchingUsers = false;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar contatos: $error'),
            backgroundColor: Colors.red,
          ),
        );

        setState(() {
          _isFetchingUsers = false;
        });
      }
    }
  }

  // ============================================================
  // CRIA O GRUPO
  // ============================================================
  Future<void> _createGroup() async {
    final groupName = _groupNameController.text.trim();

    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira um nome para o grupo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos um participante'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // O ChatService adiciona o criador automaticamente.
      final participantIds = [..._selectedParticipants];

      final groupId = await _chatService.createGroup(
        groupName: groupName,
        participantIds: participantIds,
        groupAvatar: _selectedGroupAvatar,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Grupo criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop(groupId);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar grupo: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // SELECIONA / REMOVE PARTICIPANTE
  // ============================================================
  void _toggleParticipant(String userId) {
    setState(() {
      if (_selectedParticipants.contains(userId)) {
        _selectedParticipants.remove(userId);
      } else {
        _selectedParticipants.add(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: const Text(
          'Criar Grupo',
          style: TextStyle(
            color: Color(0xFF555555),
            fontWeight: FontWeight.bold,
            fontSize: 17,
            fontFamily: 'Quicksand',
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ========================================================
            // NOME DO GRUPO
            // ========================================================

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _groupNameController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Nome do grupo',
                  hintStyle: const TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontFamily: 'Quicksand',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E5E5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E5E5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                ),
              ),
            ),

// ========================================================
// FOTO DO GRUPO
// ========================================================

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Foto do grupo',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: _groupAvatars.map((avatar) {
                      final bool isSelected = _selectedGroupAvatar == avatar;

                      return GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _selectedGroupAvatar = avatar;
                                });
                              },
                        child: Container(
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundImage: AssetImage(avatar),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ========================================================
            // TÍTULO
            // ========================================================

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selecione os participantes',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ========================================================
            // LISTA
            // ========================================================

            Expanded(
              child: _isFetchingUsers
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _users.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                            ),
                            child: Text(
                              'Nenhum contato disponível para adicionar ao grupo.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontFamily: 'Quicksand',
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          itemCount: _users.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            thickness: 0.8,
                            color: Color(0xFFE5E5E5),
                          ),
                          itemBuilder: (context, index) {
                            final user = _users[index];

                            final String userId = user['id'] as String;
                            final String userName = user['name'] as String;
                            final String userAvatar = user['avatar'] as String;

                            final bool isSelected =
                                _selectedParticipants.contains(userId);

                            return Material(
                              color: AppColors.background,
                              child: InkWell(
                                onTap: _isLoading
                                    ? null
                                    : () => _toggleParticipant(userId),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      // ==================================================
                                      // CHECKBOX
                                      // ==================================================

                                      Checkbox(
                                        value: isSelected,
                                        onChanged: _isLoading
                                            ? null
                                            : (_) => _toggleParticipant(
                                                  userId,
                                                ),
                                        activeColor: AppColors.primary,
                                      ),

                                      const SizedBox(width: 4),

                                      // ==================================================
                                      // AVATAR
                                      // ==================================================

                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor:
                                            const Color(0xFFE5E5E5),
                                        backgroundImage:
                                            userAvatar.startsWith('http')
                                                ? NetworkImage(userAvatar)
                                                : AssetImage(userAvatar)
                                                    as ImageProvider,
                                      ),

                                      const SizedBox(width: 12),

                                      // ==================================================
                                      // NOME
                                      // ==================================================

                                      Expanded(
                                        child: Text(
                                          userName,
                                          style: const TextStyle(
                                            fontFamily: 'Quicksand',
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),

            // ========================================================
            // BOTÃO CRIAR GRUPO
            // ========================================================

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey[400],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Criar Grupo',
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
