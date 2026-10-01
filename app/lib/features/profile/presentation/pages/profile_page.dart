import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/widgets/custom_footer.dart';
import 'edit_profile/edit_profile_menu_page.dart';
import 'public_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _currentUser = FirebaseAuth.instance.currentUser;

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
    'Jogos de carta': 'assets/images/commun/card_games.png',
    'Xadrez': 'assets/images/commun/chess.png',
    'Dança': 'assets/images/commun/dancing.png',
    'Jardinagem': 'assets/images/commun/gardening.png',
    'Tricô/Crochê': 'assets/images/commun/knitting.png',
    'Artesanato': 'assets/images/commun/sewing.png',
    'Caminhada': 'assets/images/commun/walking.png',
    'Dominó': 'assets/images/commun/domino.png',
  };

  String _calculateAge(String? birthDateStr) {
    if (birthDateStr == null || birthDateStr.isEmpty) return '--';
    try {
      final parts = birthDateStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final birthDate = DateTime(year, month, day);
        final today = DateTime.now();

        int age = today.year - birthDate.year;
        if (today.month < birthDate.month ||
            (today.month == birthDate.month && today.day < birthDate.day)) {
          age--;
        }
        return age.toString();
      }
    } catch (_) {}
    return '--';
  }

  // ============================================================
  // EXIBIR MODAL DE SEGUIDORES / SEGUINDO
  // ============================================================

  void _showUsersListModal(String title, List<dynamic> userIds) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
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
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D3B66),
                    ),
                  ),
                ),
                Expanded(
                  child: userIds.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum usuário encontrado.',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: userIds.length,
                          itemBuilder: (context, index) {
                            final uidStr = userIds[index].toString();

                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('idosos')
                                  .doc(uidStr)
                                  .get(),
                              builder: (context, snapshot) {
                                Map<String, dynamic>? uData;

                                if (snapshot.hasData && snapshot.data!.exists) {
                                  uData = snapshot.data!.data()
                                      as Map<String, dynamic>?;
                                }

                                if (uData == null) {
                                  return FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection('familiares')
                                        .doc(uidStr)
                                        .get(),
                                    builder: (context, famSnap) {
                                      if (famSnap.hasData &&
                                          famSnap.data!.exists) {
                                        final fData = famSnap.data!.data()
                                            as Map<String, dynamic>?;
                                        return _buildUserTile(uidStr, fData);
                                      }
                                      return _buildUserTile(uidStr, null);
                                    },
                                  );
                                }

                                return _buildUserTile(uidStr, uData);
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

  Widget _buildUserTile(String uidStr, Map<String, dynamic>? uData) {
    final uName = uData?['name'] ?? uData?['nome'] ?? 'Usuário';
    final uAvatar = uData?['avatarPath'] ??
        uData?['foto'] ??
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
          color: Colors.black87, // Nome em preto
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey,
      ),
      onTap: () {
        Navigator.pop(context); // Fechar o modal
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PublicProfilePage(uid: uidStr),
          ),
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sair da Conta',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D3B66),
          ),
        ),
        content: const Text(
          'Tem certeza que deseja sair do aplicativo?',
          style: TextStyle(fontFamily: 'Raleway'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid != null) {
        try {
          await FirebaseFirestore.instance
              .collection('idosos')
              .doc(uid)
              .update({
            'isOnline': false,
            'lastSeen': FieldValue.serverTimestamp(),
          });
        } catch (_) {
          try {
            await FirebaseFirestore.instance
                .collection('familiares')
                .doc(uid)
                .update({
              'isOnline': false,
              'lastSeen': FieldValue.serverTimestamp(),
            });
          } catch (_) {}
        }
      }

      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Usuário não autenticado.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('idosos')
              .doc(_currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                  child: Text('Erro ao carregar dados do perfil.'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                  child: Text('Dados não encontrados na coleção idosos.'));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            final name = data['name'] ?? 'Nome não informado';
            final bio = data['bio'] ?? '';
            final city = data['city'] ?? 'Não informada';
            final avatarPath = data['avatarPath'] ??
                'assets/avatars/default_profile_image.png';

            final List<dynamic> allInterests = data['interests'] ?? [];
            final age = _calculateAge(data['birthDate']);

            // Listas de seguidores e seguindo
            final List<dynamic> followerIds = data['followerIds'] ?? [];
            final int followersCount = data['followersCount'] is int
                ? data['followersCount'] as int
                : followerIds.length;

            final List<dynamic> followingIds = data['followingIds'] ?? [];
            final int followingCount = data['followingCount'] is int
                ? data['followingCount'] as int
                : followingIds.length;

            final chosenInterests = allInterests
                .where(
                    (item) => _predefinedInterests.contains(item.toString()))
                .toList();

            final addedInterests = allInterests
                .where(
                    (item) => !_predefinedInterests.contains(item.toString()))
                .toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF555555),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: const Color(0xFFEEEEEE),
                        backgroundImage: AssetImage(avatarPath),
                      ),
                      _buildStatColumn('Seguidores', followersCount, () {
                        _showUsersListModal('Seguidores', followerIds);
                      }),
                      _buildStatColumn('Seguindo', followingCount, () {
                        _showUsersListModal('Seguindo', followingIds);
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D3B66),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileMenuPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text(
                        'Editar perfil',
                        style: TextStyle(
                            fontFamily: 'Raleway', fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

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
                          bio.isEmpty
                              ? 'Toque em "Editar perfil" para adicionar uma biografia.'
                              : bio,
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
                          '$age anos',
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

                  _buildChosenInterestsSection(
                    title: 'Interesses Escolhidos',
                    icon: Icons.check_circle,
                    items: chosenInterests,
                  ),
                  const SizedBox(height: 20),

                  _buildAddedInterestsSection(
                    title: 'Interesses Adicionados',
                    icon: Icons.add_circle,
                    items: addedInterests,
                  ),
                  const SizedBox(height: 24),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD32F2F),
                        side: const BorderSide(
                            color: Color(0xFFD32F2F), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                      ),
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout,
                          size: 18, color: Color(0xFFD32F2F)),
                      label: const Text(
                        'Sair do aplicativo',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFFD32F2F),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const CustomFooter(
        currentIndex: 3,
        isFamily: false,
      ),
    );
  }

  Widget _buildStatColumn(String label, int number, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
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
        ),
      ),
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
            padding: const EdgeInsets.only(
                left: 16, right: 16, top: 16, bottom: 12),
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
            padding: const EdgeInsets.only(
                left: 16, right: 16, top: 16, bottom: 12),
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