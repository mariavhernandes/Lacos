import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/widgets/custom_footer.dart';

// ==========================================================
// PÁGINA DE MENU DE EDIÇÃO DO PERFIL DO FAMILIAR
// ==========================================================

import 'edit_profile_family/edit_family_profile_menu_page.dart';

class FamilyProfilePage extends StatefulWidget {
  const FamilyProfilePage({super.key});

  @override
  State<FamilyProfilePage> createState() => _FamilyProfilePageState();
}

class _FamilyProfilePageState extends State<FamilyProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==========================================================
  // SAIR DO APLICATIVO
  // ==========================================================

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
          style: TextStyle(
            fontFamily: 'Raleway',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontFamily: 'Raleway',
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text(
              'Sair',
              style: TextStyle(
                fontFamily: 'Raleway',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _auth.signOut();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Usuário não autenticado.',
            style: TextStyle(
              fontFamily: 'Raleway',
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: _firestore
              .collection('familiares')
              .doc(currentUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            // ==================================================
            // CARREGANDO
            // ==================================================

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0D3B66),
                ),
              );
            }

            // ==================================================
            // ERRO
            // ==================================================

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Erro ao carregar dados do perfil.',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                  ),
                ),
              );
            }

            // ==================================================
            // DOCUMENTO NÃO ENCONTRADO
            // ==================================================

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text(
                  'Dados do familiar não encontrados.',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                  ),
                ),
              );
            }

            // ==================================================
            // DADOS DO FAMILIAR
            // ==================================================

            final data =
                snapshot.data!.data() as Map<String, dynamic>;

            final String name =
                data['name']?.toString() ??
                    'Nome não informado';

            // ==================================================
            // E-MAIL DO IDOSO VINCULADO
            // ==================================================

            final String linkedElderEmail =
                data['linkedElderEmail']?.toString().trim() ?? '';

            return FutureBuilder<QuerySnapshot>(
              future: linkedElderEmail.isNotEmpty
                  ? _firestore
                      .collection('idosos')
                      .where(
                        'email',
                        isEqualTo: linkedElderEmail,
                      )
                      .limit(1)
                      .get()
                  : null,
              builder: (context, elderlySnapshot) {
                // ==================================================
                // NOME DO IDOSO
                // ==================================================

                String elderlyName = 'Pessoa não vinculada';

                if (elderlySnapshot.hasData &&
                    elderlySnapshot.data!.docs.isNotEmpty) {
                  final elderlyData =
                      elderlySnapshot.data!.docs.first.data()
                          as Map<String, dynamic>;

                  final String rawElderlyName =
                      elderlyData['name']?.toString() ??
                          elderlyData['fullName']?.toString() ??
                          '';

                  if (rawElderlyName.isNotEmpty) {
                    elderlyName = rawElderlyName.trim();
                  }
                }

                // ==================================================
                // TELA
                // ==================================================

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,
                    children: [
                      // ==========================================
                      // TÍTULO
                      // ==========================================

                      const Text(
                        'Perfil',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF777777),
                        ),
                      ),

                      const SizedBox(height: 38),

                      // ==========================================
                      // NOME DO FAMILIAR
                      // ==========================================

                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // ==========================================
                      // IDOSO VINCULADO
                      // ==========================================

                      Text(
                        'Familiar: $elderlyName',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ==========================================
                      // BOTÃO EDITAR PERFIL
                      // ==========================================

                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF0D3B66),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                          ),

                          // ======================================
                          // NAVEGAR PARA O MENU DE EDIÇÃO
                          // ======================================

                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const EditFamilyProfileMenuPage(),
                              ),
                            );
                          },

                          icon: const Icon(
                            Icons.edit,
                            size: 16,
                          ),

                          label: const Text(
                            'Editar perfil',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ==========================================
                      // CARD GERENCIAR
                      // ==========================================

                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            // ------------------------------------
                            // CABEÇALHO
                            // ------------------------------------

                            _buildHeaderItem(),

                            const Divider(
                              height: 1,
                              thickness: 0.8,
                              color: Color(0xFF8B8B8B),
                            ),

                            // ------------------------------------
                            // GRUPOS DE MENSAGEM
                            // ------------------------------------

                            _buildMenuItem(
                              title: 'Grupos de mensagem',
                              onTap: () {
                                // TODO:
                                // Navegar para grupos de mensagem.
                              },
                            ),

                            const Divider(
                              height: 1,
                              thickness: 0.8,
                              color: Color(0xFF8B8B8B),
                            ),

                            // ------------------------------------
                            // INTERESSES PESSOAIS
                            // ------------------------------------

                            _buildMenuItem(
                              title: 'Interesses pessoais',
                              onTap: () {
                                // TODO:
                                // Navegar para interesses pessoais.
                              },
                            ),

                            const Divider(
                              height: 1,
                              thickness: 0.8,
                              color: Color(0xFF8B8B8B),
                            ),

                            // ------------------------------------
                            // AMIGOS EM COMUM
                            // ------------------------------------

                            _buildMenuItem(
                              title: 'Amigos em comum',
                              onTap: () {
                                // TODO:
                                // Navegar para amigos em comum.
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ==========================================
                      // BOTÃO SAIR
                      // ==========================================

                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                const Color(0xFFD32F2F),
                            side: const BorderSide(
                              color: Color(0xFFD32F2F),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                          ),
                          onPressed: () => _logout(context),
                          icon: const Icon(
                            Icons.logout,
                            size: 18,
                            color: Color(0xFFD32F2F),
                          ),
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
            );
          },
        ),
      ),

      // ==========================================================
      // FOOTER
      // ==========================================================

      bottomNavigationBar: const CustomFooter(
        currentIndex: 3,
        isFamily: true,
      ),
    );
  }

  // ==========================================================
  // CABEÇALHO "GERENCIAR"
  // ==========================================================

  Widget _buildHeaderItem() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/family/manage.png',
              width: 25,
              height: 25,
              fit: BoxFit.contain,
              errorBuilder:
                  (context, error, stackTrace) {
                return const Icon(
                  Icons.manage_search,
                  color: Color(0xFF0D3B66),
                  size: 25,
                );
              },
            ),

            const SizedBox(width: 10),

            const Text(
              'Gerenciar',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D3B66),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ITEM DO MENU
  // ==========================================================

  Widget _buildMenuItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF5B5B5B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}