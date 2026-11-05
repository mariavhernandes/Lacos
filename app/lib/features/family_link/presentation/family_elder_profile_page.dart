import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/custom_footer.dart';
import '../services/family_link_service.dart';

enum FamilyElderProfileSection { linkInfo, interests, friends }

class FamilyElderProfilePage extends StatefulWidget {
  const FamilyElderProfilePage({
    super.key,
    required this.section,
    this.auth,
    this.firestore,
  });

  final FamilyElderProfileSection section;
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  static List<String> extractInterestsForDisplay(dynamic rawInterests) {
    if (rawInterests is List) {
      return rawInterests
          .map((interest) => interest.toString().trim())
          .where((interest) => interest.isNotEmpty)
          .toList();
    }
    if (rawInterests is Map) {
      return rawInterests.values
          .map((interest) => interest.toString().trim())
          .where((interest) => interest.isNotEmpty)
          .toList();
    }
    if (rawInterests is String && rawInterests.trim().isNotEmpty) {
      return rawInterests
          .split(',')
          .map((interest) => interest.trim())
          .where((interest) => interest.isNotEmpty)
          .toList();
    }
    return [];
  }

  static String titleForSection(
    FamilyElderProfileSection section,
    String elderName,
  ) {
    return switch (section) {
      FamilyElderProfileSection.linkInfo => 'Informações do vínculo',
      FamilyElderProfileSection.interests => 'Interesses de $elderName',
      FamilyElderProfileSection.friends => 'Amigos de $elderName',
    };
  }

  @override
  State<FamilyElderProfilePage> createState() =>
      _FamilyElderProfilePageState();
}

class _FamilyElderProfilePageState extends State<FamilyElderProfilePage> {
  late final FirebaseAuth _auth = widget.auth ?? FirebaseAuth.instance;
  late final FirebaseFirestore _firestore =
      widget.firestore ?? FirebaseFirestore.instance;

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

  bool _showingFollowers = true;

  late final Future<_FamilyElderPageData> _pageData = _loadPageData();

  Future<_FamilyElderPageData> _loadPageData() async {
    final familyUid = _auth.currentUser?.uid;

    // DIAGNÓSTICO
    debugPrint('========== DIAGNÓSTICO DO PERFIL ==========');
    debugPrint('UID logado: $familyUid');

    if (familyUid == null) return const _FamilyElderPageData();

    final familySnapshot =
        await _firestore.collection('familiares').doc(familyUid).get();

    if (!familySnapshot.exists) return const _FamilyElderPageData();

    final familyData = familySnapshot.data() ?? <String, dynamic>{};
    final linkStatus = familyData['familyLinkStatus']?.toString() ?? 'none';

    final elderData = await FamilyLinkService(
      firestore: _firestore,
      auth: _auth,
    ).getActiveElderForFamily(familyUid: familyUid);

    final elderUid = elderData?['uid']?.toString() ?? '';

    // DIAGNÓSTICO
    debugPrint('UID do idoso retornado: $elderUid');
    debugPrint(
      'UID vinculado no familiar: ${familyData['linkedElderUid']}',
    );
    debugPrint(
      'UID do familiar vinculado no idoso: ${elderData?['linkedFamilyUid']}',
    );
    debugPrint('==========================================');

    if (elderData == null ||
        !FamilyLinkService.hasActiveReciprocalLink(
          elderData: elderData,
          familyData: familyData,
          familyUid: familyUid,
          elderUid: elderUid,
        )) {
      return _FamilyElderPageData(linkStatus: linkStatus);
    }

    final interests = widget.section == FamilyElderProfileSection.interests
        ? FamilyElderProfilePage.extractInterestsForDisplay(
            elderData['interests'] ?? elderData['interesses'],
          )
        : const <String>[];

    final followers = widget.section == FamilyElderProfileSection.friends
        ? await _loadSocialProfiles(elderData['followerIds'])
        : const <_FamilySocialProfile>[];
    final following = widget.section == FamilyElderProfileSection.friends
        ? await _loadSocialProfiles(elderData['followingIds'])
        : const <_FamilySocialProfile>[];

    return _FamilyElderPageData(
      linkStatus: linkStatus,
      elderData: elderData,
      interests: interests,
      followers: followers,
      following: following,
      linkedAt: _readLinkDate(familyData, elderData),
    );
  }

