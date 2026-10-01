import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../notifications/data/notification_service.dart';
import '../../../chat/screens/chat_screen.dart';
import '../../../chat/models/chat_model.dart';
import '../../../chat/screens/chat_screen.dart';

class PublicProfilePage extends StatefulWidget {
  final String? uid;

  const PublicProfilePage({
    super.key,
    this.uid,
  });

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  bool _isFollowing = false;
  bool _isLoadingFollowStatus = true;
  bool _isUpdatingFollow = false;
  bool _isOpeningChat = false;

  final Set<String> _predefinedInterests = {
    'Jogos de tabuleiro',
    'Jogo de tabuleiro',
    'Jogos de carta',
    'Jogo de cartas',
    'Jogos de cartas',
    'Xadrez',
    'Dança',
    'Jardinagem',
    'Tricô/Crochê',
    'Artesanato',
    'Caminhada',
    'Dominó',
  };

  final Map<String, String> _interestIcons = {
    'jogos de tabuleiro': 'assets/images/commun/card_games.png',
    'jogo de tabuleiro': 'assets/images/commun/card_games.png',
    'jogo de cartas': 'assets/images/commun/card_games.png',
    'jogos de carta': 'assets/images/commun/card_games.png',
    'jogos de cartas': 'assets/images/commun/card_games.png',
    'xadrez': 'assets/images/commun/chess.png',
    'danca': 'assets/images/commun/dancing.png',
    'dança': 'assets/images/commun/dancing.png',
    'jardinagem': 'assets/images/commun/gardening.png',
    'trico/croche': 'assets/images/commun/knitting.png',
    'tricô/crochê': 'assets/images/commun/knitting.png',
    'trico': 'assets/images/commun/knitting.png',
    'tricô': 'assets/images/commun/knitting.png',
    'croche': 'assets/images/commun/knitting.png',
    'crochê': 'assets/images/commun/knitting.png',
    'artesanato': 'assets/images/commun/sewing.png',
    'caminhada': 'assets/images/commun/walking.png',
    'domino': 'assets/images/commun/domino.png',
    'dominó': 'assets/images/commun/domino.png',
  };

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
  }

  // ============================================================
  // VERIFICAR SE O USUÁRIO JÁ SEGUE
  // ============================================================

  Future<void> _checkFollowStatus() async {
    final String? targetUid = widget.uid;
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (targetUid == null ||
        targetUid.isEmpty ||
        currentUserId == null ||
        targetUid == currentUserId) {
      if (mounted) setState(() => _isLoadingFollowStatus = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('idosos')
          .doc(currentUserId)
          .get();

      if (doc.exists && doc.data() != null) {
        final List<dynamic> following = doc.data()?['followingIds'] ?? [];
        if (mounted) {
          setState(() {
            _isFollowing = following.contains(targetUid);
            _isLoadingFollowStatus = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingFollowStatus = false);
      }
    } catch (e) {
      debugPrint('Erro ao verificar status de seguir: $e');
      if (mounted) setState(() => _isLoadingFollowStatus = false);
    }
  }

  Future<void> _confirmUnfollow(String targetUid, String targetName) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Deixar de seguir?',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D3B66),
            ),
          ),
          content: Text(
            'Tem certeza que deseja deixar de seguir $targetName?',
            style: const TextStyle(
              fontFamily: 'Raleway',
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Deixar de seguir',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  color: Color(0xFF0D3B66),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _toggleFollow(targetUid);
    }
  }

  Future<void> _toggleFollow(String targetUid) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null || currentUserId == targetUid || _isUpdatingFollow) {
      return;
    }

    setState(() {
      _isUpdatingFollow = true;
    });

    final currentUserRef =
        FirebaseFirestore.instance.collection('idosos').doc(currentUserId);
    final targetUserRef =
        FirebaseFirestore.instance.collection('idosos').doc(targetUid);

    final bool wasFollowing = _isFollowing;

    try {
      if (wasFollowing) {
        // Deixar de seguir
        await currentUserRef.update({
          'followingIds': FieldValue.arrayRemove([targetUid]),
        });
        await targetUserRef.update({
          'followerIds': FieldValue.arrayRemove([currentUserId]),
          'followersCount': FieldValue.increment(-1),
        });

        if (mounted) {
          setState(() {
            _isFollowing = false;
          });
        }
      } else {
        // Seguir
        await currentUserRef.set({
          'followingIds': FieldValue.arrayUnion([targetUid]),
        }, SetOptions(merge: true));

        await targetUserRef.set({
          'followerIds': FieldValue.arrayUnion([currentUserId]),
          'followersCount': FieldValue.increment(1),
        }, SetOptions(merge: true));

        if (mounted) {
          setState(() {
            _isFollowing = true;
          });
        }

        // ------------------------------------------------------------
        // BUSCAR NOME DO SEGUIDOR E ENVIAR NOTIFICAÇÃO
        // ------------------------------------------------------------
        String followerName = 'Um utilizador';

        try {
          var userDoc = await currentUserRef.get();

          if (!userDoc.exists || userDoc.data() == null) {
            userDoc = await FirebaseFirestore.instance
                .collection('familiares')
                .doc(currentUserId)
                .get();
          }

          if (userDoc.exists && userDoc.data() != null) {
            final data = userDoc.data()!;
            followerName = data['name'] ?? data['nome'] ?? 'Um utilizador';
          }

          debugPrint('Disparando notificação. Seguidor: $followerName | Alvo: $targetUid');

          await FamilyNotificationService().sendNewFollowerNotification(
            targetElderUid: targetUid,
            followerUid: currentUserId,
            followerName: followerName,
          );
        } catch (notifErr) {
          debugPrint('Erro durante envio de notificação: $notifErr');
        }
      }
    } catch (error) {
      debugPrint('Erro ao atualizar seguir: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível realizar a ação.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingFollow = false;
        });
      }
    }
  }

  Future<void> _openChatWithUser(
    String targetUid,
    String targetName,
    String targetAvatar,
  ) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null || currentUserId == targetUid || _isOpeningChat) {
      return;
    }

    setState(() => _isOpeningChat = true);

    try {
      final chatsRef = FirebaseFirestore.instance.collection('chats');

      // 1. Procurar conversa existente onde o usuário atual é participante
      final querySnapshot = await chatsRef
          .where('participants', arrayContains: currentUserId)
          .get();

      DocumentSnapshot<Map<String, dynamic>>? existingDoc;

      for (final doc in querySnapshot.docs) {
        final List<dynamic> participants = doc.data()['participants'] ?? [];
        if (participants.contains(targetUid)) {
          existingDoc = doc;
          break;
        }
      }

      String chatId;
      Map<String, dynamic> chatData = {};

      if (existingDoc != null) {
        // Encontrou a conversa existente no banco de dados!
        chatId = existingDoc.id;
        chatData = existingDoc.data() ?? {};
      } else {
        // Se NUNCA conversaram antes, cria com a estrutura exata do seu Firestore
        final newDoc = await chatsRef.add({
          'participants': [currentUserId, targetUid],
          'participantId': targetUid,
          'participantName': targetName,
          'participantAvatar': targetAvatar,
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'isBlocked': false,
          'unreadMessages': 0,
        });

        chatId = newDoc.id;
      }

      if (!mounted) return;

      // 2. Montar o objeto Chat preenchendo todos os campos da conversa
      final chatModel = Chat(
        id: chatId,
        participantId: targetUid,
        participantName: targetName,
        participantAvatar: targetAvatar,
        lastMessage: chatData['lastMessage']?.toString() ?? '',
        isGroup: chatData['isGroup'] == true,
      );

      // 3. Abrir diretamente a tela de chat (sem SnackBar e sem criar duplicado!)
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(chat: chatModel),
        ),
      );
    } catch (e) {
      debugPrint('Erro ao abrir chat: $e');
    } finally {
      if (mounted) {
        setState(() => _isOpeningChat = false);
      }
    }
  }

  // ============================================================
  // MODAL DE EXIBIÇÃO DE LISTA DE SEGUIDORES OU SEGUINDO (SEM LINHA PRETA)
  // ============================================================

  void _showUsersListModal(String title, List<dynamic> userIds) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 12),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D3B66),
                    ),
                  ),
                ),
                // Linha divisória removida conforme solicitado!
                Expanded(
                  child: userIds.isEmpty
                      ? Center(
                          child: Text(
                            'Ninguém na lista.',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: userIds.length,
                          itemBuilder: (context, index) {
                            final uidStr = userIds[index].toString();

                            return FutureBuilder<Map<String, dynamic>?>(
                              future: _fetchUserData(uidStr),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData || snapshot.data == null) {
                                  return const ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Color(0xFFEEEEEE),
                                    ),
                                    title: Text('Carregando...'),
                                  );
                                }

                                final uData = snapshot.data!;
                                final uName = uData['name'] ?? uData['nome'] ?? 'Usuário';
                                final uAvatar = uData['avatarPath'] ??
                                    uData['foto'] ??
                                    'assets/avatars/default_profile_image.png';

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: AssetImage(uAvatar),
                                  ),
                                  title: Text(
                                    uName,
                                    style: const TextStyle(
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 39, 39, 39),
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  onTap: () {
                                    Navigator.pop(context); // Fechar modal
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PublicProfilePage(uid: uidStr),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // NORMALIZAÇÃO DE DADOS
  // ============================================================

  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ì', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c');
  }

  bool _isPredefinedInterest(String item) {
    final cleanItem = _normalizeText(item);
    return _predefinedInterests.any((p) => _normalizeText(p) == cleanItem);
  }

  String? _getIconPath(String title) {
    final cleanTitle = title.toLowerCase().trim();
    if (_interestIcons.containsKey(cleanTitle)) {
      return _interestIcons[cleanTitle];
    }
    final normalized = _normalizeText(title);
    return _interestIcons[normalized];
  }

  List<String> _extractInterestsList(Map<String, dynamic> data) {
    final dynamic rawData = data['interests'] ?? data['interesses'];

    if (rawData == null) return [];

    if (rawData is List) {
      return rawData
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    if (rawData is Map) {
      return rawData.values
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    if (rawData is String) {
      if (rawData.trim().isEmpty) return [];
      return rawData
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return [];
  }

  Future<Map<String, dynamic>?> _fetchUserData(String targetUid) async {
    final idosoDoc = await FirebaseFirestore.instance
        .collection('idosos')
        .doc(targetUid)
        .get();

    if (idosoDoc.exists && idosoDoc.data() != null) {
      return idosoDoc.data();
    }

    final familiarDoc = await FirebaseFirestore.instance
        .collection('familiares')
        .doc(targetUid)
        .get();

    if (familiarDoc.exists && familiarDoc.data() != null) {
      return familiarDoc.data();
    }

    return null;
  }

  String _getAgeText(Map<String, dynamic> data) {
    final dynamic rawBirth = data['birthDate'] ??
        data['dataNascimento'] ??
        data['data_nascimento'] ??
        data['birth_date'] ??
        data['nascimento'];

    DateTime? birthDate;

    if (rawBirth is Timestamp) {
      birthDate = rawBirth.toDate();
    } else if (rawBirth is String && rawBirth.trim().isNotEmpty) {
      if (rawBirth.contains('/')) {
        final parts = rawBirth.split('/');

        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);

          if (day != null && month != null && year != null) {
            birthDate = DateTime(year, month, day);
          }
        }
      } else {
        birthDate = DateTime.tryParse(rawBirth);
      }
    }

    int? age;

    if (birthDate != null) {
      final now = DateTime.now();
      age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
    } else {
      final dynamic rawAge = data['idade'] ?? data['age'];
      if (rawAge is int) {
        age = rawAge;
      } else if (rawAge is String) {
        age = int.tryParse(rawAge);
      }
    }

    if (age != null) {
      return '$age anos';
    }

    return 'Não informado.';
  }

  // ============================================================
  // BUILD PRINCIPAL
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final String? targetUid = widget.uid;

    if (targetUid == null || targetUid.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'Não foi possível carregar o perfil.',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 16,
              color: Color(0xFF555555),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _fetchUserData(targetUid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == null) {
              return const Center(
                child: Text(
                  'Perfil não encontrado.',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 16,
                    color: Color(0xFF555555),
                  ),
                ),
              );
            }

            final data = snapshot.data!;

            final String name = data['name'] ?? data['nome'] ?? 'Usuário';
            final String bio =
                data['bio'] ?? data['biografia'] ?? data['sobre'] ?? '';
            final String ageText = _getAgeText(data);
            final String city =
                data['city'] ?? data['cidade'] ?? 'Não informada';

            final bool isOnline = data['isOnline'] is bool
                ? data['isOnline'] as bool
                : false;

            final String avatarPath = data['avatarPath'] ??
                data['foto'] ??
                'assets/avatars/default_profile_image.png';

            final List<String> allInterests = _extractInterestsList(data);

            final chosenInterests = allInterests
                .where((item) => _isPredefinedInterest(item))
                .toList();

            final addedInterests = allInterests
                .where((item) => !_isPredefinedInterest(item))
                .toList();

            // Cálculo dinâmico de seguidores
            final List<dynamic> followerIds = data['followerIds'] ?? [];
            final int followersCount = data['followersCount'] is int
                ? data['followersCount'] as int
                : followerIds.length;

            final List<dynamic> followingIds = data['followingIds'] ?? [];
            final int followingCount = data['followingCount'] is int
                ? data['followingCount'] as int
                : followingIds.length;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // CABEÇALHO
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.maybePop(context),
                        child: Image.asset(
                          'assets/icons/navigation/back_icon.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.arrow_back_ios_new,
                              size: 18,
                              color: Color(0xFF033B63),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF555555),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isOnline
                              ? const Color(0xFF6BBE66)
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // FOTO + SEGUIDORES
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: const Color(0xFFEEEEEE),
                        backgroundImage: AssetImage(avatarPath),
                        child: avatarPath.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 45,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      InkWell(
                        onTap: () => _showUsersListModal('Seguidores', followerIds),
                        borderRadius: BorderRadius.circular(8),
                        child: _buildStatColumn(
                          'Seguidores',
                          followersCount,
                        ),
                      ),
                      InkWell(
                        onTap: () => _showUsersListModal('Seguindo', followingIds),
                        borderRadius: BorderRadius.circular(8),
                        child: _buildStatColumn(
                          'Seguindo',
                          followingCount,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // BOTÕES DE AÇÃO
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFollowing
                                ? const Color(0xFF9AA7B2)
                                : const Color(0xFF0D3B66),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: _isLoadingFollowStatus || _isUpdatingFollow
                            ? null
                            : () {
                                if (_isFollowing) {
                                  _confirmUnfollow(targetUid, name);
                                } else {
                                  _toggleFollow(targetUid);
                                }
                              },
                          child: _isUpdatingFollow
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isFollowing ? 'Seguindo' : 'Seguir',
                                  style: const TextStyle(
                                    fontFamily: 'Raleway',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D3B66),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: _isOpeningChat
                              ? null
                              : () => _openChatWithUser(targetUid, name, avatarPath),
                          child: _isOpeningChat
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Mensagens',
                                  style: TextStyle(
                                    fontFamily: 'Raleway',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // SOBRE MIM
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sobre mim:',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D3B66),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          bio.isEmpty ? 'Nenhuma biografia adicionada.' : bio,
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 14,
                            height: 1.4,
                            color: bio.isEmpty ? Colors.grey : Colors.black87,
                            fontStyle: bio.isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Idade:',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D3B66),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ageText,
                          style: const TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Cidade:',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D3B66),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          city,
                          style: const TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // INTERESSES ESCOLHIDOS
                  _buildChosenInterestsSection(
                    title: 'Interesses Escolhidos',
                    icon: Icons.check_circle,
                    items: chosenInterests,
                  ),

                  const SizedBox(height: 20),

                  // INTERESSES ADICIONADOS
                  _buildAddedInterestsSection(
                    title: 'Interesses Adicionados',
                    icon: Icons.add_circle,
                    items: addedInterests,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    int number,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Raleway',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D3B66),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$number',
          style: const TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildChosenInterestsSection({
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 12,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF0D3B66),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D3B66),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 0.8,
            color: Color(0xFF8B8B8B),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: items.isEmpty
                ? const Text(
                    'Nenhum interesse pré-definido selecionado.',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      final titleStr = items[index];
                      final imagePath = _getIconPath(titleStr);
                      return _buildInterestCardWithIcon(titleStr, imagePath);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestCardWithIcon(
    String title,
    String? imagePath,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0D3B66),
          width: 1.8,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imagePath != null)
            Image.asset(
              imagePath,
              height: 36,
              width: 36,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.extension,
                  size: 32,
                  color: Color(0xFF0D3B66),
                );
              },
            )
          else
            const Icon(
              Icons.star,
              size: 32,
              color: Color(0xFF0D3B66),
            ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Raleway',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              height: 1.1,
              color: Color(0xFF0D3B66),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddedInterestsSection({
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 12,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF0D3B66),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D3B66),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 0.8,
            color: Color(0xFF8B8B8B),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: items.isEmpty
                ? const Text(
                    'Nenhum interesse adicionado.',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: items.map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF0D3B66),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontFamily: 'Raleway',
                            color: Color(0xFF0D3B66),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}