import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  final Set<String> _predefinedInterests = {
    'Jogos de tabuleiro',
    'Jogos de carta',
    'Xadrez',
    'Dança',
    'Jardinagem',
    'Tricô/Crochê',
    'Artesanato',
    'Caminhada',
    'Dominó',
  };

  final Map<String, String> _interestIcons = {
    'Jogos de tabuleiro': 'assets/images/commun/card_games.png',
    'Jogo de cartas': 'assets/images/commun/card_games.png',
    'Jogos de carta': 'assets/images/commun/card_games.png',
    'Xadrez': 'assets/images/commun/chess.png',
    'Dança': 'assets/images/commun/dancing.png',
    'Jardinagem': 'assets/images/commun/gardening.png',
    'Tricô/Crochê': 'assets/images/commun/knitting.png',
    'Artesanato': 'assets/images/commun/sewing.png',
    'Caminhada': 'assets/images/commun/walking.png',
    'Dominó': 'assets/images/commun/domino.png',
  };

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

            if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
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
            final String city = data['city'] ?? data['cidade'] ?? 'Não informada';
            final bool isOnline =
                data['isOnline'] is bool ? data['isOnline'] as bool : false;
            final String avatarPath = data['avatarPath'] ??
                data['foto'] ??
                'assets/avatars/default_profile_image.png';

            final List<dynamic> allInterests = data['interests'] is List
                ? data['interests'] as List
                : (data['interesses'] is List
                    ? data['interesses'] as List
                    : []);

            final chosenInterests = allInterests
                .where((item) => _predefinedInterests.contains(item.toString()))
                .toList();

            final addedInterests = allInterests
                .where((item) => !_predefinedInterests.contains(item.toString()))
                .toList();

            final int followersCount = data['followersCount'] is int
                ? data['followersCount'] as int
                : (data['seguidores'] is int ? data['seguidores'] as int : 0);

            final int followingCount = data['followingCount'] is int
                ? data['followingCount'] as int
                : (data['seguindo'] is int ? data['seguindo'] as int : 0);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ==================================================
                  // CABEÇALHO COM NOME E STATUS ONLINE
                  // ==================================================
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.maybePop(context);
                        },
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

                  // ==================================================
                  // FOTO + SEGUIDORES
                  // ==================================================
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
                      _buildStatColumn('Seguidores', followersCount),
                      _buildStatColumn('Seguindo', followingCount),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // BOTÕES
                  // ==================================================
                  Row(
                    children: [
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
                          onPressed: () {
                            setState(() {
                              _isFollowing = !_isFollowing;
                            });
                          },
                          child: Text(
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
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
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

                  // ==================================================
                  // SOBRE MIM
                  // ==================================================
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
                            fontStyle: bio.isEmpty ? FontStyle.italic : FontStyle.normal,
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

                  // ==================================================
                  // INTERESSES ESCOLHIDOS
                  // ==================================================
                  _buildChosenInterestsSection(
                    title: 'Interesses Escolhidos',
                    icon: Icons.check_circle,
                    items: chosenInterests,
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // INTERESSES ADICIONADOS
                  // ==================================================
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

  Widget _buildStatColumn(String label, int number) {
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
    required List<dynamic> items,
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
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 12),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF0D3B66)),
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      final titleStr = items[index].toString();
                      final imagePath = _interestIcons[titleStr];
                      return _buildInterestCardWithIcon(titleStr, imagePath);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestCardWithIcon(String title, String? imagePath) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0D3B66), width: 1.8),
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
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.extension,
                size: 32,
                color: Color(0xFF0D3B66),
              ),
            )
          else
            const Icon(
              Icons.star,
              size: 32,
              color: Color(0xFF0D3B66),
            ),
          const SizedBox(height: 4),
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
    required List<dynamic> items,
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
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 12),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF0D3B66)),
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
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF0D3B66), width: 1.5),
                        ),
                        child: Text(
                          item.toString(),
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