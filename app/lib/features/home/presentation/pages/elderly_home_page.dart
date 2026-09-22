import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/custom_footer.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../../profile/presentation/pages/public_profile_page.dart';

class ElderlyHomePage extends StatefulWidget {
  const ElderlyHomePage({super.key});

  @override
  State<ElderlyHomePage> createState() => _ElderlyHomePageState();
}

// Mapeamento de exibições amigáveis para cidades
const Map<String, String> _cityDisplayNames = {
  'Americana': 'Americana',
  'Campinas': 'Campinas',
  'Limeira': 'Limeira',
  'SantaBarbara': 'Santa Bárbara',
  'Sumare': 'Sumaré',
};

class _ElderlyHomePageState extends State<ElderlyHomePage> {
  final TextEditingController _searchController = TextEditingController();

  String _userFirstName = '';
  String _userLastName = '';
  bool _isLoadingName = true;

  final Set<String> _followingFriends = {};
  final Set<String> _joinedGroups = {};

  List<Map<String, dynamic>> _allFriendSuggestions = [];
  bool _isLoadingSuggestions = true;

  // Controle de estado dos filtros
  String? _selectedCity;
  String? _selectedHobby;
  String? _selectedAgeRange; // Ex: '60-70', '70-80', '80+'

  // Lista de todos os interesses pré-definidos do sistema
  final List<String> _predefinedInterestsList = const [
    'Dominó',
    'Jogo de cartas',
    'Jogos de tabuleiro',
    'Tricô/Crochê',
    'Caminhada',
    'Dança',
    'Artesanato',
    'Jardinagem',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchFriendSuggestions();
  }

  // ============================================================
  // BUSCAR DADOS DO USUÁRIO LOGADO
  // ============================================================

