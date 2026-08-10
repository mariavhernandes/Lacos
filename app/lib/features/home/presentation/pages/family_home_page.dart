import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/custom_footer.dart';

class FamilyHomePage extends StatefulWidget {
  const FamilyHomePage({super.key});

  @override
  State<FamilyHomePage> createState() => _FamilyHomePageState();
}

class _FamilyHomePageState extends State<FamilyHomePage> {
  String _userFirstName = '';
  String _userLastName = '';
  String _elderlyMonitoredName = 'Idoso vinculado';
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  String _formatFirstAndLastName(String fullName) {
    if (fullName.trim().isEmpty) return fullName;
    List<String> parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first;
    return '${parts.first} ${parts.last}';
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

          String foundElderlyName = 'Idoso vinculado';

          if (linkedEmail.isNotEmpty) {
            final QuerySnapshot elderQuery = await FirebaseFirestore.instance
                .collection('idosos')
                .where('email', isEqualTo: linkedEmail.trim())
                .limit(1)
                .get();

            if (elderQuery.docs.isNotEmpty) {
              final elderData = elderQuery.docs.first.data() as Map<String, dynamic>;
              final String rawElderName = elderData['name'] ?? elderData['fullName'] ?? '';
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
  Widget build(BuildContext context) {
    final String displayName = _isLoadingData
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
              _buildHeader(
                context,
                displayName.isEmpty ? 'Usuário' : displayName,
                _elderlyMonitoredName,
              ),
              const SizedBox(height: 20),
              _buildMetricCardsSection(),
              const SizedBox(height: 28),
              _buildRecentActivitiesSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomFooter(currentIndex: 0),
    );
  }

  Widget _buildHeader(BuildContext context, String displayName, String monitoredName) {
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
                        'Olá, $displayName!',
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Gerencie as interações\nda $monitoredName.',
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
                errorBuilder: (context, error, stackTrace) => const SizedBox(height: 110),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCardsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Conversas',
                value: '3 NOVAS',
                assetPath: 'assets/images/family/chat_icon.png',
                fallbackIcon: Icons.chat_bubble_outline,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                title: 'Novo Seguidor',
                value: 'José Carlos',
                assetPath: 'assets/images/family/new_follower.png',
                fallbackIcon: Icons.account_circle_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                title: 'Última Interação',
                value: 'Éder Barros',
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
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
                width: 16,
                height: 16,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  fallbackIcon,
                  size: 16,
                  color: const Color(0xFF033B63),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  softWrap: true,
                  style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF033B63),
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesSection() {
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
          _buildActivityCard('Anderson', 'Há 8min'),
          const SizedBox(height: 12),
          _buildActivityCard('Marina', 'Há 30min'),
          const SizedBox(height: 12),
          _buildActivityCard('Lurdes', 'Há 1 hora'),
        ],
      ),
    );
  }

  Widget _buildActivityCard(String name, String timeAgo) {
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
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFE0E0E0),
            child: Icon(Icons.person, size: 30, color: Colors.white),
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