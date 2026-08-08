import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/custom_footer.dart';
import '../../../../core/widgets/custom_search_bar.dart';

class ElderlyHomePage extends StatefulWidget {
  const ElderlyHomePage({super.key});

  @override
  State<ElderlyHomePage> createState() => _ElderlyHomePageState();
}

class _ElderlyHomePageState extends State<ElderlyHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final bool _hasUnreadNotifications = true;

  String _userFirstName = '';
  String _userLastName = '';
  bool _isLoadingName = true;

  // Controle de estado para os botões de seguir/participar
  final Set<String> _followingFriends = {};
  final Set<String> _joinedGroups = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('idosos')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          final String rawName = data['name'] ?? '';

          if (rawName.isNotEmpty) {
            List<String> nameParts = rawName.trim().split(RegExp(r'\s+'));

            setState(() {
              _userFirstName = nameParts.first;
              _userLastName = nameParts.length > 1 ? nameParts.last : '';
              _isLoadingName = false;
            });
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar dados do idoso: $e');
    }

    if (mounted) {
      setState(() {
        _isLoadingName = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String displayName = _isLoadingName
        ? '...'
        : '$_userFirstName $_userLastName'.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildHeader(context, displayName.isEmpty ? 'Usuário' : displayName),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: -26,
                    child: CustomSearchBar(
                      hintText: 'Pesquisar amigos',
                      controller: _searchController,
                      onChanged: (text) {
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _buildFiltersSection(),
              const SizedBox(height: 24),
              _buildFriendsSection(),
              const SizedBox(height: 24),
              _buildGroupsSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomFooter(currentIndex: 0),
    );
  }

  Widget _buildHeader(BuildContext context, String displayName) {
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
                    // if (_hasUnreadNotifications)
                    //   Positioned(
                    //     right: 2,
                    //     top: 2,
                    //     child: Container(
                    //       width: 10,
                    //       height: 10,
                    //       decoration: BoxDecoration(
                    //         color: const Color(0xFF62B6CB),
                    //         shape: BoxShape.circle,
                    //         border: Border.all(color: const Color(0xFF033B63), width: 1.5),
                    //       ),
                    //     ),
                    //   ),
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
                  padding: const EdgeInsets.only(bottom: 56.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, $displayName!',
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Pronto para praticar\nseus hobbies?',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Image.asset(
                'assets/images/elderly/home_banner.png',
                height: 135,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox(height: 110),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildFilterChip('Cidade'),
          const SizedBox(width: 10),
          _buildFilterChip('Hobbies'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Raleway',
          color: Color(0xFF033B63),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  /// Seção de Amigos
  Widget _buildFriendsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sugestões de amizades:',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Pessoas com interesses semelhantes',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 235,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFriendCard('Joaquim Martins', '75 anos, fã de\nmúsica antiga'),
                _buildFriendCard('Fátima Rosa', '70 anos, fã de\njardinagem'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Seção de Grupos
  Widget _buildGroupsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sugestões de Grupos:',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Grupos baseados nos seus interesses',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 215,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildGroupCard('Yoga com os Amigos'),
                _buildGroupCard('Dia de Caminhar'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card de Amigo
  Widget _buildFriendCard(String name, String description) {
    final bool isFollowing = _followingFriends.contains(name);

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/avatars/default_profile_image.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                    radius: 36,
                    backgroundColor: Color(0xFFDCDCDC),
                    child: Icon(Icons.person, size: 44, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          _buildActionButton(
            label: isFollowing ? 'Seguindo' : 'Seguir',
            isActive: isFollowing,
            onPressed: () {
              setState(() {
                if (isFollowing) {
                  _followingFriends.remove(name);
                } else {
                  _followingFriends.add(name);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  /// Card de Grupo
  Widget _buildGroupCard(String title) {
    final bool isJoined = _joinedGroups.contains(title);

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/avatars/default_group_image.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                    radius: 36,
                    backgroundColor: Color(0xFFDCDCDC),
                    child: Icon(Icons.group, size: 40, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF222222),
                ),
              ),
            ],
          ),
          _buildActionButton(
            label: isJoined ? 'Participando' : 'Participar',
            isActive: isJoined,
            onPressed: () {
              setState(() {
                if (isJoined) {
                  _joinedGroups.remove(title);
                } else {
                  _joinedGroups.add(title);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  /// Botão reutilizável menor com troca de cores
  Widget _buildActionButton({
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 32,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? const Color(0xFF033B63) : const Color(0xFF9ED1FF),
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Raleway',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : const Color(0xFF033B63),
          ),
        ),
      ),
    );
  }
}