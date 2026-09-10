import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/widgets/custom_footer.dart';

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
  bool _isFollowing = true;

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

  @override
  Widget build(BuildContext context) {
    final String? targetUid = widget.uid;

    if (targetUid == null || targetUid.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: Text(
            'Não foi possível carregar o perfil.',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 16,
              color: Color(0xFF555555),
            ),
          ),
        ),
        bottomNavigationBar: const CustomFooter(
          currentIndex: 3,
          isFamily: false,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('idosos')
              .doc(targetUid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Não foi possível carregar o perfil.',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 16,
                    color: Color(0xFF555555),
                  ),
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
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

            final data = snapshot.data!.data() as Map<String, dynamic>;

            final String name = data['name']?.toString() ?? '';
            final String bio = data['bio']?.toString() ?? '';
            final String ageRange = data['ageRange']?.toString() ?? '';
            final String city = data['city']?.toString() ?? '';
            final bool isOnline = data['isOnline'] == true;
            final String? avatarPath = data['avatarPath']?.toString();

            final List<dynamic> interests =
                data['interests'] is List
                    ? data['interests'] as List
                    : [];

            final int followersCount =
                data['followersCount'] is int
                    ? data['followersCount'] as int
                    : 0;

            final int followingCount =
                data['followingCount'] is int
                    ? data['followingCount'] as int
                    : 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ==================================================
                  // CABEÇALHO
                  // ==================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Icon(
                              Icons.arrow_back_ios_new,
                              size: 18,
                              color: Color(0xFF033B63),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: Text(
                          name,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF555555),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: Text(
                          isOnline ? 'Online' : 'Offline',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isOnline
                                ? const Color(0xFF6BBE66)
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // FOTO + SEGUIDORES
                  // ==================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFFE0E0E0),
                        backgroundImage:
                            avatarPath != null && avatarPath.isNotEmpty
                                ? AssetImage(avatarPath)
                                : null,
                        child: avatarPath == null || avatarPath.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      _buildStatColumn(
                        'Seguidores',
                        followersCount,
                      ),
                      _buildStatColumn(
                        'Seguindo',
                        followingCount,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // BOTÕES
                  // ==================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D3B66),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
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
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D3B66),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          'Mensagens',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

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
                        const SizedBox(height: 8),
                        Text(
                          bio.isNotEmpty ? bio : 'Não informado.',
                          style: const TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 14,
                            height: 1.4,
                            color: Color(0xFF555555),
                          ),
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'Faixa Etária',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D3B66),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ageRange.isNotEmpty
                              ? ageRange
                              : 'Não informado.',
                          style: const TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 14,
                            color: Color(0xFF555555),
                          ),
                        ),

                        const SizedBox(height: 18),

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
                          city.isNotEmpty ? city : 'Não informado.',
                          style: const TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 14,
                            color: Color(0xFF555555),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // INTERESSES
                  // ==================================================
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: 12,
                          ),
                          child: Text(
                            'Interesses',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D3B66),
                            ),
                          ),
                        ),

                        const Divider(
                          height: 1,
                          thickness: 0.8,
                          color: Color(0xFFD0D0D0),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: interests.isEmpty
                              ? const Text(
                                  'Nenhum interesse informado.',
                                  style: TextStyle(
                                    fontFamily: 'Raleway',
                                    fontSize: 14,
                                    color: Color(0xFF555555),
                                  ),
                                )
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  itemCount: interests.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 1.1,
                                  ),
                                  itemBuilder: (context, index) {
                                    final String itemTitle =
                                        interests[index].toString();

                                    final String? iconPath =
                                        _interestIcons[itemTitle];

                                    return _buildInterestCard(
                                      itemTitle,
                                      iconPath,
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),

      // ==============================================================
      // RODAPÉ
      // ==============================================================
      bottomNavigationBar: const CustomFooter(
        currentIndex: 3,
        isFamily: false,
      ),
    );
  }

  // ================================================================
  // ESTATÍSTICAS
  // ================================================================
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
            fontFamily: 'Raleway',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // CARD DE INTERESSE
  // ================================================================
  Widget _buildInterestCard(
    String title,
    String? imagePath,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0D3B66),
          width: 2,
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
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons.star,
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

          const SizedBox(height: 8),

          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Raleway',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              height: 1.1,
              color: Color(0xFF0D3B66),
            ),
          ),
        ],
      ),
    );
  }
}