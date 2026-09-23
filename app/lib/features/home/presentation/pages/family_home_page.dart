import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/custom_footer.dart';
import '../../../notifications/data/notification_service.dart';

class FamilyHomePage extends StatefulWidget {
  const FamilyHomePage({super.key});

  @override
  State<FamilyHomePage> createState() => _FamilyHomePageState();
}

class _FamilyHomePageState extends State<FamilyHomePage> {
  String _userFirstName = '';
  String _userLastName = '';
  String _elderlyMonitoredName = 'Idoso vinculado';
  String _elderlyUid = '';
  bool _isLoadingData = true;
  bool _hasUnreadNotifications = false;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _notificationSubscription;

  // Cache para guardar nomes jÃ¡ buscados por UID e evitar chamadas repetidas
  final Map<String, String> _userNameCache = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _listenForUnreadNotifications();
  }

  void _listenForUnreadNotifications() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _notificationSubscription = FamilyNotificationService()
        .unreadNotificationsStream(uid: uid, isElder: false)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() => _hasUnreadNotifications = snapshot.docs.isNotEmpty);
      }
    });
  }

  String _formatFirstAndLastName(String fullName) {
    if (fullName.trim().isEmpty) return fullName;
    List<String> parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first;
    return '${parts.first} ${parts.last}';
  }

  String _formatTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Sem data';
    final DateTime dateTime = timestamp.toDate();
    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) return 'Agora mesmo';
    if (difference.inMinutes < 60) return 'HÃ¡ ${difference.inMinutes}min';
    if (difference.inHours < 24)
      return 'HÃ¡ ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    return 'HÃ¡ ${difference.inDays} ${difference.inDays == 1 ? 'dia' : 'dias'}';
  }

  // Descobre o nome do chat (se for grupo usa groupName, se for pessoa busca pelo UID no Firestore)
  Future<String> _getChatDisplayName(Map<String, dynamic> data) async {
    // 1. Se tiver groupName definido
    if (data['groupName'] != null &&
        data['groupName'].toString().trim().isNotEmpty) {
      return data['groupName'].toString();
    }

    // 2. Se jÃ¡ tiver campo com nome salvo
    if (data['participantName'] != null &&
        data['participantName'].toString().trim().isNotEmpty) {
      return data['participantName'].toString();
    }
    if (data['name'] != null && data['name'].toString().trim().isNotEmpty) {
      return data['name'].toString();
    }

    // 3. Se for conversa individual com array de participantes (UIDs)
    final List<dynamic> participants = data['participants'] ?? [];

    // Procura o ID que seja diferente do ID do idoso monitorado
    String otherUid = '';
    for (var uid in participants) {
      if (uid.toString() != _elderlyUid && uid.toString().isNotEmpty) {
        otherUid = uid.toString();
        break;
      }
    }

    if (otherUid.isEmpty && participants.isNotEmpty) {
      otherUid = participants.first.toString();
    }

    if (otherUid.isNotEmpty) {
      if (_userNameCache.containsKey(otherUid)) {
        return _userNameCache[otherUid]!;
      }

      try {
        // Busca o nome na coleÃ§Ã£o de idosos
        final elderDoc = await FirebaseFirestore.instance
            .collection('idosos')
            .doc(otherUid)
            .get();
        if (elderDoc.exists && elderDoc.data() != null) {
          final eData = elderDoc.data()!;
          final fetchedName = eData['name'] ?? eData['fullName'] ?? 'UsuÃ¡rio';
          _userNameCache[otherUid] = fetchedName.toString();
          return fetchedName.toString();
        }

        // Se nÃ£o achou em idosos, busca na coleÃ§Ã£o de familiares
        final famDoc = await FirebaseFirestore.instance
            .collection('familiares')
            .doc(otherUid)
            .get();
        if (famDoc.exists && famDoc.data() != null) {
          final fData = famDoc.data()!;
          final fetchedName = fData['name'] ?? fData['fullName'] ?? 'UsuÃ¡rio';
          _userNameCache[otherUid] = fetchedName.toString();
          return fetchedName.toString();
        }
      } catch (e) {
        debugPrint('Erro ao buscar nome do participante: $e');
      }
    }

    return 'Conversa';
  }

  String _extractParticipantAvatar(Map<String, dynamic> data) {
    return data['participantAvatar'] ??
        data['avatar'] ??
        data['userPhoto'] ??
        data['photoUrl'] ??
        '';
  }

  Future<void> _fetchUserData() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('familiares')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          final String rawName = data['name'] ?? '';
          final String linkedEmail = data['linkedElderEmail'] ?? '';
          final String linkStatus = data['familyLinkStatus']?.toString() ?? '';

          if (linkStatus == 'blocked') {
            if (mounted) {
              setState(() {
                _userFirstName = rawName.split(' ').first;
                _userLastName = '';
                _elderlyMonitoredName = 'Vínculo bloqueado';
                _isLoadingData = false;
              });
            }
            return;
          }

          String foundElderlyName = 'Idoso vinculado';
          String foundElderUid = '';

          if (linkedEmail.isNotEmpty) {
            final QuerySnapshot elderQuery = await FirebaseFirestore.instance
                .collection('idosos')
                .where('email', isEqualTo: linkedEmail.trim())
                .limit(1)
                .get();

            if (elderQuery.docs.isNotEmpty) {
              final elderDoc = elderQuery.docs.first;
              final elderData = elderDoc.data() as Map<String, dynamic>;
              foundElderUid = elderDoc.id;
              final String rawElderName =
                  elderData['name'] ?? elderData['fullName'] ?? '';
              if (rawElderName.isNotEmpty) {
                foundElderlyName = _formatFirstAndLastName(rawElderName);
              }
            }
          }

          if (rawName.isNotEmpty) {
            List<String> nameParts = rawName.trim().split(RegExp(r'\s+'));

            if (mounted) {
              setState(() {
                _userFirstName = nameParts.first;
                _userLastName = nameParts.length > 1 ? nameParts.last : '';
                _elderlyMonitoredName = foundElderlyName;
                _elderlyUid = foundElderUid;
                _isLoadingData = false;
              });
            }
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar dados do familiar: $e');
    }

    if (mounted) {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String displayName =
        _isLoadingData ? '...' : '$_userFirstName $_userLastName'.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(
                context,
                displayName.isEmpty ? 'UsuÃ¡rio' : displayName,
                _elderlyMonitoredName,
              ),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('chats').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      _isLoadingData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF033B63)),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  // Ordena localmente pela data da Ãºltima mensagem
                  final List<QueryDocumentSnapshot> sortedDocs =
                      List.from(docs);
                  sortedDocs.sort((a, b) {
                    final dataA = a.data() as Map<String, dynamic>;
                    final dataB = b.data() as Map<String, dynamic>;
                    final Timestamp? timeA =
                        dataA['lastMessageTime'] as Timestamp? ??
                            dataA['timestamp'] as Timestamp?;
                    final Timestamp? timeB =
                        dataB['lastMessageTime'] as Timestamp? ??
                            dataB['timestamp'] as Timestamp?;
                    if (timeA == null) return 1;
                    if (timeB == null) return -1;
                    return timeB.compareTo(timeA);
                  });

                  final activeDocs = _elderlyUid.isNotEmpty
                      ? sortedDocs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final List<dynamic> participants =
                              data['participants'] ?? [];
                          final String participantId =
                              data['participantId'] ?? '';
                          return participants.contains(_elderlyUid) ||
                              participantId == _elderlyUid;
                        }).toList()
                      : sortedDocs;

                  final docsToDisplay =
                      activeDocs.isNotEmpty ? activeDocs : sortedDocs;

                  // 1. Total de conversas ativas
                  final int totalChats = docsToDisplay.length;

                  // 2. Busca o nome do primeiro chat para a "Ãšltima InteraÃ§Ã£o"
                  final Future<String> lastInteractionFuture = docsToDisplay
                          .isNotEmpty
                      ? _getChatDisplayName(
                          docsToDisplay.first.data() as Map<String, dynamic>)
                      : Future.value('-');

                  return FutureBuilder<String>(
                    future: lastInteractionFuture,
                    builder: (context, lastInterSnap) {
                      final String rawLastInter = lastInterSnap.data ?? '-';
                      final String lastInteractionUser = rawLastInter != '-'
                          ? _formatFirstAndLastName(rawLastInter)
                          : '-';

                      // 3. Busca o Novo Seguidor
                      return FutureBuilder<QuerySnapshot>(
                        future: _elderlyUid.isNotEmpty
                            ? FirebaseFirestore.instance
                                .collection('idosos')
                                .doc(_elderlyUid)
                                .collection('seguidores')
                                .orderBy('createdAt', descending: true)
                                .limit(1)
                                .get()
                            : null,
                        builder: (context, followerSnap) {
                          String newFollowerName = '-';

                          if (followerSnap.hasData &&
                              followerSnap.data != null &&
                              followerSnap.data!.docs.isNotEmpty) {
                            final followerData = followerSnap.data!.docs.first
                                .data() as Map<String, dynamic>;
                            final rawFollower = followerData['name'] ??
                                followerData['fullName'] ??
                                '';
                            if (rawFollower.isNotEmpty) {
                              newFollowerName =
                                  _formatFirstAndLastName(rawFollower);
                            }
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMetricCardsSection(
                                unreadCount: totalChats,
                                newFollower: newFollowerName,
                                lastInteraction: lastInteractionUser,
                              ),
                              const SizedBox(height: 28),
                              _buildRecentActivitiesSection(docsToDisplay),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomFooter(currentIndex: 0),
    );
  }

  Widget _buildHeader(
      BuildContext context, String displayName, String monitoredName) {
    final double topSafeArea = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF033B63),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: topSafeArea + 12,
        bottom: 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() => _hasUnreadNotifications = false);
                  Navigator.pushNamed(context, AppRoutes.notifications);
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset(
                      'assets/images/commun/notification_icon.png',
                      height: 21,
                      width: 21,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    if (_hasUnreadNotifications)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF62B6CB),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF033B63),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.help);
                },
                child: Image.asset(
                  'assets/images/commun/help_icon.png',
                  height: 25,
                  width: 25,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.help_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OlÃ¡, $displayName!',
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Gerencie as interaÃ§Ãµes\nda $monitoredName.',
                        style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Image.asset(
                'assets/images/family/home_banner_responsible.png',
                height: 135,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox(height: 110),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCardsSection({
    required int unreadCount,
    required String newFollower,
    required String lastInteraction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Conversas',
                value: '$unreadCount ATIVAS',
                assetPath: 'assets/images/family/chat_icon.png',
                fallbackIcon: Icons.chat_bubble_outline,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                title: 'Novo Seguidor',
                value: newFollower,
                assetPath: 'assets/images/family/new_follower.png',
                fallbackIcon: Icons.account_circle_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                title: 'Ãšltima InteraÃ§Ã£o',
                value: lastInteraction,
                assetPath: 'assets/images/family/last_interation_icon.png',
                fallbackIcon: Icons.access_time_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String assetPath,
    required IconData fallbackIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                assetPath,
                width: 15,
                height: 15,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  fallbackIcon,
                  size: 15,
                  color: const Color(0xFF033B63),
                ),
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF033B63),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesSection(List<QueryDocumentSnapshot> docs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Atividades Recentes',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 16),
          if (docs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Nenhuma atividade recente.',
                style: TextStyle(fontFamily: 'Raleway', color: Colors.black45),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length > 5 ? 5 : docs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final Timestamp? timestamp =
                    data['lastMessageTime'] as Timestamp? ??
                        data['timestamp'] as Timestamp?;
                final String avatarUrl = _extractParticipantAvatar(data);

                return FutureBuilder<String>(
                  future: _getChatDisplayName(data),
                  builder: (context, nameSnapshot) {
                    final rawName = nameSnapshot.data ?? 'Carregando...';
                    return _buildActivityCard(
                      name: _formatFirstAndLastName(rawName),
                      timeAgo: _formatTimeAgo(timestamp),
                      avatarUrl: avatarUrl,
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required String name,
    required String timeAgo,
    String avatarUrl = '',
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE0E0E0),
            backgroundImage: avatarUrl.startsWith('http')
                ? NetworkImage(avatarUrl)
                : (avatarUrl.isNotEmpty
                    ? AssetImage(avatarUrl) as ImageProvider
                    : null),
            child: avatarUrl.isEmpty
                ? const Icon(Icons.person, size: 30, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                timeAgo,
                style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 12,
                  color: Colors.black38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