  Future<List<_FamilySocialProfile>> _loadSocialProfiles(
    dynamic rawUids,
  ) async {
    if (rawUids is! List) return [];

    final uids = rawUids
        .map((uid) => uid.toString().trim())
        .where((uid) => uid.isNotEmpty)
        .toSet();
    final profiles = <_FamilySocialProfile>[];

    for (final uid in uids) {
      Map<String, dynamic>? profileData;

      try {
        final elderlySnapshot =
            await _firestore.collection('idosos').doc(uid).get();
        if (elderlySnapshot.exists) profileData = elderlySnapshot.data();
      } catch (error) {
        debugPrint('Erro ao carregar perfil idoso $uid: $error');
      }

      if (profileData == null) {
        try {
          final familySnapshot =
              await _firestore.collection('familiares').doc(uid).get();
          if (familySnapshot.exists) profileData = familySnapshot.data();
        } catch (error) {
          debugPrint('Erro ao carregar perfil familiar $uid: $error');
        }
      }

      if (profileData == null) continue;

      final name = (profileData['name'] ?? profileData['nome'] ?? '')
          .toString()
          .trim();
      final rawPhoto = profileData['avatarPath'] ??
          profileData['foto'] ??
          profileData['avatar'] ??
          profileData['foto_url'];
      final photoPath = rawPhoto?.toString().trim();

      profiles.add(
        _FamilySocialProfile(
          uid: uid,
          name: name.isEmpty ? 'Usuário' : name,
          photoPath: photoPath == null || photoPath.isEmpty ? null : photoPath,
        ),
      );
    }

    return profiles;
  }

