import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_family_basic_data_page.dart'; 

import 'package:app/core/widgets/custom_footer.dart';

class EditFamilyProfileMenuPage extends StatefulWidget {
  const EditFamilyProfileMenuPage({super.key});

  @override
  State<EditFamilyProfileMenuPage> createState() =>
      _EditFamilyProfileMenuPageState();
}

class _EditFamilyProfileMenuPageState
    extends State<EditFamilyProfileMenuPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        child: Column(
          children: [
            // ==========================================
            // CABEÇALHO COM ÍCONE DE VOLTAR E TÍTULO
            // ==========================================
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
                        color: Color(0xFF777777),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // ==========================================
            // STREAM DOS DADOS DO FAMILIAR
            // ==========================================
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _firestore
                    .collection('familiares')
                    .doc(currentUser.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0D3B66),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Erro ao carregar dados do perfil.',
                        style: TextStyle(fontFamily: 'Raleway'),
                      ),
                    );
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(
                      child: Text(
                        'Dados do familiar não encontrados.',
                        style: TextStyle(fontFamily: 'Raleway'),
                      ),
                    );
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final String name =
                      data['name']?.toString() ?? 'Nome não informado';
                  final String linkedElderEmail =
                      data['linkedElderEmail']?.toString().trim() ?? '';

                  return FutureBuilder<QuerySnapshot>(
                    future: linkedElderEmail.isNotEmpty
                        ? _firestore
                            .collection('idosos')
                            .where('email', isEqualTo: linkedElderEmail)
                            .limit(1)
                            .get()
                        : null,
                    builder: (context, elderlySnapshot) {
                      String elderlyName = 'Pessoa não vinculada';

                      if (elderlySnapshot.hasData &&
                          elderlySnapshot.data!.docs.isNotEmpty) {
                        final elderlyData = elderlySnapshot.data!.docs.first
                            .data() as Map<String, dynamic>;

                        final String rawElderlyName =
                            elderlyData['name']?.toString() ??
                                elderlyData['fullName']?.toString() ??
                                '';

                        if (rawElderlyName.isNotEmpty) {
                          elderlyName = rawElderlyName.trim();
                        }
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            // ==========================================
                            // NOME DO FAMILIAR E IDOSO VINCULADO
                            // ==========================================
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text(
                                name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text(
                                'Familiar: $elderlyName',
                                textAlign: TextAlign.center,
                                softWrap: true,
                                maxLines: 3,
                                overflow: TextOverflow.visible,
                                style: const TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // ==========================================
                            // ITEM: DADOS BÁSICOS
                            // ==========================================
                            _buildMenuItem(
                              iconPath: 'assets/images/commun/basic_info_icon.png',
                              title: 'Dados básicos',
                              subtitle: 'Verifique suas informações',
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditFamilyBasicDataPage(
                                      uid: currentUser.uid,
                                      initialData: data,
                                    ),
                                  ),
                                );

                                if (result == true && mounted) {
                                  setState(() {});
                                }
                              },
                            ),
                            _buildDivider(),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomFooter(
        currentIndex: 3,
        isFamily: true,
      ),
    );
  }

  // ==========================================================
  // ITEM DE MENU
  // ==========================================================
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
                Icons.lock,
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

  // ==========================================================
  // DIVISOR
  // ==========================================================
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