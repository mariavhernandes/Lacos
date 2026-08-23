import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/widgets/custom_footer.dart';

class EditProfileMenuPage extends StatefulWidget {
  const EditProfileMenuPage({super.key});

  @override
  State<EditProfileMenuPage> createState() => _EditProfileMenuPageState();
}

class _EditProfileMenuPageState extends State<EditProfileMenuPage> {
  final _currentUser = FirebaseAuth.instance.currentUser;

  // Lista dos caminhos dos avatares disponíveis
  final List<String> _avatars = [
    'assets/avatars/avatar_1.png',
    'assets/avatars/avatar_2.png',
    'assets/avatars/avatar_3.png',
    'assets/avatars/avatar_4.png',
    'assets/avatars/default_profile_image.png',
  ];

  // Método para salvar o avatar selecionado no Firestore
  Future<void> _updateAvatar(String newAvatarPath) async {
    if (_currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('idosos')
          .doc(_currentUser!.uid)
          .update({'avatarPath': newAvatarPath});

      if (mounted) {
        Navigator.pop(context); // Fecha o modal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar atualizado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar avatar: $e')),
        );
      }
    }
  }

  // Modal com a grade de avatares
  void _showAvatarSelectionModal(String currentAvatar) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Escolha seu Avatar',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D3B66),
                ),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                itemCount: _avatars.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final avatar = _avatars[index];
                  final isSelected = avatar == currentAvatar;

                  return GestureDetector(
                    onTap: () => _updateAvatar(avatar),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0D3B66)
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundImage: AssetImage(avatar),
                        backgroundColor: const Color(0xFFEEEEEE),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Usuário não autenticado.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            // CABEÇALHO
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      'assets/icons/navigation/back_icon.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDCEAF5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: Color(0xFF033B63),
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Editar Perfil',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // CONTEÚDO
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('idosos')
                    .doc(_currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  Map<String, dynamic> userData = {};
                  String avatarPath =
                      'assets/avatars/default_profile_image.png';
                  String bio = '';
                  List<String> interests = [];

                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    userData = data;

                    if (data['avatarPath'] != null &&
                        data['avatarPath'].toString().isNotEmpty) {
                      avatarPath = data['avatarPath'].toString();
                    }

                    if (data['bio'] != null) {
                      bio = data['bio'].toString();
                    }

                    if (data['interests'] != null && data['interests'] is List) {
                      interests = (data['interests'] as List)
                          .map((item) => item.toString())
                          .toList();
                    }
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        // FOTO DE PERFIL
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 46,
                                backgroundColor: const Color(0xFFEEEEEE),
                                backgroundImage: AssetImage(avatarPath),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () =>
                                      _showAvatarSelectionModal(avatarPath),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0D3B66),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // MENU ITEMS
                        _buildMenuItem(
                          iconPath:
                              'assets/images/commun/basic_info_icon.png',
                          title: 'Dados básicos',
                          subtitle:
                              'Altere seu nome, cidade e data de nascimento',
                          onTap: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/edit-basic-data',
                              arguments: {
                                'uid': _currentUser!.uid,
                                'initialData': userData,
                              },
                            );

                            if (result == true && mounted) {
                              setState(() {});
                            }
                          },
                        ),
                        _buildDivider(),

                        _buildMenuItem(
                          iconPath: 'assets/images/elderly/about_you.png',
                          title: 'Sobre você',
                          subtitle:
                              'Escreva uma breve biografia sobre sua história',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/edit-about-me',
                              arguments: {
                                'uid': _currentUser!.uid,
                                'initialBio': bio,
                              },
                            );
                          },
                        ),
                        _buildDivider(),

                        // _buildMenuItem(
                        //   iconPath:
                        //       'assets/images/commun/appearance_icon.png',
                        //   title: 'Aparência',
                        //   subtitle:
                        //       'Escolha um novo avatar de perfil para sua conta',
                        //   onTap: () {
                        //     _showAvatarSelectionModal(avatarPath);
                        //   },
                        // ),
                        // _buildDivider(),

                        _buildMenuItem(
                          iconPath: 'assets/images/elderly/interests.png',
                          title: 'Interesses',
                          subtitle:
                              'Selecione e organize suas preferências e hobbies',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/edit-interests',
                              arguments: {
                                'uid': _currentUser!.uid,
                                'currentInterests': interests,
                              },
                            );
                          },
                        ),
                        _buildDivider(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomFooter(
        currentIndex: 3,
        isFamily: false,
      ),
    );
  }

  Widget _buildMenuItem({
    required String iconPath,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 20,
        ),
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: 30,
              height: 30,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.settings,
                size: 28,
                color: Color(0xFF0D3B66),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D3B66),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF0D3B66),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.8,
      indent: 20,
      endIndent: 20,
      color: Color(0xFFE0E0E0),
    );
  }
}