  DateTime? _readLinkDate(
    Map<String, dynamic> familyData,
    Map<String, dynamic> elderData,
  ) {
    final value = familyData['familyLinkCreatedAt'] ??
        familyData['linkedAt'] ??
        elderData['familyLinkCreatedAt'] ??
        elderData['linkedAt'];

    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<_FamilyElderPageData>(
          future: _pageData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0D3B66),
                ),
              );
            }

            if (snapshot.hasError) {
              debugPrint(
                'Erro ao carregar dados do vínculo: ${snapshot.error}',
              );
              debugPrint('Stack trace: ${snapshot.stackTrace}');

              return _buildMessageScreen(
                'Não foi possível carregar as informações.',
              );
            }

            final pageData = snapshot.data ?? const _FamilyElderPageData();
            final elderName = _elderName(pageData.elderData);
            final title = _title(elderName);

            return Column(
              children: [
                _buildHeader(title),
                Expanded(
                  child: _buildSectionContent(pageData, elderName),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const CustomFooter(
        currentIndex: 3,
        isFamily: true,
      ),
    );
  }

  String _elderName(Map<String, dynamic>? elderData) {
    final name =
        (elderData?['name'] ?? elderData?['fullName'] ?? '').toString().trim();

    return name.isEmpty ? 'idoso' : name;
  }

  String _title(String elderName) {
    return FamilyElderProfilePage.titleForSection(widget.section, elderName);
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Image.asset(
              'assets/icons/navigation/back_icon.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Color(0xFF033B63),
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF777777),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSectionContent(
    _FamilyElderPageData pageData,
    String elderName,
  ) {
    final elderData = pageData.elderData;

    if (elderData == null) {
      if (widget.section == FamilyElderProfileSection.linkInfo) {
        return _buildLinkInfo(pageData);
      }

      final message = pageData.linkStatus == 'blocked'
          ? 'O vínculo familiar está bloqueado.'
          : 'Nenhum idoso com vínculo ativo foi encontrado.';

      return _buildMessage(message);
    }

    return switch (widget.section) {
      FamilyElderProfileSection.linkInfo => _buildLinkInfo(pageData),
      FamilyElderProfileSection.interests => _buildInterests(pageData),
      FamilyElderProfileSection.friends => _buildFriends(pageData),
    };
  }

  Widget _buildLinkInfo(_FamilyElderPageData pageData) {
    final elderData = pageData.elderData;
    final details = elderData == null
        ? <MapEntry<String, String>>[
            MapEntry('Situação do vínculo', _linkStatusLabel(pageData)),
          ]
        : <MapEntry<String, String>>[
            MapEntry('Nome', _elderName(elderData)),
            MapEntry(
              'E-mail',
              (elderData['email']?.toString().trim().isNotEmpty ?? false)
                  ? elderData['email'].toString().trim()
                  : 'Não informado',
            ),
            const MapEntry('Situação do vínculo', 'Ativo'),
            if (pageData.linkedAt != null)
              MapEntry(
                'Data do vínculo',
                _formatDate(pageData.linkedAt!),
              ),
          ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < details.length; index++)
              _buildInfoRow(
                details[index].key,
                details[index].value,
                isLast: index == details.length - 1,
              ),
          ],
        ),
      ),
    );
  }

  String _linkStatusLabel(_FamilyElderPageData pageData) {
    if (pageData.linkStatus == 'blocked') return 'Bloqueado';

    if (pageData.linkStatus == 'none' || pageData.linkStatus.isEmpty) {
      return 'Sem vínculo';
    }

    return 'Vínculo indisponível';
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    required bool isLast,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontFamily: 'Raleway',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D3B66),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Raleway',
              fontSize: 14,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Widget _buildInterests(_FamilyElderPageData pageData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: _buildChosenInterestsSection(
        title: 'Interesses Escolhidos',
        icon: Icons.check_circle,
        items: pageData.interests,
      ),
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
                      final interest = items[index];
                      return _buildInterestCardWithIcon(
                        interest,
                        _interestIcons[interest],
                      );
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

  Widget _buildFriends(_FamilyElderPageData pageData) {
    final profiles = _showingFollowers ? pageData.followers : pageData.following;
    final emptyMessage = _showingFollowers
        ? 'Nenhum seguidor encontrado.'
        : 'O idoso ainda não segue ninguém.';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialStat(
                'Seguidores',
                pageData.followers.length,
                showingFollowers: true,
              ),
              _buildSocialStat(
                'Seguindo',
                pageData.following.length,
                showingFollowers: false,
              ),
            ],
          ),
        ),
        Expanded(
          child: profiles.isEmpty
              ? _buildMessage(emptyMessage)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  itemCount: profiles.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    thickness: 0.8,
                    color: Color(0xFFE5E5E5),
                  ),
                  itemBuilder: (context, index) {
                    final profile = profiles[index];
                    final photoPath = profile.photoPath;
                    ImageProvider<Object>? image;

                    if (photoPath != null) {
                      image = photoPath.startsWith('http')
                          ? NetworkImage(photoPath) as ImageProvider<Object>
                          : AssetImage(photoPath) as ImageProvider<Object>;
                    }

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundImage: image,
                        child: image == null
                            ? const Icon(Icons.person_outline)
                            : null,
                      ),
                      title: Text(
                        profile.name,
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          color: Color(0xFF333333),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSocialStat(
    String label,
    int number, {
    required bool showingFollowers,
  }) {
    return InkWell(
      onTap: () => setState(() => _showingFollowers = showingFollowers),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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

  Widget _buildMessageScreen(String message) {
    return Column(
      children: [
        _buildHeader(_title('idoso')),
        Expanded(child: _buildMessage(message)),
      ],
    );
  }

  Widget _buildMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 15,
            color: Color(0xFF8A8A8A),
          ),
        ),
      ),
    );
  }
}

class _FamilyElderPageData {
  const _FamilyElderPageData({
    this.linkStatus = 'none',
    this.elderData,
    this.interests = const [],
    this.followers = const [],
    this.following = const [],
    this.linkedAt,
  });

  final String linkStatus;
  final Map<String, dynamic>? elderData;
  final List<String> interests;
  final List<_FamilySocialProfile> followers;
  final List<_FamilySocialProfile> following;
  final DateTime? linkedAt;
}

class _FamilySocialProfile {
  const _FamilySocialProfile({
    required this.uid,
    required this.name,
    this.photoPath,
  });

  final String uid;
  final String name;
  final String? photoPath;
}