  Future<void> _fetchUserData() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        if (mounted) {
          setState(() {
            _isLoadingName = false;
          });
        }
        return;
      }

      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('idosos')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final Map<String, dynamic> data =
            userDoc.data() as Map<String, dynamic>;

        final String rawName = _getName(data);

        if (rawName.isNotEmpty) {
          final List<String> nameParts =
              rawName.trim().split(RegExp(r'\s+'));

          if (mounted) {
            setState(() {
              _userFirstName = nameParts.first;
              _userLastName =
                  nameParts.length > 1 ? nameParts.last : '';
              _isLoadingName = false;
            });
          }

          return;
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

  // ============================================================
  // BUSCAR SUGESTÕES DE AMIZADE
  // ============================================================

  Future<void> _fetchFriendSuggestions() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        if (mounted) {
          setState(() {
            _isLoadingSuggestions = false;
          });
        }
        return;
      }

      final DocumentSnapshot currentUserDoc =
          await FirebaseFirestore.instance
              .collection('idosos')
              .doc(currentUser.uid)
              .get();

      if (!currentUserDoc.exists || currentUserDoc.data() == null) {
        if (mounted) {
          setState(() {
            _isLoadingSuggestions = false;
          });
        }
        return;
      }

      final Map<String, dynamic> currentUserData =
          currentUserDoc.data() as Map<String, dynamic>;

      final String currentCity =
          _getCity(currentUserData).toLowerCase().trim();

      final List<String> currentInterests = _getInterests(currentUserData);

      final Set<String> currentInterestKeys = currentInterests
          .map((interest) => _normalizeText(interest))
          .where((interest) => interest.isNotEmpty)
          .toSet();

      final QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('idosos')
          .get();

      final List<Map<String, dynamic>> suggestions = [];

      for (final DocumentSnapshot doc in usersSnapshot.docs) {
        if (doc.id == currentUser.uid) {
          continue;
        }

        final dynamic rawData = doc.data();
        if (rawData == null) continue;

        final Map<String, dynamic> userData = rawData as Map<String, dynamic>;

        final String name = _getName(userData);
        final String city = _getCity(userData);
        final List<String> interests = _getInterests(userData);

        final List<String> commonInterests = [];
        for (final String interest in interests) {
          final String normalizedInterest = _normalizeText(interest);
          if (currentInterestKeys.contains(normalizedInterest)) {
            commonInterests.add(interest);
          }
        }

        final bool sameCity = currentCity.isNotEmpty &&
            city.isNotEmpty &&
            _normalizeText(currentCity) == _normalizeText(city);

        final String birthDate = _getBirthDate(userData);
        final int? age = _calculateAge(birthDate);
        final String avatarPath = _getAvatarPath(userData);

        int score = commonInterests.length * 2;
        if (sameCity) {
          score += 1;
        }

        suggestions.add({
          'id': doc.id,
          'name': name.isEmpty ? 'Usuário' : name,
          'city': city,
          'interests': interests,
          'commonInterests': commonInterests,
          'sameCity': sameCity,
          'age': age,
          'avatarPath': avatarPath,
          'score': score,
        });
      }

      suggestions.sort((a, b) {
        final int scoreA = (a['score'] ?? 0) as int;
        final int scoreB = (b['score'] ?? 0) as int;
        return scoreB.compareTo(scoreA);
      });

      if (mounted) {
        setState(() {
          _allFriendSuggestions = List<Map<String, dynamic>>.from(suggestions);
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      debugPrint('ERRO AO BUSCAR SUGESTÕES: $e');

      if (mounted) {
        setState(() {
          _isLoadingSuggestions = false;
        });
      }
    }
  }

  // ============================================================
  // LISTA FILTRADA DE AMIGOS
  // ============================================================

  List<Map<String, dynamic>> get _filteredFriendSuggestions {
    final String query = _normalizeText(_searchController.text);

    return _allFriendSuggestions.where((friend) {
      final String name = _normalizeText((friend['name'] ?? '').toString());
      final String city = _normalizeText((friend['city'] ?? '').toString());
      final List<String> interests = _convertInterests(friend['interests']);
      final int? age = friend['age'] as int?;

      final bool matchesQuery = query.isEmpty ||
          name.contains(query) ||
          city.contains(query) ||
          interests.any((i) => _normalizeText(i).contains(query));

      final bool matchesCity = _selectedCity == null ||
          _normalizeText(city) == _normalizeText(_selectedCity!);

      final bool matchesHobby = _selectedHobby == null ||
          interests.any((i) =>
              _normalizeText(i).contains(_normalizeText(_selectedHobby!)) ||
              _normalizeText(_selectedHobby!).contains(_normalizeText(i)));

      bool matchesAge = true;
      if (_selectedAgeRange != null && age != null) {
        if (_selectedAgeRange == '60-70') {
          matchesAge = age >= 60 && age <= 70;
        } else if (_selectedAgeRange == '70-80') {
          matchesAge = age > 70 && age <= 80;
        } else if (_selectedAgeRange == '80+') {
          matchesAge = age > 80;
        }
      }

      return matchesQuery && matchesCity && matchesHobby && matchesAge;
    }).toList();
  }

  // ============================================================
  // PEGAR DADOS E NORMALIZAÇÃO
  // ============================================================

  String _getName(Map<String, dynamic> data) {
    final dynamic value =
        data['nome'] ?? data['name'] ?? data['Nome'] ?? data['Name'];
    return value == null ? '' : value.toString().trim();
  }

  String _getCity(Map<String, dynamic> data) {
    final dynamic value =
        data['cidade'] ?? data['city'] ?? data['Cidade'] ?? data['City'];
    return value == null ? '' : value.toString().trim();
  }

  List<String> _getInterests(Map<String, dynamic> data) {
    dynamic interestsData =
        data['interesses'] ?? data['interests'] ?? data['Interesses'] ?? data['Interests'];

    if (interestsData is String) {
      final String value = interestsData.trim();
      if (value.isEmpty) return [];
      return value
          .split(',')
          .map((interest) => interest.trim())
          .where((interest) => interest.isNotEmpty)
          .toList();
    }

    if (interestsData is List) {
      return interestsData
          .map((interest) => interest.toString().trim())
          .where((interest) => interest.isNotEmpty)
          .toList();
    }

    return [];
  }

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

  String _getBirthDate(Map<String, dynamic> data) {
    final dynamic value = data['data de nascimento'] ??
        data['dataDeNascimento'] ??
        data['data_nascimento'] ??
        data['birthDate'] ??
        data['nascimento'] ??
        data['Nascimento'];
    return value == null ? '' : value.toString().trim();
  }

  String _getAvatarPath(Map<String, dynamic> data) {
    final dynamic value = data['avatarPath'] ??
        data['avatar'] ??
        data['foto'] ??
        data['fotoPerfil'] ??
        data['photoURL'] ??
        data['photoUrl'];

    if (value == null || value.toString().trim().isEmpty) {
      return 'assets/avatars/default_profile_image.png';
    }
    return value.toString().trim();
  }

  int? _calculateAge(String birthDate) {
    if (birthDate.isEmpty) return null;

    try {
      String value = birthDate.trim();
      if (value.contains('/')) {
        final List<String> parts = value.split('/');
        if (parts.length == 3) {
          final int day = int.parse(parts[0]);
          final int month = int.parse(parts[1]);
          final int year = int.parse(parts[2]);
          final DateTime birth = DateTime(year, month, day);
          return _calculateAgeFromDate(birth);
        }
      }

      if (value.contains('-')) {
        final DateTime? birth = DateTime.tryParse(value);
        if (birth != null) return _calculateAgeFromDate(birth);
      }
    } catch (e) {
      debugPrint('Erro ao calcular idade: $e');
    }

    return null;
  }

  int _calculateAgeFromDate(DateTime birth) {
    final DateTime today = DateTime.now();
    int age = today.year - birth.year;
    if (today.month < birth.month ||
        (today.month == birth.month && today.day < birth.day)) {
      age--;
    }
    return age;
  }

  List<String> _convertInterests(dynamic interestsData) {
    if (interestsData is String) {
      if (interestsData.trim().isEmpty) return [];
      return interestsData
          .split(',')
          .map((interest) => interest.trim())
          .where((interest) => interest.isNotEmpty)
          .toList();
    }

    if (interestsData is! List) return [];

    return interestsData
        .map((interest) => interest.toString().trim())
        .where((interest) => interest.isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final String displayName =
        _isLoadingName ? '...' : '$_userFirstName $_userLastName'.trim();

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
                  _buildHeader(
                    context,
                    displayName.isEmpty ? 'Usuário' : displayName,
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: -26,
                    child: CustomSearchBar(
                      hintText: 'Pesquisar amigos',
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
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
      bottomNavigationBar: const CustomFooter(
        currentIndex: 0,
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

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
                  Navigator.pushNamed(
                    context,
                    AppRoutes.notifications,
                  );
                },
                child: Image.asset(
                  'assets/images/commun/notification_icon.png',
                  height: 21,
                  width: 21,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.help,
                  );
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
                  padding: const EdgeInsets.only(bottom: 56),
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
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  height: 110,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTROS
  // ============================================================

  Widget _buildFiltersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildAddFilterButton(),

            if (_selectedCity != null) ...[
              const SizedBox(width: 8),
              _buildActiveFilterChip(
                label: _cityDisplayNames[_selectedCity] ?? _selectedCity!,
                onRemove: () {
                  setState(() {
                    _selectedCity = null;
                  });
                },
              ),
            ],

            if (_selectedHobby != null) ...[
              const SizedBox(width: 8),
              _buildActiveFilterChip(
                label: _selectedHobby!,
                onRemove: () {
                  setState(() {
                    _selectedHobby = null;
                  });
                },
              ),
            ],

            if (_selectedAgeRange != null) ...[
              const SizedBox(width: 8),
              _buildActiveFilterChip(
                label: '$_selectedAgeRange anos',
                onRemove: () {
                  setState(() {
                    _selectedAgeRange = null;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddFilterButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: _openFilterMenu,
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Text(
            'Filtrar',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF033B63),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF033B63),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF033B63),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MENU DE FILTROS (BOTTOM SHEET)
  // ============================================================

  Future<void> _openFilterMenu() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 8,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- CIDADE ---
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Cidade',
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF033B63),
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('Americana', style: TextStyle(fontFamily: 'Raleway')),
                    onTap: () {
                      setState(() => _selectedCity = 'Americana');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Campinas', style: TextStyle(fontFamily: 'Raleway')),
                    onTap: () {
                      setState(() => _selectedCity = 'Campinas');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Limeira', style: TextStyle(fontFamily: 'Raleway')),
                    onTap: () {
                      setState(() => _selectedCity = 'Limeira');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Santa Bárbara', style: TextStyle(fontFamily: 'Raleway')),
                    onTap: () {
                      setState(() => _selectedCity = 'SantaBarbara');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Sumaré', style: TextStyle(fontFamily: 'Raleway')),
                    onTap: () {
                      setState(() => _selectedCity = 'Sumare');
                      Navigator.pop(context);
                    },
                  ),

                  const Divider(),

                  // --- HOBBIES (TODOS OS 8 INTERESSES PRÉ-DEFINIDOS) ---
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Hobbies / Interesses',
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF033B63),
                      ),
                    ),
                  ),
                  ..._predefinedInterestsList.map((hobby) {
                    return ListTile(
                      title: Text(hobby, style: const TextStyle(fontFamily: 'Raleway')),
                      onTap: () {
                        setState(() => _selectedHobby = hobby);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),

                  const Divider(),

                  // --- FAIXA ETÁRIA ---
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Faixa Etária',
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF033B63),
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('60 a 70 anos', style: TextStyle(fontFamily: 'Raleway')),
                    onTap: () {
                      setState(() => _selectedAgeRange = '60-70');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('70 a 80 anos', style: TextStyle(fontFamily: 'Raleway')),
                    onTap: () {
                      setState(() => _selectedAgeRange = '70-80');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Mais de 80 anos', style: TextStyle(fontFamily: 'Raleway')),
                    onTap: () {
                      setState(() => _selectedAgeRange = '80+');
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SEÇÃO DE AMIGOS
  // ============================================================

  Widget _buildFriendsSection() {
    final filteredList = _filteredFriendSuggestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sugestões de amizades:',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Pessoas com interesses semelhantes',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoadingSuggestions)
          const SizedBox(
            height: 235,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (filteredList.isEmpty)
          const SizedBox(
            height: 100,
            child: Center(
              child: Text(
                'Nenhuma sugestão encontrada',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 235,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> friend = filteredList[index];
                return _buildFriendCard(friend);
              },
            ),
          ),
      ],
    );
  }

  // ============================================================
  // CARD DE AMIGO
  // ============================================================

  Widget _buildFriendCard(Map<String, dynamic> friend) {
    final String id = (friend['id'] ?? '').toString();
    final String name = (friend['name'] ?? 'Usuário').toString();
    final bool isFollowing = _followingFriends.contains(id);
    final int? age = friend['age'] as int?;
    final List<String> commonInterests =
        _convertInterests(friend['commonInterests']);
    final String city = (friend['city'] ?? '').toString();

    String description;
    if (age != null && commonInterests.isNotEmpty) {
      description =
          '$age anos, gosta de ${commonInterests.take(2).join(' e ')}';
    } else if (age != null && city.isNotEmpty) {
      description = '$age anos, mora em $city';
    } else if (age != null) {
      description = '$age anos';
    } else if (city.isNotEmpty) {
      description = 'Mora em $city';
    } else {
      description = 'Possível novo amigo';
    }

    return GestureDetector(
      onTap: () {
        if (id.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PublicProfilePage(uid: id),
            ),
          );
        }
      },
      child: Container(
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
                  child: _buildFriendAvatar(friend['avatarPath']),
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
                    _followingFriends.remove(id);
                  } else {
                    _followingFriends.add(id);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // AVATAR
  // ============================================================

  Widget _buildFriendAvatar(dynamic avatarPath) {
    final String path = (avatarPath ?? 'assets/avatars/default_profile_image.png')
        .toString();

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _defaultFriendAvatar(),
      );
    }

    return Image.asset(
      path,
      width: 72,
      height: 72,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _defaultFriendAvatar(),
    );
  }

  Widget _defaultFriendAvatar() {
    return const CircleAvatar(
      radius: 36,
      backgroundColor: Color(0xFFDCDCDC),
      child: Icon(
        Icons.person,
        size: 44,
        color: Colors.white,
      ),
    );
  }

  // ============================================================
  // SEÇÃO DE GRUPOS
  // ============================================================

  Widget _buildGroupsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sugestões de Grupos:',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Grupos baseados nos seus interesses',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 215,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildGroupCard('Yoga com os Amigos'),
              _buildGroupCard('Dia de Caminhar'),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CARD DE GRUPO
  // ============================================================

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
                  errorBuilder: (context, error, stackTrace) =>
                      const CircleAvatar(
                    radius: 36,
                    backgroundColor: Color(0xFFDCDCDC),
                    child: Icon(
                      Icons.group,
                      size: 40,
                      color: Colors.white,
                    ),
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

  // ============================================================
  // BOTÃO
  // ============================================================

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
          backgroundColor:
              isActive ? const Color(0xFF033B63) : const Color(0xFF9ED1FF),
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