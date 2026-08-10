import 'package:flutter/material.dart';

import '../../data/repositories/discovery_repository.dart';
import '../../domain/models/place_activity.dart';
import '../widgets/place_activity_card.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({
    super.key,
    this.repository = const DiscoveryRepository(),
  });

  final DiscoveryRepository repository;

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  late final List<PlaceActivity> _places;
  final TextEditingController _searchController = TextEditingController();

  String? _selectedCategory;
  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _places = widget.repository.getPlaces();
    _searchController.addListener(_updateResults);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_updateResults)
      ..dispose();
    super.dispose();
  }

  void _updateResults() {
    setState(() {});
  }

  List<PlaceActivity> get _filteredPlaces {
    final query = _searchController.text.trim().toLowerCase();
    return _places.where((place) {
      final matchesQuery = query.isEmpty ||
          place.name.toLowerCase().contains(query) ||
          place.description.toLowerCase().contains(query) ||
          place.category.toLowerCase().contains(query);

      final matchesCategory = _selectedCategory == null ||
          place.category == _selectedCategory;

      final matchesLocation = switch (_selectedLocation) {
        'Até 5 km' => place.distanceKm <= 5,
        'Até 10 km' => place.distanceKm <= 10,
        _ => true,
      };

      return matchesQuery && matchesCategory && matchesLocation;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchField(),
                    const SizedBox(height: 16),
                    _buildFilters(),
                    const SizedBox(height: 18),
                    ..._filteredPlaces.map(
                      (place) => PlaceActivityCard(place: place),
                    ),
                    if (_filteredPlaces.isEmpty) _buildEmptyState(),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 52,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: TextField(
          key: const ValueKey('search_text_field'),
          controller: _searchController,
          textInputAction: TextInputAction.search,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(
            fontFamily: 'Raleway',
            fontSize: 16,
            color: Color(0x80000000),
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Pesquisar lugares',
            hintStyle: const TextStyle(
              fontFamily: 'Raleway',
              fontSize: 16,
              color: Color(0x80000000),
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.only(left: 20),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIconConstraints: const BoxConstraints(
              maxHeight: 22,
              minHeight: 22,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Image.asset(
                'assets/images/commun/search_icon.png',
                width: 22,
                height: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Botão Filtrar no lado esquerdo
          _buildAddFilterButton(),

          // Pílulas dos filtros ativos no lado direito
          if (_selectedCategory != null) ...[
            const SizedBox(width: 8),
            _buildActiveFilterChip(
              label: _selectedCategory!,
              onRemove: () => setState(() => _selectedCategory = null),
            ),
          ],
          if (_selectedLocation != null) ...[
            const SizedBox(width: 8),
            _buildActiveFilterChip(
              label: _selectedLocation!,
              onRemove: () => setState(() => _selectedLocation = null),
            ),
          ],
        ],
      ),
    );
  }

  // Botão de "Filtrar" no formato de pílula branca simples
  Widget _buildAddFilterButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: _openFilterMenu,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            'Filtrar',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF033B63),
            ),
          ),
        ),
      ),
    );
  }

  // Pílula com o estilo azul e borda dupla conforme a imagem
  Widget _buildActiveFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF033B63), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF033B63),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFilterMenu() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Categorias',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF033B63),
                  ),
                ),
              ),
              ListTile(
                title: const Text('Lazer', style: TextStyle(fontFamily: 'Raleway')),
                onTap: () {
                  setState(() => _selectedCategory = 'Lazer');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Esporte', style: TextStyle(fontFamily: 'Raleway')),
                onTap: () {
                  setState(() => _selectedCategory = 'Esporte');
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Distância',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF033B63),
                  ),
                ),
              ),
              ListTile(
                title: const Text('Até 5 km', style: TextStyle(fontFamily: 'Raleway')),
                onTap: () {
                  setState(() => _selectedLocation = 'Até 5 km');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Até 10 km', style: TextStyle(fontFamily: 'Raleway')),
                onTap: () {
                  setState(() => _selectedLocation = 'Até 10 km');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          'Nenhum local encontrado.',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontSize: 14,
            color: Color(0xFF033B63),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
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
        children: const [
          _FooterItem(
            asset: 'assets/icons/icons_footer/footer_home_icon.png',
            label: 'Início',
          ),
          _FooterItem(
            asset: 'assets/icons/icons_footer/footer_location_icon.png',
            label: 'Lugares',
            selected: true,
          ),
          _FooterItem(
            asset: 'assets/icons/icons_footer/footer_chat_icon.png',
            label: 'Conversas',
          ),
          _FooterItem(
            asset: 'assets/icons/icons_footer/footer_profile_icon.png',
            label: 'Perfil',
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
    this.selected = false,
  });

  final String asset;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 32,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFD9EEFF) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset(asset),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Raleway',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}