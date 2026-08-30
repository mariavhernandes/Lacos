import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_footer.dart';
import '../../../../core/widgets/custom_search_bar.dart';
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

  final TextEditingController _searchController =
      TextEditingController();

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
      final matchesQuery =
          query.isEmpty ||
          place.name.toLowerCase().contains(query) ||
          place.description.toLowerCase().contains(query) ||
          place.category.toLowerCase().contains(query);

      final matchesCategory =
          _selectedCategory == null ||
          place.category == _selectedCategory;

      final matchesLocation = switch (_selectedLocation) {
        'Até 5 km' => place.distanceKm <= 5,
        'Até 10 km' => place.distanceKm <= 10,
        _ => true,
      };

      return matchesQuery &&
          matchesCategory &&
          matchesLocation;
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
                padding: const EdgeInsets.fromLTRB(
                  16,
                  24,
                  16,
                  8,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // BARRA DE PESQUISA
                    // ==================================================

                    CustomSearchBar(
                      hintText: 'Pesquisar lugares',
                      controller: _searchController,
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // FILTROS
                    // ==================================================

                    _buildFilters(),

                    const SizedBox(height: 18),

                    // ==================================================
                    // RESULTADOS
                    // ==================================================

                    ..._filteredPlaces.map(
                      (place) => PlaceActivityCard(
                        place: place,
                      ),
                    ),

                    if (_filteredPlaces.isEmpty)
                      _buildEmptyState(),
                  ],
                ),
              ),
            ),

            // ==========================================================
            // RODAPÉ PADRÃO DO APP
            // ==========================================================

            const CustomFooter(
              currentIndex: 1,
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // FILTROS
  // ================================================================

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildAddFilterButton(),

          if (_selectedCategory != null) ...[
            const SizedBox(width: 8),
            _buildActiveFilterChip(
              label: _selectedCategory!,
              onRemove: () {
                setState(() {
                  _selectedCategory = null;
                });
              },
            ),
          ],

          if (_selectedLocation != null) ...[
            const SizedBox(width: 8),
            _buildActiveFilterChip(
              label: _selectedLocation!,
              onRemove: () {
                setState(() {
                  _selectedLocation = null;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  // ================================================================
  // BOTÃO FILTRAR
  // ================================================================

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
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
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

  // ================================================================
  // FILTRO ATIVO
  // ================================================================

  Widget _buildActiveFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF033B63),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
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

  // ================================================================
  // MENU DE FILTROS
  // ================================================================

  Future<void> _openFilterMenu() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                  title: const Text(
                    'Lazer',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'Lazer';
                    });

                    Navigator.pop(context);
                  },
                ),

                ListTile(
                  title: const Text(
                    'Esporte',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'Esporte';
                    });

                    Navigator.pop(context);
                  },
                ),

                const Divider(),

                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                  title: const Text(
                    'Até 5 km',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedLocation = 'Até 5 km';
                    });

                    Navigator.pop(context);
                  },
                ),

                ListTile(
                  title: const Text(
                    'Até 10 km',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedLocation = 'Até 10 km';
                    });

                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================================================================
  // ESTADO VAZIO
  // ================================================================

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
}