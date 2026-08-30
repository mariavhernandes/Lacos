import 'package:flutter/material.dart';

/// Item para CustomBottomNavigationBar
class BottomNavItem {
  final Widget icon;
  final Widget? activeIcon;
  final String label;

  BottomNavItem({required this.icon, this.activeIcon, required this.label});
}

/// BottomNavigationBar personalizado com estilo Figma
/// O item selecionado possui fundo em cápsula com cor azul clara
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.only(top: 12, bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            items.length,
            (index) => _buildNavItem(index),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = index == currentIndex;
    final item = items[index];

    if (isSelected) {
      // Item selecionado: cápsula apenas ao redor do ícone
      return Expanded(
        child: GestureDetector(
          onTap: () => onTap(index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Cápsula com apenas o ícone
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8ECFF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: item.activeIcon ?? item.icon,
                ),
              ),
              const SizedBox(height: 4),
              // Texto sem fundo
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F1F1F),
                  fontFamily: 'Quicksand',
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Item não selecionado: sem fundo
      return Expanded(
        child: GestureDetector(
          onTap: () => onTap(index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 24, height: 24, child: item.icon),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F1F1F),
                  fontFamily: 'Quicksand',
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
