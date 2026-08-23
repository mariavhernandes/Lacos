import 'package:flutter/material.dart';

class CustomFooter extends StatelessWidget {
  final int currentIndex;
  final bool isFamily;

  const CustomFooter({
    super.key,
    required this.currentIndex,
    this.isFamily = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentRoute =
        ModalRoute.of(context)?.settings.name ?? '';

    // O parâmetro isFamily é a principal referência.
    // A rota é usada apenas como complemento.
    final isFamilyRoute =
        isFamily || currentRoute.contains('family');

    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // =====================================================
          // INÍCIO
          // =====================================================

          _FooterItem(
            asset:
                'assets/icons/icons_footer/footer_home_icon.png',
            label: 'Início',
            selected: currentIndex == 0,
            onTap: () {
              final homeRoute = isFamilyRoute
                  ? '/family-home'
                  : '/elderly-home';

              Navigator.pushReplacementNamed(
                context,
                homeRoute,
              );
            },
          ),

          // =====================================================
          // LOCALIZAÇÃO
          // =====================================================

          _FooterItem(
            asset:
                'assets/icons/icons_footer/footer_location_icon.png',
            label: 'Lugares',
            selected: currentIndex == 1,
            onTap: () {
              if (currentRoute != '/places') {
                Navigator.pushReplacementNamed(
                  context,
                  '/places',
                );
              }
            },
          ),

          // =====================================================
          // CONVERSAS
          // =====================================================

          _FooterItem(
            asset:
                'assets/icons/icons_footer/footer_chat_icon.png',
            label: 'Conversas',
            selected: currentIndex == 2,
            onTap: () {
              if (currentRoute != '/chat') {
                Navigator.pushReplacementNamed(
                  context,
                  '/chat',
                );
              }
            },
          ),

          // =====================================================
          // PERFIL
          // =====================================================

          _FooterItem(
            asset:
                'assets/icons/icons_footer/footer_profile_icon.png',
            label: 'Perfil',
            selected: currentIndex == 3,
            onTap: () {
              final targetProfile = isFamilyRoute
                  ? '/family-profile'
                  : '/profile';

              Navigator.pushReplacementNamed(
                context,
                targetProfile,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FooterItem extends StatelessWidget {
  const _FooterItem({
    required this.asset,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String asset;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 32,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFD9EEFF)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(
                asset,
                errorBuilder:
                    (context, error, stackTrace) => Icon(
                  Icons.image_not_supported,
                  size: 20,
                  color: selected
                      ? const Color(0xFF033B63)
                      : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 10,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.w500,
                color: const Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}